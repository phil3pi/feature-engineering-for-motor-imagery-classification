classdef FeatureExtractor
    %EXTRACTOR Contains several feature extractor methods
    %   Detailed explanation goes here
    methods(Static)
        function ar_coeff = ar(eeg,ar_params)
            %AR_EXTRACTOR extract parameters of autoregressive model
            % The supported ar method types are: arcov, aryule, arburg,
            % armcov
            arguments
                eeg (:,:,:);
                ar_params (1,1) ArParameters;
            end
            order = ar_params.order;
            if ar_params.use_white_noise
                order = order + 1;
            end
            [channels,~,trials]=size(eeg);
            ar_coeff=nan(channels,order,trials);
            for trial=1:trials
                for channel=1:channels
                    switch ar_params.method
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
                    if ar_params.use_white_noise
                        coeff = [a,e];
                    else
                        coeff = a;
                    end
                    ar_coeff(channel,:,trial) = coeff(linspace(2,order + 1,order));
                end
            end
        end

        function statistics = statistic(eeg,fs,statistic_features)
            % STATISTIC Extract statistic features of the raw eeg signal
            arguments
                eeg (:,:,:);
                fs {mustBeNumeric};
                statistic_features (1,1) StatisticParameters;
            end
            [channels,~,trials]=size(eeg);
            statistics=nan(channels,length(statistic_features),trials);
            for trial=1:trials
                data = statistic_extractor(eeg(:,:,trial)',statistic_features,fs,1);
                statistics(:,:,trial) = permute(data,[2,1]);
            end
        end

        function psd = psd(eeg,fs,psd_param)
            % PSD Calculate and returns the welch's power spectral density
            % estimate
            arguments
                eeg (:,:,:);
                fs {mustBeNumeric};
                psd_param (1,1) PsdParameters;
            end
            
            bands=psd_param.frequencyBands;
            [channels,~,trials]=size(eeg);
            psd=nan(channels*length(psd_param.statisticParameters.statisticFeatures),length(bands),trials);
            for trial=1:trials
                x=squeeze(eeg(:,:,trial))';
                % TODO: eventually experiment with non-default parameters of pwelch
                [pxx,f]=pwelch(x,[],[],[],fs);
                for j=1:length(bands)
                    [~,ii1]=min(abs(f-bands(j).min));
                    [~,ii2]=min(abs(f-bands(j).max));
                    psd(:,j,trial)=statistic_extractor(pxx(ii1:ii2,:),psd_param.statisticParameters,fs,1);
                end
            end
        end

        function lyapunov_exp = lyapunovExponent(eeg,fs)
            %LYAPUNOVEXPONENT Extracts the lyapunov exponents of the time
            %series
            arguments
                eeg (:,:,:);
                fs {mustBeNumeric};
            end
            [channels,~,trials]=size(eeg);
            lyapunov_exp=nan(channels,1,trials);
            for trial=1:trials
                for channel=1:channels
                    lyapunov_exp(channel,:,trial) = lyapunovExponent(eeg(channel,:,trial),fs);
                end
            end
        end

        function entropy = waveletEntropy(eeg,parameters)
            %WAVELETENTROPY Summary of this function goes here
            %   Detailed explanation goes here
            arguments
                eeg (:,:,:);
                parameters (1,1) WaveletEntropyParameters;
            end
            [channels,~,trials]=size(eeg);
            entropy_length=length(wentropy(eeg(1,:,1),...
                Entropy=parameters.entropy_type,...
                Transform=parameters.transform_type));
            entropy=nan(channels,entropy_length,trials);
            for trial=1:trials
                for channel=1:channels
                    entropy(channel,:,trial)=wentropy(...
                        eeg(channel,:,trial),...
                        Entropy=parameters.entropy_type,...
                        Transform=parameters.transform_type);
                end
            end
        end

        function var = waveletVariance(eeg)
            %WAVELETVARIANCE calculates the variance of wavelet coeff.
            arguments
                eeg (:,:,:);
            end
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

        function corr = waveletCorrelation(eeg)
            %WAVELETCORRELATION calculates the correlation between each
            %channel signal
            arguments
                eeg (:,:,:);
            end
            [channels,~,trials] = size(eeg);
            corr = nan(channels,channels-1,trials);

            for trial=1:trials
                for channel=1:channels
                    current_signal_coeff = modwt(eeg(channel,:,trial),'db2');
                    index = 1;
                    for c=1:channels
                        if c==channel
                            continue
                        end
                        temp_coeff = modwt(eeg(c,:,trial),'db2');
                        corr(channel,index,trial) = mean(modwtcorr(current_signal_coeff,temp_coeff,'db2'));
                        index = index + 1;
                    end
                end
            end
        end

        function ar_psd_features = arPsd(eeg,fs,ar_psd_param)
            %ARPSD calculate the psd with autoregression model
            % additionally statistic feature will be extracted of the
            % estimated psd
            arguments
                eeg (:,:,:);
                fs {mustBeNumeric};
                ar_psd_param (1,1) ArPsdParameters;
            end
            statistic_features = ar_psd_param.statistic.statisticFeatures;
            bands=ar_psd_param.frequencyBands;
            [channels,~,trials]=size(eeg);
            ar_psd_features=nan(channels*length(statistic_features),length(bands),trials);
            for trial=1:trials
                x=squeeze(eeg(:,:,trial))';
                % TODO: experiment with non default parameters
                switch ar_psd_param.method
                    case "pcov"
                        [pxx,f]=pcov(x,ar_psd_param.order,[],fs);
                    case "pmcov"
                        [pxx,f]=pmcov(x,ar_psd_param.order,[],fs);
                    case "pburg"
                        [pxx,f]=pburg(x,ar_psd_param.order,[],fs);
                    case "pyulear"
                        [pxx,f]=pyulear(x,ar_psd_param.order,[],fs);
                    otherwise
                        error("AR psd extractor only supports pcov, pmcov, pburg or pyulear");
                end
                for j=1:length(bands)
                    [~,ii1]=min(abs(f-bands(j).min));
                    [~,ii2]=min(abs(f-bands(j).max));
                    ar_psd_features(:,j,trial)=statistic_extractor(pxx(ii1:ii2,:),statistic_features,fs,1);
                end
            end
        end
    end
end

