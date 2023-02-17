function parameters_combination_list = get_parameters_combinations()
    %PERMUTE_PARAMETERS get all possible feature extraction parameter
    % combinations
    % using following function for combination calculation:
    % https://ch.mathworks.com/matlabcentral/fileexchange/10064-allcomb-varargin
    statistics = {[], {StatisticParameters("mean"), 50}}; % add additional statistic measure here
    ar = {[], {ArParameters("arcov", 4, false), 250}};
    psd = {[], {PsdParameters(FrequencyBand.getAllBands, StatisticParameters("std")), 250}};
    arPsd = {[], {ArPsdParameters("pyulear", 6, StatisticParameters("min"), FrequencyBand.getAllBands), 250}};
    waveletVariance = {[], {WaveletVarianceParameters(), 50}};
    waveletCorrelation = {[], {WaveletCorrelationParameters(), 50}};
    parameters_combination_list = allcomb(statistics, ar, psd, arPsd, waveletVariance, waveletCorrelation);

    deleted_lines = 0;

    for i = 1:length(parameters_combination_list)
        line = parameters_combination_list(i - deleted_lines, :);
        count_non_zero = 0;

        for j = 1:length(line)

            if ~isempty(line{j})
                count_non_zero = count_non_zero + 1;
            end

        end

        if count_non_zero < 2
            parameters_combination_list(i - deleted_lines, :) = [];
            deleted_lines = deleted_lines + 1;
        end

    end

end
