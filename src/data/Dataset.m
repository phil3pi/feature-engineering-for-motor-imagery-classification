classdef Dataset < handle
    %DATASET Base class of the eeg data
    %   Loads data from the original dataset, remove artifacts and outliers

    properties
        patient_id {mustBeNumeric};
        eeg;
        laball;
        channels {mustBeNumeric};
        N {mustBeNumeric};
        trials {mustBeNumeric};
        fs {mustBeNumeric} = 250; % sampling rate
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

        function removeArtifacts(obj)
            %REMOVEARTIFACTS Remove artifactual trials
            obj.artifacts=find(obj.artifactsall==1);
            obj.eeg(:,:,obj.artifacts)=[];
            obj.laball(obj.artifacts)=[];
            [obj.channels,obj.N,obj.trials]=size(obj.eeg);
        end

        function resample(obj,desired_fs)
            %RESAMPLE Resamples with the given resampling frequency
            timeseries=obj.eeg(1,:,1);
            [p,q] = rat(desired_fs / obj.fs);
            new_n = 6*desired_fs;
            resampled_eeg = nan(obj.channels,new_n,obj.trials);

            for trial=1:obj.trials
                for channel=1:obj.channels
                    resampled_eeg(channel,:,trial) = resample(timeseries,p,q);
                end
            end
            obj.N = new_n;
            obj.fs = desired_fs;
            obj.eeg = resampled_eeg;
        end

        function removeOutliers(obj)
            %REMOVEOUTLIERS Remove outliers
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

