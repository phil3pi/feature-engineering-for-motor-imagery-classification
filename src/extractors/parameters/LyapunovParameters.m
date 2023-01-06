classdef LyapunovParameters < ExtractorParameterInterface
    %LYAPUNOVPARAMETERS Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj = LyapunovParameters()
            %LYAPUNOVPARAMETERS Construct an instance of this class
            %   Detailed explanation goes here
            obj.name = "lyapunov";
        end
        
        function name = toString(obj)
            %TOSTRING Converts the object into a string based on its
            %parameters
            name = sprintf("%s",obj.name);
        end
    end
end

