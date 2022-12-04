function [lyapunov_exp] = lyapunov_exponent_extractor(eeg,fs)
%LYAPUNOV_EXPONENT_EXTRACTOR Extracts the lyapunov exponents of the time
%series
[channels,~,trials]=size(eeg);
lyapunov_exp=nan(channels,1,trials);
for trial=1:trials
    for channel=1:channels
        lyapunov_exp(channel,:,trial) = lyapunovExponent(eeg(channel,:,trial),fs);
    end
end
end

