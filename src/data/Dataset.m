classdef Dataset < handle
    %DATASET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        patient_id {mustBeNumeric};
        eeg;
        laball;
        channels {mustBeNumeric};
        N {mustBeNumeric};
        trials {mustBeNumeric};
    end
    properties (Constant)
        fs = 250; % sampling rate
    end
    properties (Access = private)
        artifactsall;
        artifacts;
    end
    
    methods
        function obj = Dataset(patient_id)
            %DATASET Construct an instance of this class
            %   load the dataset of the specified patient_id
            obj.patient_id = patient_id;
            data = load(sprintf('../dataset/Training Data/DATAall_cleaneog_A0%dT_Fs250',obj.patient_id));
            obj.eeg = data.eeg;
            obj.artifactsall = data.artifactsall;
            obj.laball = data.laball;
        end

        function remove_artifacts(obj)
            % Remove artifactual trials
            obj.artifacts=find(obj.artifactsall==1);
            obj.eeg(:,:,obj.artifacts)=[];
            obj.laball(obj.artifacts)=[];
            [obj.channels,obj.N,obj.trials]=size(obj.eeg);
        end
        
        function remove_outliers(obj)

            % TODO: implement this one

            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
%             outliers=isoutlier(obj.eeg(1,:,:),"quartiles",2);
%             outlier_indexes=find(outliers==1);
%             number_of_outliers=length(outlier_indexes);
%             fprintf('Number of outliers detected: %d.\n', number_of_outliers);
%             
%             eeg_preprocessed=nan(obj.channels,obj.N,obj.trials);
%             disp("Preprocessing channel: ")
%             for c=1:obj.channels
%                 fprintf('%d, ',c);
%                 eeg_preprocessed(c,:,:)=filloutliers(obj.eeg(c,:,:),"linear","quartiles");
%             end
        end
    end
end

