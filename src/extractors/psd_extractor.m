function [psd] = psd_extractor(eeg,fs)
% Calculate and returns the welch's power spectral density estimate
selected_bands=["delta","theta","alpha","beta","gamma","high-gamma","broad"];
bands=FrequencyBand.getSpecificBands(selected_bands);
features=["mean","median","std"];
[channels,~,trials]=size(eeg);
%nfft=N;
%pxx_length=inline_if(mod(nfft,2)==0,(nfft/2+1),(nfft+1)/2);
% TODO: check different windowing methods
% window=hamming(nfft);
% window=rectwin(nfft);
psd=nan(channels*length(features),length(bands),trials);
for trial=1:trials
    x=squeeze(eeg(:,:,trial))';
    [pxx,f]=pwelch(x,[],[],[],fs);
    for j=1:length(bands)
        [~,ii1]=min(abs(f-bands(j).min));
        [~,ii2]=min(abs(f-bands(j).max));
        psd(:,j,trial)=statistic_extractor_2d(pxx(ii1:ii2,:),features);
    end
end
end


