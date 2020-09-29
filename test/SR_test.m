wordlist = ["Wheelchair","Computer","Smartphone","Start","Stop","Off","Left",...
    "Right","Turn","Forward","Backward","Up","Down","Scroll","Zoom",...
    "Hold","Keyboard","Return","Home","Click","Select"];

%% Record.
Fs=44100;
myVoice = audiorecorder(Fs,16,1);
number  = sprintf('Ready to record 2 seconds: Press Enter.');
disp(number);
pause; 
myVoice.StartFcn = 'disp(''Start speaking.'')';
myVoice.StopFcn = 'disp(''End of recording.'')';
recordblocking(myVoice, 2); % Record 2 seconds.
%play(myVoice); % Replay speech being recorded.
myRecording = getaudiodata(myVoice);
sp = myRecording(5000:end);

%%
% extime = 0;
% for wo = 1:21
% for t = 1:10
%% Read wave file
% word = wordlist(1);
% file  = sprintf('Test1/%s/%s (%d).wav',word,word,1);
% [s,Fs] = audioread(file);
% sp = s(:,1);

%% Start timer
% timer = tic;

%% LPC extraction.
sp = sp/max(abs(sp));  % Normalize speech signal to [-1,1]
ts = 1/Fs;
% t = 0:ts:(length(sp)*ts)-ts;

% figure();
% subplot(3,1,1); plot(t,sp);
% title('Original Signal: Stop'); xlabel('Seconds'); ylabel('Amplitude');  % Plot signal

%% Filter out noise with threshold value
a = [1.0000 -0.6926 0.4609 -0.0696];
b = [0.0873 0.2620 0.2620 0.0873];
sp = filter(b,a,sp);
%sp = lowpass(sp,5000,Fs);

%% Threshold extraction
thd=0.005; % Noise thershold 0.04
% j=1;
% y1 = 0;
% for i=1:length(sp)
%     if(abs(sp(i))>thd)
%         y1(j)=sp(i);
%         j=j+1;
%     end
% end
y1 = sp_thd(sp,thd);

% Passed through high pass filter to boost the high frequency components.
frame = 23;
blocklen=2000;  %45ms block
overlap=500;    % Overlap samples of each frames (1/4 frame overlap)
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

%% Framing the signal.
block(1,:)=y(1:blocklen); % First frame
for i=1:(frame-1)      % Remaining 13 frames.
    block(i+1,:)=y(i*(blocklen-overlap):(i*(blocklen-overlap)+blocklen-1));
end

%% MAZCR extraction
% blocklen=1000;  %45ms block
% overlap=250;    % Overlap samples of each frames (1/4 frame overlap)
% frame_total = ceil((length(sp) - blocklen)/(blocklen-overlap)) + 1;
% y = [sp',zeros(1,(blocklen+(frame_total-1)*(blocklen-overlap))-length(sp))];
% block_ori(1,:)=sp(1:blocklen); % First frame
% for i=1:(frame_total-1)      % Remaining frames.
%     block_ori(i+1,:)=y(i*(blocklen-overlap):i*(blocklen-overlap)+blocklen-1);
% end
% 
% MA = zeros(1,frame_total);
% ZCR = zeros(1,frame_total);
% for i=1:frame_total  
%     signal = block_ori(i,:)';
%     MA(i) = mean(abs(signal));
%     zcd = dsp.ZeroCrossingDetector;
%     ZCR(i) = zcd(signal);
% end
% 
% %%
% frame = 46;
% block_sp = zeros(frame,blocklen);
% index = 1;
% MAlow_thd = 0.005;
% ZCR_thd = 50;
% count = zeros(1,frame);
% for i = 1:frame_total
%     if MA(i)>=0.05
%         %block_sp(index*blocklen+1:index*blocklen+blocklen) = block(i,:);
%         block_sp(index,:) = block_ori(i,:);
%         count(index) = i;
%         index = index+1;
%     elseif MA(i)>=MAlow_thd && ZCR(i)>=ZCR_thd
%         %block_sp(index*blocklen+1:index*blocklen+blocklen) = block(i,:);
%         block_sp(index,:) = block_ori(i,:);
%         count(index) = i;
%         index = index+1;
%     end
% end
% % for i =1:frame
% %     block_sp(i,:) = filter([1 -0.8],1,block_sp(i,:));
% % end
% % block_sp = filter([1 -0.8],1,block_sp); % High pass filter
% 
% out_sp = block_sp(1,blocklen);
% for i = 1:(frame-1)
%    if count(i) == count(i+1) + 1
%        out_sp = [out_sp,block_sp(i+1,overlap+1:blocklen)];
%    else
%        out_sp = [out_sp,block_sp(i+1,:)];
%    end
%    %out_sp = [out_sp,block_sp(i*blocklen+overlap+1:(i+1)*blocklen)]; 
%    
% end
% 
% % t = 0:ts:(length(out_sp)*ts)-ts;
% % subplot(3,1,2);
% % plot(t,out_sp);title('Extracted speech');
% 
% %% MAZCR + Threshold
% thd=0.005; % Noise thershold 0.04
% y1 = sp_thd(out_sp,thd);
% 
% if length(y1)>(blocklen+(frame-1)*(blocklen-overlap))
%     y2 = y1(1:blocklen+(frame-1)*(blocklen-overlap));
% else
%     y2=[y1,zeros(1,(blocklen+(frame-1)*(blocklen-overlap))-length(y1))];  % 14 frames.
% end
% % y2=[y1,zeros(1,(blocklen+(frame-1)*(blocklen-overlap))-length(y1))];  % 14 frames.
% y = filter([1 -0.8],1,y2');  %high pass filter to boost the high frequency components
% 
% % t1 = 0:ts:(length(y)*ts)-ts;
% % subplot(3,1,2); plot(t1,y);
% % title('Noise + High Pass Filtered Signal'); xlabel('Seconds'); ylabel('Amplitude');
% 
% block(1,:)=y(1:blocklen); % First frame
% for i=1:(frame-1)      % Remaining 13 frames.
%     block(i+1,:)=y(i*(blocklen-overlap):(i*(blocklen-overlap)+blocklen-1));
% end

%% Calculate LPC with Auto-correlation Matrix, with numbers of coefficient = K
K = 12; % Number of LPC coefficients for each frame.
w=hamming(blocklen); % Hamming window
for i=1:frame
    [a,lags]=xcorr((block(i,:).*w'),K); % Finding auto correlation for lag -K to K
%     [a,lags]=xcorr((block_sp(i,:).*w'),K);
    for j=1:K
        auto(j,:)=fliplr(a(j+1:j+K));   % Forming autocorrelation matrix from lag -(K-1) to (K-1)
    end
    z=fliplr(a(1:K));   % Forming a column matrix of autocorrelations for lags 1 to K 
    alpha=pinv(auto)*z';
    lpcc(:,i)=alpha;     % LPCC for a 'single' frame
end
X=reshape(lpcc,1,frame*K);   % LPCC for the whole speech signal (frames * K LPCC)
% subplot(3,1,3);
% stem(X); title('LPC coefficient');

%% SVM prediction
label = 0;
inst = sparse(X);

load('model/model_K12.mat');
[predict_label, accuracy, dec_values] = svmpredict(label,inst, model);

% disp(wordlist(predict_label+1));
fprintf('Predicted word: %s\n', wordlist(predict_label+1));
clear;
%% Display timer
% fprintf('Prediction time = %f sec\n', toc(timer));

% extime = extime + toc(timer);
% end
% end

% disp(extime);
