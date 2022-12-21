classdef WaveletEntropyParameters < ExtractorParameterInterface
    %WAVELETENTROPYPARAMETERS contains wavelet entropy parameters

    properties (Constant)
        entropy_type = ["Shannon" "Renyi" "Tsallis"]
        transform_type = ["modwt" "dwt" "dwpt" "modwpt"]
        level = ["4" "5" "6"]
    end

    methods
        function obj = WaveletEntropyParameters()
            %WAVELETENTROPYPARAMETERS Construct an instance of this class
            %   Detailed explanation goes here
        end

        function combinations = getPermutations(obj)
            %GETPERMUTATIONS Calculates the permutations of the parameters
            %   All possible combinations are calculated and returned
            [ca, cb, cc] = ndgrid(obj.entropy_type, obj.transform_type, obj.level);
            combinations = [ca(:), cb(:), cc(:)];
        end
    end
end