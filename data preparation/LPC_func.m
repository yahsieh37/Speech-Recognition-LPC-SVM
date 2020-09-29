function [] = LPC_func(num1,num2,word,label)
    for re = num1:num2

        file  = sprintf('%s/%s (%d).wav',word,word,re);
        [s,Fs] = audioread(file);
        sp = s(:,1);
        sp = sp/max(abs(sp));  % Normalize speech signal to [-1,1]
        ts = 1/Fs;
        t = 0:ts:(length(sp)*ts)-ts;

        %figure();
        %subplot(3,1,1); plot(t,sp);
        %title('Original Signal'); xlabel('Seconds'); ylabel('Amplitude');  % Plot signal

        %% Filter out noise with threshold value
        a = [1.0000 -0.6926 0.4609 -0.0696];
        b = [0.0873 0.2620 0.2620 0.0873];
        sp = filter(b,a,sp);
        
        thd=0.005; % Noise thershold
        j=1;
        y1 = 0;
        for i=1:length(sp)
            if(abs(sp(i))>thd)
                y1(j)=sp(i);
                j=j+1;
            end
        end

        %% Passed through high pass filter to boost the high frequency components.
        frame = 46;
        blocklen=1000;  %45ms block
        overlap=250;    % Overlap samples of each frames (1/4 frame overlap)
        if length(y1)>(blocklen+(frame-1)*(blocklen-overlap))
            y2 = y1(1:blocklen+(frame-1)*(blocklen-overlap));
        else
            y2=[y1,zeros(1,(blocklen+(frame-1)*(blocklen-overlap))-length(y1))];  % 14 frames.
        end
        %y2=[y1,zeros(1,(blocklen+(frame-1)*(blocklen-overlap))-length(y1))];  % 14 frames.
        y = filter([1 -0.8],1,y2');  %high pass filter to boost the high frequency components

        %t1 = 0:ts:(length(y)*ts)-ts;
        %subplot(3,1,2); plot(t1,y);
        %title('Noise + High Pass Filtered Signal'); xlabel('Seconds'); ylabel('Amplitude');

        %% Framing the signal.
        block(1,:)=y(1:blocklen); % First frame
        for i=1:(frame-1)      % Remaining 13 frames.
            block(i+1,:)=y(i*(blocklen-overlap):(i*(blocklen-overlap)+blocklen-1));
        end

        %% Calculate LPC with Auto-correlation Matrix, with numbers of coefficient = K
        K = 8; % Number of LPC coefficients for each frame.
        w=hamming(blocklen); % Hamming window
        for i=1:frame
            %[a,lags]=xcorr((block(i,:).*w'),K); % Finding auto correlation for lag -K to K
            [a,lags]=xcorr((block(i,:)),K);
            for j=1:K
                auto(j,:)=fliplr(a(j+1:j+K));   % Forming autocorrelation matrix from lag -(K-1) to (K-1)
            end
            z=fliplr(a(1:K));   % Forming a column matrix of autocorrelations for lags 1 to K 
            alpha=pinv(auto)*z';
            lpcc(:,i)=alpha;     % LPCC for a 'single' frame
        end
        X=reshape(lpcc,1,frame*K);   % LPCC for the whole speech signal (11 frames * K LPCC)
        %subplot(3,1,3);
        %stem(X); title('LPC coefficient');

        L = length(X);
        fid=fopen('train_final/train_K8F46.txt','a');
        fprintf(fid,'%d ',label);
        for i = 1:L-1
            fprintf(fid,'%d:%1.5f ',i,X(i));
        end
        fprintf(fid,'%d:%1.5f\r\n',L,X(L));
        fclose(fid);
    end

end

