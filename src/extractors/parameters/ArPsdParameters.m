classdef ArPsdParameters < ExtractorParameterInterface
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        method string;
        order {mustBeNumeric};
        frequencyBands (1,:) FrequencyBand;
        statistic StatisticParameters;
    end

    properties(Access = private,Constant)
            method_list (1,:) string = ["pcov" "pmcov" "pburg" "pyulear"];
            order_list (1,:) {mustBeNumeric} = [3 4 5 6];
    end
    
    methods
        function obj = ArPsdParameters(method,order,statistic,frequencyBands)
            %ARPSDPARAMETERS Construct an instance of this class
            %   Detailed explanation goes here
            obj.method = method;
            obj.order = order;
            obj.statistic = statistic;
            obj.frequencyBands = frequencyBands;
            obj.name = "arPsd";
        end
        
        function name = toString(obj)
            %TOSTRING Converts the object into a string based on its
            %parameters
            name = sprintf("%s-%s-%s-%s",obj.name,obj.method,num2str(obj.order),obj.statistic.toString);
        end
    end

    methods(Static)
        function combinations = getPermutations()
            %GETPERMUTATIONS Calculates the permutations of the parameters
            %   All possible combinations are calculated and returned
            [ca, cb] = ndgrid(ArPsdParameters.method_list,ArPsdParameters.order_list);
            statistic_permutations = StatisticParameters.getPermutations;
            temp_combinations = [ca(:), cb(:)];
            combinations=ArPsdParameters.empty(0,length(temp_combinations) + length(statistic_permutations));
            counter = 1;
            for i=1:length(temp_combinations)
                combination = temp_combinations(i,:);
                for statistic=statistic_permutations
                    combinations(counter) = ArPsdParameters(combination(1),str2double(combination(2)),statistic,FrequencyBand.getAllBands);
                    counter = counter + 1;
                end
            end
        end
    end
end

