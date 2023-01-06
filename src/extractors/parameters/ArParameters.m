classdef ArParameters < ExtractorParameterInterface
    %ARPARAMETERS Summary of this class goes here
    %   Detailed explanation goes here

    properties
        method string;
        order {mustBeNumeric};
        use_white_noise {logical};
    end

    properties (Access = private, Constant)
        method_list (1, :) string = ["arcov" "aryule" "arburg" "armcov"];
        order_list (1, :) {mustBeNumeric} = [3 4 5 6];
        use_white_noise_list (1, 2) {logical} = [false, true];
    end

    methods

        function obj = ArParameters(method, order, use_white_noise)
            %ARPARAMETERS Construct an instance of this class
            %   Detailed explanation goes here
            obj.method = method;
            obj.order = order;
            obj.use_white_noise = use_white_noise;
            obj.name = "ar";
        end

        function name = toString(obj)
            %TOSTRING Converts the object into a string based on its
            %parameters
            name = sprintf("%s-%s-%s-%s", obj.name, obj.method, num2str(obj.order), string(obj.use_white_noise));
        end

    end

    methods (Static)

        function combinations = getPermutations()
            %GETPERMUTATIONS Calculates the permutations of the parameters
            %   All possible combinations are calculated and returned
            [ca, cb, cc] = ndgrid(ArParameters.method_list, ArParameters.order_list, ArParameters.use_white_noise_list);
            temp_combinations = [ca(:), cb(:), cc(:)];
            combinations = ArParameters.empty(0, length(temp_combinations));

            for i = 1:length(temp_combinations)
                combination = temp_combinations(i, :);
                combinations(i) = ArParameters(combination(1), str2double(combination(2)), strcmp(combination(3), "true"));
            end

        end

    end

end
