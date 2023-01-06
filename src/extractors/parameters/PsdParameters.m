classdef PsdParameters < ExtractorParameterInterface
    %PSDPARAMETERS Summary of this class goes here
    %   Detailed explanation goes here

    properties
        frequencyBands (1, :) FrequencyBand;
        statisticParameters StatisticParameters;
    end

    methods

        function obj = PsdParameters(frequencyBands, statisticParameters)
            %PSDPARAMETERS Construct an instance of this class
            %   Detailed explanation goes here
            obj.frequencyBands = frequencyBands;
            obj.statisticParameters = statisticParameters;
            obj.name = "psd";
        end

        function name = toString(obj)
            %TOSTRING Converts the object into a string based on its
            %parameters
            % TODO: add frequency bands later
            name = sprintf("%s-%s", obj.name, obj.statisticParameters.toString);
        end

    end

    methods (Static)

        function combinations = getPermutations()
            %GETPERMUTATIONS Calculates the permutations of the parameters
            %   All possible combinations are calculated and returned
            statistics = StatisticParameters.getPermutations;
            bands = FrequencyBand.getAllBands;
            combinations = PsdParameters.empty(0, length(statistics));

            for i = 1:length(statistics)
                statistic = statistics(i);
                combinations(i) = PsdParameters(bands, statistic);
            end

        end

    end

end
