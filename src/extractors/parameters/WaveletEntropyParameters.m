classdef WaveletEntropyParameters < ExtractorParameterInterface
    %WAVELETENTROPYPARAMETERS contains wavelet entropy parameters

    properties
        entropy_type string
        transform_type string
        level int8
    end

    properties(Access = private,Constant)
            entropy_types string = ["Shannon" "Renyi" "Tsallis"];
            transform_types string = ["modwt" "dwt" "dwpt" "modwpt"];
            levels {mustBeNumeric} = [4 5 6];
    end

    methods
        function obj = WaveletEntropyParameters(entropy_type,transform_type,level)
            %WAVELETENTROPYPARAMETERS Construct an instance of this class
            %   Detailed explanation goes here
            obj.entropy_type = entropy_type;
            obj.transform_type = transform_type;
            obj.level = level;
            obj.name = "waveletEntropy";
        end

        function name = toString(obj)
            %TOSTRING Converts the object into a string based on its
            %parameters
            name = sprintf("%s-%s-%s-%s",obj.name,obj.entropy_type,obj.transform_type,num2str(obj.level));
        end
    end

    methods(Static)
        function combinations = getPermutations()
            %GETPERMUTATIONS Calculates the permutations of the parameters
            %   All possible combinations are calculated and returned
            [ca, cb, cc] = ndgrid(WaveletEntropyParameters.entropy_types,WaveletEntropyParameters.transform_types, WaveletEntropyParameters.levels);
            temp_combinations = [ca(:), cb(:), cc(:)];
            combinations=WaveletEntropyParameters.empty(0,length(temp_combinations));
            for i=1:length(temp_combinations)
                combination = temp_combinations(i,:);
                combinations(i) = WaveletEntropyParameters(combination(1),combination(2),str2double(combination(3)));
            end
        end
    end
end