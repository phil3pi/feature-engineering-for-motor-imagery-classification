% clear workspace, functionspace and figures
close all;clear all;

patient_id=1;
% here eeg, laball, artifactsall is loaded
load(sprintf('./Training Data/DATAall_cleaneog_A0%dT_Fs250',patient_id));
[channels,N,trials]=size(eeg);

x=eeg(1,:,1);
fs=250; %sampling rate

t=tiledlayout(3,2);
t.TileSpacing='compact';

nexttile;
% print pure amplitude signal
time=((0:N-1)/fs)-2;
plot(time,x);
title('Signal data')
xlabel('s')
ylabel('amplitude [µV]')

nexttile;
% TODO: check fft2,fftn,fft2n,fftw,fftshift,ifft,fftfilt
y=fft(x);
f=fs*(0:(N/2))/N;
% TODO: think about/investigate why to compute the two-sided and single
% sided spectrum
P2 = abs(y/N);
P1 = P2(1:N/2+1);
P1(2:end-1) = 2*P1(2:end-1);
plot(f,P1) 
title('FFT of signal data')
xlabel('Hz')
ylabel('amplitude [µV]')

nexttile;
% print unscaled power spectral density
nfft=N;
noverlap=nfft/2;
% TODO: check different windowing methods
window=hanning(nfft);
% window1=hamming(nfft);
% window=rectwin(nfft);
[pxx,f]=pwelch(x,window,noverlap,nfft,fs);
plot(f,pxx);
title('Welch`s PSD')
xlabel('Hz')
ylabel('W/Hz')

nexttile;
% print scaled power spectral density by logarithm
PdB_Hz= 10*log10(pxx);
plot(f,PdB_Hz);
title('Welch`s PSD')
xlabel('Hz')
ylabel('dBW/Hz')

nexttile;
% print wavelet transformation
% TODO: checkout cwtfilterbank: https://de.mathworks.com/help/wavelet/ref/cwtfilterbank.html
[wt,f]=cwt(x,fs);
plot(f,wt);
title('CWT')
xlabel('Hz')
ylabel('Amplitude')


