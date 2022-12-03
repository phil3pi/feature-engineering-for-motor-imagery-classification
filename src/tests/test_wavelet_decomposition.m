% clear workspace, functionspace and figures
close all;clear all;

patient_id=1;
% here eeg, laball, artifactsall is loaded
load(sprintf('../dataset/Training Data/DATAall_cleaneog_A0%dT_Fs250',patient_id));
[channels,N,trials]=size(eeg);

x=eeg(1,:,1);
fs=250;               %sampling rate
T = 1/fs;             % Sampling period

figure;
[wt,f]=cwt(x,'bump',fs);
w=wt;
plot(f,w);

%% discrete wavelet transformation
[cA,cD]=dwt(x,'db2');

%% wavelet decomposition with wavedec
time=((0:N-1)/fs)-2;
figure
plot(time,x);

[c,l] = wavedec(x,5,'db2');

approx = appcoef(c,l,'db2');
[cd1,cd2,cd3,cd4,cd5] = detcoef(c,l,[1 2 3 4 5]);

figure
subplot(6,1,1)
plot(approx)
title('Approximation Coefficients')
subplot(6,1,2)
plot(cd3)
title('Level 5 Detail Coefficients')
subplot(6,1,3)
plot(cd3)
title('Level 4 Detail Coefficients')
subplot(6,1,4)
plot(cd3)
title('Level 3 Detail Coefficients')
subplot(6,1,5)
plot(cd2)
title('Level 2 Detail Coefficients')
subplot(6,1,6)
plot(cd1)
title('Level 1 Detail Coefficients')

Y = fft(approx,length(approx));

L = length(approx);   % Length of signal
t = (0:L-1)*T;        % Time vector

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = fs*(0:(L/2))/L;
figure;
subplot(2,1,1);
plot(f,P1);

L = 1500;             % Length of signal
t = (0:L-1)*T;        % Time vector

Y2 = fft(x,length(x));
P2 = abs(Y2/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = fs*(0:(L/2))/L;
subplot(2,1,2);
plot(f,P1);

%% cwt filterbank
% frq1 = 32;
% amp1 = 1;
% frq2 = 64;
% amp2 = 2;
%
% Fs = 1e3;
% t = 0:1/Fs:1;
% x = amp1*sin(2*pi*frq1*t).*(t>=0.1 & t<0.3)+...
%     amp2*sin(2*pi*frq2*t).*(t>0.6 & t<0.9);
%
% figure(1);
% subplot(3,1,1);
% plot(t,x)
% grid on
% xlabel("Time (sec)")
% ylabel("Amplitude")
% title("Signal")
% subplot(3,1,2);
% fb = cwtfilterbank(SignalLength=numel(x),SamplingFrequency=Fs,...
%     FrequencyLimits=[20 100]);
% freqz(fb)
% subplot(3,1,3);
% datacursormode on
% cwt(x,FilterBank=fb)

