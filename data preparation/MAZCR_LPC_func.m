function [] = MAZCR_LPC_func(num1,num2,word,label)
        %% Parameters
    frame = 31;
    blocklen=1500;  %45ms block
    overlap=375;    % Overlap samples of each frames (1/4 frame overlap)
    
    MAhigh_thd = 0.05;
    MAlow_thd = 0.005;
    ZCR_thd = 50;
    K = 6; % Number of LPC coefficients for each frame.
        
    for re = num1:num2
        %% Read audio file
        file  = sprintf('%s/%s (%d).wav',word,word,re);
        [s,Fs] = audioread(file);
        sp = s(:,1);
        sp = sp/max(abs(sp));  % Normalize speech signal to [-1,1]
        
        %% Low-pass filter
        a = [1.0000 -0.6926 0.4609 -0.0696];
        b = [0.0873 0.2620 0.2620 0.0873];
        %sp = filter([0.0873 0.2620 0.2620 0.0873],[1 -0.6926 0.4609 -0.0696],sp);
        sp = filter(b,a,sp);

        %% Framing and calculating MA, ZCR
        %blocklen=2000;  %45ms block
        %overlap=500;    % Overlap samples of each frames (1/4 frame overlap)
        frame_total = ceil((length(sp) - blocklen)/(blocklen-overlap)) + 1;
        y = [sp',zeros(1,(blocklen+(frame_total-1)*(blocklen-overlap))-length(sp))];
        block_ori(1,:)=sp(1:blocklen); % First frame
        for i=1:(frame_total-1)      % Remaining frames.
            block_ori(i+1,:)=y(i*(blocklen-overlap):(i*(blocklen-overlap)+blocklen-1));
        end

        for i=1:frame_total  
            signal = block_ori(i,:)';
            MA(i) = mean(abs(signal));
            zcd = dsp.ZeroCrossingDetector;
            ZCR(i) = zcd(signal);
        end

        %% Remove silent and noise based on MA, ZCR
        %frame = 21;
        %MAlow_thd = 0.002;
        %ZCR_thd = 100;
        block_sp = zeros(frame,blocklen);
        index = 1;
        count = zeros(1,frame);
        for i = 1:frame_total
            if MA(i)>=0.05
                %block_sp(index*blocklen+1:index*blocklen+blocklen) = block(i,:);
                block_sp(index,:) = block_ori(i,:);
                count(index) = i;
                index = index+1;
            elseif MA(i)>=MAlow_thd && ZCR(i)>=ZCR_thd
                %block_sp(index*blocklen+1:index*blocklen+blocklen) = block(i,:);
                block_sp(index,:) = block_ori(i,:);
                count(index) = i;
                index = index+1;
            end
        end
        
        %% High-pass filter
%         for i =1:frame
%             block_sp(i,:) = filter([1 -0.8],1,block_sp(i,:));
%         end

        %%
        out_sp = block_sp(1,blocklen);
        for i = 1:(frame-1)
           if count(i) == count(i+1) + 1
               out_sp = [out_sp,block_sp(i+1,overlap+1:blocklen)];
           else
               out_sp = [out_sp,block_sp(i+1,:)];
           end
           %out_sp = [out_sp,block_sp(i*blocklen+overlap+1:(i+1)*blocklen)]; 

        end
        % MAZCR + Threshold
        thd=0.005; % Noise thershold 0.04
        y1 = sp_thd(out_sp,thd);
        
        if length(y1)>(blocklen+(frame-1)*(blocklen-overlap))
            y2 = y1(1:blocklen+(frame-1)*(blocklen-overlap));
        else
            y2=[y1,zeros(1,(blocklen+(frame-1)*(blocklen-overlap))-length(y1))];  % 14 frames.
        end
        % y2=[y1,zeros(1,(blocklen+(frame-1)*(blocklen-overlap))-length(y1))];  % 14 frames.
        y = filter([1 -0.8],1,y2');  %high pass filter to boost the high frequency components
        
        % t1 = 0:ts:(length(y)*ts)-ts;
        % subplot(3,1,2); plot(t1,y);
        % title('Noise + High Pass Filtered Signal'); xlabel('Seconds'); ylabel('Amplitude');
        
        block(1,:)=y(1:blocklen); % First frame
        for i=1:(frame-1)      % Remaining 13 frames.
            block(i+1,:)=y(i*(blocklen-overlap):(i*(blocklen-overlap)+blocklen-1));
        end

        %% Calculate LPC with Auto-correlation Matrix, with numbers of coefficient = K
        %K = 8; % Number of LPC coefficients for each frame.
        w=hamming(blocklen); % Hamming window
        for i=1:frame
            [a,lags]=xcorr((block(i,:).*w'),K);
%             [a,lags]=xcorr((block_sp(i,:).*w'),K);
            for j=1:K
                auto(j,:)=fliplr(a(j+1:j+K));   % Forming autocorrelation matrix from lag -(K-1) to (K-1)
            end
            z=fliplr(a(1:K));   % Forming a column matrix of autocorrelations for lags 1 to K 
            alpha=pinv(auto)*z';
            lpcc(:,i)=alpha;     % LPCC for a 'single' frame
        end
        X=reshape(lpcc,1,frame*K);   % LPCC for the whole speech signal (frames * K LPCC)

        L = length(X);
        fid=fopen('train_final/train_K6F31_MZthd.txt','a');
        fprintf(fid,'%d ',label);
        for i = 1:L-1
            fprintf(fid,'%d:%1.5f ',i,X(i));
        end
        fprintf(fid,'%d:%1.5f\r\n',L,X(L));
        fclose(fid);
    end

end

