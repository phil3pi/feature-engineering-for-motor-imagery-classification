function [entropy] = wavelet_entropy_extractor(eeg,parameters)
%WAVELET_ENTROPY_EXTRACTOR Summary of this function goes here
%   Detailed explanation goes here
lvl_of_detail=str2double(parameters(3));
entropy_type=parameters(1);
transform_type=parameters(2);
[channels,~,trials]=size(eeg);
entropy_length=length(wentropy(eeg(1,:,1),Level=lvl_of_detail,Entropy=entropy_type,Transform=transform_type));
entropy=nan(channels,entropy_length,trials);
for trial=1:trials
    for channel=1:channels
        entropy(channel,:,trial)=wentropy(eeg(channel,:,trial),Level=lvl_of_detail,Entropy=entropy_type,Transform=transform_type);
    end
end
end

