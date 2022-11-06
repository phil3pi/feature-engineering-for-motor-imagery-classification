function [psd] = psd_extractor(eeg,fs)
% Calculate and returns the welch's power spectral density estimate
[channels,N,trials]=size(eeg);
nfft=N;
pxx_length=inline_if(mod(nfft,2)==0,(nfft/2+1),(nfft+1)/2);
noverlap=nfft/2;
% TODO: check different windowing methods
window=hanning(nfft);
% window=hamming(nfft);
% window=rectwin(nfft);
psd=nan(channels,pxx_length,trials);
for trial=1:trials
    for channel=1:channels
        x=eeg(channel,:,trial);
        [pxx,~]=pwelch(x,window,noverlap,nfft,fs);
        psd(channel,:,trial)=pxx;
    end
end
end

