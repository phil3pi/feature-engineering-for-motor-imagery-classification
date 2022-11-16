function [psd] = psd_extractor(eeg,fs)
% Calculate and returns the welch's power spectral density estimate

% delta theta alpha beta gamma high gamma broad
bands=[0.1 3.5; 4 7.5; 8 12.5; 13 29.5; 30 60; 60.5 100; 0.1 100];
features=["mean","median","std"];
[channels,N,trials]=size(eeg);
%nfft=N;
%pxx_length=inline_if(mod(nfft,2)==0,(nfft/2+1),(nfft+1)/2);
% TODO: check different windowing methods
% window=hamming(nfft);
% window=rectwin(nfft);
psd=nan(channels*length(features),size(bands,1),trials);
for trial=1:trials
        x=squeeze(eeg(:,:,trial))';
        [pxx,f]=pwelch(x,[],[],[],fs);
        for j=1:size(bands,1)
            [mm,ii1]=min(abs(f-bands(j,1)));
            [mm,ii2]=min(abs(f-bands(j,2)));
                    %psd(:,j,trial)=mean(pxx(ii1:ii2,:));
                    psd(:,j,trial)=statistic_extractor_2d(pxx(ii1:ii2,:),features);
        end
end


