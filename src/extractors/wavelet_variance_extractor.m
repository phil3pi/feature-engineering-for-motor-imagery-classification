function [var] = wavelet_variance_extractor(eeg)
%WAVELET_VARIANCE_EXTRACTOR calculate the variance of wavelet coeff.
[channels,~,trials]=size(eeg);
% TODO: do not hardcode variance coefficients
var=nan(channels,5,trials);
for trial=1:trials
    for channel=1:channels
        wsoi = modwt(eeg(channel,:,trial),'db2');
        var(channel,:,trial) = modwtvar(wsoi,'db2');
    end
end
end

