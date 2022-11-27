function [entropy] = wavelet_entropy_extractor(eeg,lvl_of_detail)
    %WAVELET_ENTROPY_EXTRACTOR Summary of this function goes here
    %   Detailed explanation goes here
    [channels,~,trials]=size(eeg);
    entropy=nan(channels,lvl_of_detail+1,trials);
    for trial=1:trials
        for channel=1:channels
            entropy(channel,:,trial)=wentropy(eeg(channel,:,trial),Level=lvl_of_detail,Entropy="Shannon");
        end
    end
end

