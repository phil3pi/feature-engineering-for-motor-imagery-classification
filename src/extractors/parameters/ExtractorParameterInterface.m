classdef ExtractorParameterInterface
    %EXTRACTORPARAMETERS Summary of this class goes here
    %   Detailed explanation goes here
    properties
        name string;
    end

    methods (Abstract)
        toString(obj);
    end
end

