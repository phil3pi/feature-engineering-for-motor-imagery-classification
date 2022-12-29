classdef StatisticParameters < ExtractorParameterInterface
    %STATISTICPARAMETERS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        statisticFeatures (1,:) string;
    end

    properties(Access=private,Constant)
        allStatisticFeatures = ["min","max","mean","median","std","var",...
            "kurtosis","skewness","prctile","entropy","spectral-entropy"...
            "slope"]
    end
    
    methods
        function obj = StatisticParameters(statisticFeatures)
            %STATISTICPARAMETERS Construct an instance of this class
            %   Detailed explanation goes here
            obj.name = "statistic";
            obj.statisticFeatures = statisticFeatures;
        end
        
        function name = toString(obj)
            %TOSTRING Converts the object into a string based on its
            %parameters
            name = sprintf("%s-%s",obj.name,strjoin(obj.statisticFeatures,"-"));
        end
    end

    methods(Static)
        function combinations = getPermutations()
            %GETPERMUTATIONS Calculates the permutations of the parameters
            %   All possible combinations are calculated and returned
            statisticFeatures = StatisticParameters.allStatisticFeatures;
            combinations = StatisticParameters.empty(0,length(statisticFeatures));
            for i=1:length(statisticFeatures)
                combinations(i) = StatisticParameters(statisticFeatures(i));
            end
        end
    end
end

