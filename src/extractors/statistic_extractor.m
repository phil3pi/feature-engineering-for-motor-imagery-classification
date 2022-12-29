function [statistic_features] = statistic_extractor(data,statistic_parameters,fs,dim)
% STATISTIC_EXTRACTOR Extracts statistic features of dimension
% [data-points x channels] The statistics are created for the data-points 
% of each channel and trial. Following statistic features are created: 
% min, max, mean, median, standard-deviation, var, kurtosis, skewness, 
% percentile, entropy, slope
% output of data will be of format [number_of_selected_features x channels]
arguments
    data (:,:) double;
    statistic_parameters StatisticParameters;
    fs {mustBeNumeric};
    dim {mustBeNumeric};
end
selected_features = statistic_parameters.statisticFeatures;
[min_data,max_data,mean_data,median_data,...
    std_data,var_data,kurtosis_data,skewness_data,prctile_data,entropy_data,...
    spectral_entropy_data,slope_data] = deal([]);
for i=1:length(selected_features)
    if any(strcmp(selected_features,"min"))
        min_data = min(data,[],dim);
    elseif any(strcmp(selected_features,"max"))
        max_data = max(data,[],dim);
    elseif any(strcmp(selected_features,"mean"))
        mean_data = mean(data,dim);
    elseif any(strcmp(selected_features,"median"))
        median_data = median(data,dim);
    elseif any(strcmp(selected_features,"std"))
        % TODO: optimize parameter
        weight_scheme=0;
        std_data = std(data,weight_scheme,dim);
    elseif any(strcmp(selected_features,"var"))
        % TODO: optimize parameters
        weight = 0;
        var_data = var(data,weight,dim);
    elseif any(strcmp(selected_features,"kurtosis"))
        % TODO: optimize parameters
        flag = 1;
        kurtosis_data = kurtosis(data,flag,dim);
    elseif any(strcmp(selected_features,"skewness"))
        % TODO: optimize parameters
        flag = 1;
        skewness_data = skewness(data,flag,dim);
    elseif any(strcmp(selected_features,"prctile"))
        % TODO: optimize parameter
        percentile = 50;
        prctile_data = prctile(data,percentile,dim);
    elseif any(strcmp(selected_features,"entropy"))
        entropy_data = approximateEntropy(data,[],dim);
    elseif any(strcmp(selected_features, "spectral-entropy"))
        [~,channels] = size(data);
        spectral_entropy_data = nan(1,channels);
        for c=1:channels
            % TODO: think about the median of entropy values ...
            spectral_entropy_data(1,c) = median(pentropy(data(:,c),fs));
        end
    elseif any(strcmp(selected_features, "slope"))
        slope_data = slope(data,dim);
    end
    selected_features(i) = nan;
end
statistic_features=[min_data,max_data,mean_data,median_data,...
    std_data,var_data,kurtosis_data,skewness_data,prctile_data,entropy_data,...
    spectral_entropy_data,slope_data];
end

