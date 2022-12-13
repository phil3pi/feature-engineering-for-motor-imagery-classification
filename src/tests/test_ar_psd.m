% clear workspace, functionspace and figures
close all;clear all;

patient_id=1;
% here eeg, laball, artifactsall is loaded
load(sprintf('../dataset/Training Data/DATAall_cleaneog_A0%dT_Fs250',patient_id));
[channels,N,trials]=size(eeg);

x=eeg(1,:,1);
fs=250; %sampling rate

r=FeatureExtractor.arPsd(x,fs,"pcov",5,["delta","theta","alpha","beta","gamma","high-gamma","broad"],["mean"]);
disp(r);