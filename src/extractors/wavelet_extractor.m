function [w_coeff] = wavelet_extractor(eeg)
    % Calculate the coefficients of the wavelet transformation
    lvl_of_detail = 6;
    [channels,~,trials]=size(eeg);
    w_coeff=nan(channels,lvl_of_detail,trials);
    for trial=1:trials
        for channel=1:channels
            [c,l] = wavedec(eeg(channel,:,trial),lvl_of_detail,'db2');
            [cd1 cd2 cd3 cd4 cd5 cd6] = detcoef(c,l,[1 2 3 4 5 6]);
%             x = squeeze(eeg(channel,:,trial));
%             [~,cD]=dwt(x,'db2');
%             w_coeff(channel,:,trial) = cD(1,1:lvl_of_detail);

            % TODO: implement further
            error("Please implement the necessary code in the wavelet extractor.");
        end
    end
end

