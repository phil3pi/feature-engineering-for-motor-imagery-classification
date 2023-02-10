classdef Dataset < handle
    %DATASET Base class of the eeg data
    %   Loads data from the original dataset, remove artifacts and outliers

    properties
        patient_id {mustBeNumeric};
        eeg (:, :, :) double;
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

        function obj = Dataset(patient_id,is_training_data)
            %DATASET Construct an instance of this class
            %   load the dataset of the specified patient_id
            obj.patient_id = patient_id;
            if is_training_data
                data = load(sprintf('../dataset/Training Data/DATAall_cleaneog_A0%dT_Fs250', obj.patient_id));
            else
                data = load(sprintf('../dataset/Evaluation Data/DATAall_cleaneog_A0%dE_Fs250', obj.patient_id));
            end
            obj.eeg = data.eeg;
            obj.artifactsall = data.artifactsall;
            obj.laball = data.laball;
        end

        function removeArtifacts(obj)
            %REMOVEARTIFACTS Remove artifactual trials
            obj.artifacts = find(obj.artifactsall == 1);
            obj.eeg(:, :, obj.artifacts) = [];
            obj.laball(obj.artifacts) = [];
            [obj.channels, obj.N, obj.trials] = size(obj.eeg);
        end

        function resample(obj, desired_fs)
            %RESAMPLE Resamples with the given resampling frequency
            if desired_fs == obj.fs
                return;
            end

            [p, q] = rat(desired_fs / obj.fs);
            new_n = 6 * desired_fs;
            resampled_eeg = nan(obj.channels, new_n, obj.trials);

            for trial = 1:obj.trials

                for channel = 1:obj.channels
                    timeseries = obj.eeg(channel, :, trial);
                    resampled_eeg(channel, :, trial) = resample(timeseries, p, q);
                end

            end

            obj.N = new_n;
            obj.fs = desired_fs;
            obj.eeg = resampled_eeg;
        end

        function removeOutliers(obj, find_method, fill_method)
            %REMOVEOUTLIERS Detect outliers and interpolate them
            eeg_preprocessed = nan(obj.channels, obj.N, obj.trials);
            number_of_outliers = 0;

            for channel = 1:obj.channels
                outliers = isoutlier(obj.eeg(channel, :, :), find_method);
                outlier_indexes = find(outliers == 1);
                number_of_outliers = length(outlier_indexes);
                eeg_preprocessed(channel, :, :) = filloutliers(obj.eeg(channel, :, :), fill_method, find_method);
                %figure(1);
                %plot(1:1500, obj.eeg(channel,:,1));
                %hold on;
                %plot(1:1500, eeg_preprocessed(channel,:,1));
                %hold off;
            end

            fprintf('%d outliers detected and interpolated.\n', number_of_outliers);
            obj.eeg = eeg_preprocessed;
        end

    end

end
