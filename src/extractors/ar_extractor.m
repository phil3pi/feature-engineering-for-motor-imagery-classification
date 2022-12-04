function [ar_burg_coeff] = ar_extractor(eeg,method,order,use_white_noice_variance)
%AR_EXTRACTOR extract parameters of autoregressive model
%   The supported ar method types are: arcov, aryule, arburg, armcov
if use_white_noice_variance
    order = order + 1;
end
[channels,~,trials]=size(eeg);
ar_burg_coeff=nan(channels,order,trials);
for trial=1:trials
    for channel=1:channels
        switch method
            case "arcov"
                [a,e] = arcov(eeg(channel,:,trial),order);
            case "aryule"
                [a,e] = aryule(eeg(channel,:,trial),order);
            case "arburg"
                [a,e] = arburg(eeg(channel,:,trial),order);
            case "armcov"
                [a,e] = armcov(eeg(channel,:,trial),order);
            otherwise
                error("AR extractor only supports arcov, aryule, arburg or armcov");
        end
        
        % TODO: implement pcov, pburg, pmcov, pyulear later
        if use_white_noice_variance
            coeff = [a,e];
        else
            coeff = a;
        end
        
        ar_burg_coeff(channel,:,trial) = coeff(linspace(2,order + 1,order));
    end
end
end

