% clear workspace, functionspace and figures
close all;clear all;

patient_id=1;
% here eeg, laball, artifactsall is loaded
load(sprintf('./Training Data/DATAall_cleaneog_A0%dT_Fs250',patient_id));

%Remove artifactual trials
artifacts=find(artifactsall==1);
eeg(:,:,artifacts)=[];
laball(artifacts)=[];
[channels,N,trials]=size(eeg);

x=eeg(1,:,1);

fs=250; %sampling rate
nfft=N;
noverlap=nfft/2;
% TODO: check different windowing methods
window=hanning(nfft);
% window1=hamming(nfft);
% window=rectwin(nfft);
[pxx,f]=pwelch(x,window,noverlap,nfft,fs);

PdB_Hz= 10*log10(pxx);

figure;plot(f,PdB_Hz);
title('Welch Power Spectral density estimate')
xlabel('Hz')
ylabel('dBW/Hz')

