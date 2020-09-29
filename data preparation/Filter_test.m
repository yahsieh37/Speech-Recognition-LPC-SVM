% b = [1 -0.8];
% a = 1;

lpFilt = designfilt('lowpassiir','PassbandFrequency',5000,...
         'StopbandFrequency',20000,'PassbandRipple',0.2, ...
         'SampleRate',44100);
% lpFilt = designfilt('lowpassiir','NumeratorOrder',1,...
%          'DenominatorOrder',5,'HalfPowerFrequency',8000, ...
%          'SampleRate',44100);
% fvtool(lpFilt);
% [b,a] = tf(lpFilt);

bpFilt = designfilt('bandpassiir', ...       % Response type
       'StopbandFrequency1',400, ...    % Frequency constraints
       'PassbandFrequency1',500, ...
       'PassbandFrequency2',5000, ...
       'StopbandFrequency2',10000, ...
       'StopbandAttenuation1',40, ...   % Magnitude constraints
       'StopbandAttenuation2',50, ...
       'SampleRate',44100)   ;            % Sample rate
% hpFilt = designfilt('highpassiir','PassbandFrequency',10000,...
%          'StopbandFrequency',1000, ...
%          'SampleRate',44100);
% fvtool(lpFilt);
% [b,a] = tf(lpFilt);
b = [1.25 -0.5];
a = [1];

% b = conv(b1,b2);
% a = conv(a1,a2);

N = 10000;
Fs = 44100;
[H,F] = freqz(b,a,'whole',N);
P2 = abs(H);
P1 = P2(1:N/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(N/2))/N;
plot(f,P1);
xlabel('Freq (Hz)'); ylabel('Amplitude (|F(w)|)');
