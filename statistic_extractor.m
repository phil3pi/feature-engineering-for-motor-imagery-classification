function [all,max_data,min_data,kurtosis_data,skewness_data] = statistic_extractor(data)
%STATISTIC_EXTRACTOR Summary of this function goes here
%   Detailed explanation goes here
kurtosis_data=kurtosis(data(:,:,:),1,2);
skewness_data=skewness(data(:,:,:),1,2);
min_data=min(data(:,:,:),[],2);
max_data=max(data(:,:,:),[],2);
all=[max_data,min_data,skewness_data,kurtosis_data];
end

