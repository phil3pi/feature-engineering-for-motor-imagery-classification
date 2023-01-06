% clear workspace, functionspace and figures
close all; clear all;

patient_id = 1;
% here eeg, laball, artifactsall is loaded
load(sprintf('../dataset/Training Data/DATAall_cleaneog_A0%dT_Fs250', patient_id));
[channels, N, trials] = size(eeg);
x = eeg(1, :, 1);
fs = 250;

%% Calculate the Spectral entropy of the signal
% checkout function docs:
% https://ch.mathworks.com/help/signal/ref/pentropy.html
[se, te] = pentropy(x, fs);
plot(te, se)
title('Spectral Entropy of White Noise Signal Vector')
xlabel('Time (mins)')
ylabel('Spectral Entropy')

%% estimates the approximate entropy of the uniformly sampled time-domain signal
% checkout function docs:
% https://ch.mathworks.com/help/predmaint/ref/approximateentropy.html
approxEnt = approximateEntropy(x);

%% calculate the normalized Shannon wavelet entropy
% checkout function docs:
% https://ch.mathworks.com/help/wavelet/ref/wentropy.html
ent = wentropy(x, Level = 4, Entropy = "Shannon");
