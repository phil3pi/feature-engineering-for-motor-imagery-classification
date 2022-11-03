function [statistic_features] = statistic_extractor(data)
% Extracts statistic features of dimension[channels x data-points x trials]
%   The statistics are created for the data-points of each channel and
%   trial. Following statistic features are created: min, max, mean,
%   median, standard-deviation, kurtosis, skewness, percentile, entropy
min_data=min(data(:,:,:),[],2);
max_data=max(data(:,:,:),[],2);
mean_data=mean(data(:,:,:),2);
median_data=median(data(:,:,:),2);
% TODO: checkout different weighting schemes (0 is default)
weight_scheme=0;
std_data=std(data(:,:,:),weight_scheme,2);
kurtosis_data=kurtosis(data(:,:,:),1,2);
skewness_data=skewness(data(:,:,:),1,2);

% TODO: think about the moment calculation, something weird is going on
% there
% moment_order=4;
% moment_data=moment(data(:,:,:),moment_order,2);

rms_data=rms(data(:,:,:),2); % root-mean-square value
% TODO: play around with the value
percentile=50;
prctile_data=prctile(data(:,:,:),percentile,2);

[channels,~,trials]=size(data);
entropy_data=nan(channels,1,trials);
for t=1:1:trials
    for c=1:1:channels
        % TODO: check if calculation is correct
        % [~,lag]=phaseSpaceReconstruction(data(c,:,t),[]);
        entropy_data(c,1,t)=approximateEntropy(data(c,:,t));
    end
end
statistic_features=[max_data,min_data,mean_data,median_data,std_data,skewness_data,kurtosis_data,rms_data,prctile_data,entropy_data];
end

