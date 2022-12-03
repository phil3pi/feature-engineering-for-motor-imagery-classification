function [var] = wavelet_variance_extractor(eeg)
%WAVELET_VARIANCE_EXTRACTOR calculate the variance of wavelet coeff.
[channels,~,trials]=size(eeg);

wsoi1 = modwt(eeg(1,:,1),'db2');
variance_coeff_length = length(modwtvar(wsoi1,'db2'));

var=nan(channels,variance_coeff_length,trials);
for trial=1:trials
    for channel=1:channels
        wsoi = modwt(eeg(channel,:,trial),'db2');
        var(channel,:,trial) = modwtvar(wsoi,'db2');
    end
end
end

