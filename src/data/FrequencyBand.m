classdef FrequencyBand < handle
    %FREQUENCYBAND Provides important information about the frequency band

    properties
        name string
        min {mustBeNumeric}
        max {mustBeNumeric}
    end

    methods
        function obj = FrequencyBand(name,min,max)
            %FREQUENCYBAND Construct an instance of this class
            %   set the properties of this class
            obj.name = name;
            obj.min = min;
            obj.max = max;
        end
    end

    methods (Static)
        function allBands = getAllBands()
            %GETFREQUENCYBANDS Returns all important frequency bands for
            % eeg signal processing
            allBands = [
                FrequencyBand('delta',0.1,3.5),...
                FrequencyBand('theta',4,7.5),...
                FrequencyBand('alpha',8,12.5),...
                FrequencyBand('beta',13,29.5),...
                FrequencyBand('gamma',30,60),...
                FrequencyBand('high-gamma',60.5,100),...
                FrequencyBand('broad',0.1,100)];
        end

        function selectedBands = getSpecificBands(bandNames)
            %GETSPECIFICBANDS Returns the frequency band objects selected
            % by the function argument
            allBands=FrequencyBand.getAllBands;
            selectedBands=FrequencyBand.empty(0,length(bandNames));
            for i=1:length(bandNames)
                selectedBands(i)=findobj(allBands,'name',bandNames(i));
            end
        end
    end
end