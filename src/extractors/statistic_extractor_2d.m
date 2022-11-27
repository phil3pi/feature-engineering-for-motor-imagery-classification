function [statistic_features] = statistic_extractor_2d(data,selected_features,fs)
    % Extracts statistic features of dimension[data-points x channels]
    %   The statistics are created for the data-points of each channel and
    %   trial. Following statistic features are created: min, max, mean,
    %   median, standard-deviation, kurtosis, skewness, percentile, entropy
    min_data=inline_if(any(strcmp(selected_features,"min")),min(data,[],1),[]);
    max_data=inline_if(any(strcmp(selected_features,"max")),max(data,[],1),[]);
    mean_data=inline_if(any(strcmp(selected_features,"mean")),mean(data),[]);
    median_data=inline_if(any(strcmp(selected_features,"median")),median(data),[]);
    % TODO: checkout different weighting schemes (0 is default)
    weight_scheme=0;
    std_data=inline_if(any(strcmp(selected_features,"std")),std(data,weight_scheme),[]);
    kurtosis_data=inline_if(any(strcmp(selected_features,"kurtosis")),kurtosis(data),[]);
    skewness_data=inline_if(any(strcmp(selected_features,"skewness")),skewness(data),[]);
    
    percentile=50;
    prctile_data=inline_if(any(strcmp(selected_features,"prctile")),prctile(data,percentile),[]);
    
    entropy_data = inline_if(any(strcmp(selected_features,"entropy")),approximateEntropy(data(:)),[]);
    spectral_entropy_data = inline_if(any(strcmp(selected_features, "spectral-entropy")),median(pentropy(data(:),fs)),[]);
    
    % TODO: add other wanted features here
    statistic_features=[min_data,max_data,mean_data,median_data,...
        std_data,kurtosis_data,skewness_data,prctile_data,entropy_data,...
        spectral_entropy_data];
end

