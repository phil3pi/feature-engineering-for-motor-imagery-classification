classdef ExtractorParameterInterface
    %EXTRACTORPARAMETERS Summary of this class goes here
    %   Detailed explanation goes here
    methods (Abstract)
        getPermutations(obj);
        toString(obj);
    end
end

