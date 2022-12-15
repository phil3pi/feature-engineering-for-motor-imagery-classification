function [statistic_features] = statistic_extractor_2d(data,selected_features,fs)
% Extracts statistic features of dimension[data-points x channels]
%   The statistics are created for the data-points of each channel and
%   trial. Following statistic features are created: min, max, mean,
%   median, standard-deviation, kurtosis, skewness, percentile, entropy
[min_data,max_data,mean_data,median_data,...
    std_data,kurtosis_data,skewness_data,prctile_data,entropy_data,...
    spectral_entropy_data,slope_data] = deal([]);
for i=1:length(selected_features)
    if any(strcmp(selected_features,"min"))
        min_data = min(data,[],1);
    elseif any(strcmp(selected_features,"max"))
        max_data = max(data,[],1);
    elseif any(strcmp(selected_features,"mean"))
        mean_data = mean(data);
    elseif any(strcmp(selected_features,"median"))
        median_data = median(data);
    elseif any(strcmp(selected_features,"std"))
        % TODO: optimize parameter
        weight_scheme=0;
        std_data = std(data,weight_scheme);
    elseif any(strcmp(selected_features,"kurtosis"))
        kurtosis_data = kurtosis(data);
    elseif any(strcmp(selected_features,"skewness"))
        skewness_data = skewness(data);
    elseif any(strcmp(selected_features,"prctile"))
        % TODO: optimize parameter
        percentile=50;
        prctile_data = prctile(data,percentile);
    elseif any(strcmp(selected_features,"entropy"))
        entropy_data = approximateEntropy(data(:));
    elseif any(strcmp(selected_features, "spectral-entropy"))
        % TODO: think about the median of entropy values ...
        spectral_entropy_data = median(pentropy(data(:),fs));
    elseif any(strcmp(selected_features, "slope"))
        data_points = length(data);
        assert(data_points > 1, "In order to calculate the slop at least 2 data-points are needed.");
        slope_data = (data(data_points)-data(1)) / (data_points - 1);
    end
    selected_features(i) = nan;
end
statistic_features=[min_data,max_data,mean_data,median_data,...
    std_data,kurtosis_data,skewness_data,prctile_data,entropy_data,...
    spectral_entropy_data,slope_data];
end

