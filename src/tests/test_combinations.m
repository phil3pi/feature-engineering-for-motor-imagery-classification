% using following function for combination calculation:
% https://ch.mathworks.com/matlabcentral/fileexchange/10064-allcomb-varargin
statistics = {[], StatisticParameters("mean")}; % StatisticParameters("mean"), StatisticParameters("slope")
ar = {[], ArParameters("arcov", 4, false)};
psd = {[], PsdParameters(FrequencyBand.getAllBands, StatisticParameters("std"))};
arPsd = {[], ArPsdParameters("pyulear", 6, StatisticParameters("min"), FrequencyBand.getAllBands)};
waveletCorrelation = {[], WaveletCorrelationParameters()};
waveletVariance = {[], WaveletVarianceParameters()};

% ArParameters("arcov",4,false)
% PsdParameters(FrequencyBand.getAllBands,StatisticParameters("std"))
% ArPsdParameters("pyulear",6,StatisticParameters("min"),FrequencyBand.getAllBands)
% WaveletCorrelationParameters();
% WaveletVarianceParameters();
z = allcomb(statistics, ar, psd, arPsd, waveletCorrelation, waveletVariance);

deleted_lines = 0;

for i = 1:length(z)
    line = z(i - deleted_lines, :);
    count = 0;

    for j = 1:length(line)

        if ~isempty(line{j})
            count = count + 1;
        end

    end

    if count < 2
        z(i - deleted_lines, :) = [];
        deleted_lines = deleted_lines + 1;
    end

end

z2 = get_parameters_combinations
