function [accuracy, accuracy_chance, kappa, kappa_chance, model] = get_best_classifier_window(data, window_size, trained_window)
    %TRAIN_CLASSIFIER Summary of this function goes here
    %   Detailed explanation goes here
    arguments
        data Dataset;
        window_size {mustBeNumeric};
        trained_window {mustBeNumeric};
    end

    kfolds = 10;
    rng('default') % set predefined random state for making results comparable
    % performance measures
    nn = window_size + 1:window_size:data.N;

    accuracy = nan(length(nn), kfolds);
    accuracy_chance = nan(length(nn), kfolds);
    kappa = nan(length(nn), kfolds);
    kappa_chance = nan(length(nn), kfolds);

    cv_indixes = crossvalind('kfold', data.laball, kfolds);

    tStart = tic;

    for kf = 1:kfolds
        train_indices = find(cv_indixes ~= kf);
        test_indices = find(cv_indixes == kf);
    
        % Pre-allocate a buffered matrix of all window sizes.
        % This reduces the memory overhead of parfor if the thread size
        % continues to increase. Without pre-allocation each thread would need
        % to copy the complete eeg dataset
        train_data_nn = nan(length(nn), data.channels, window_size + 1, length(train_indices));
        test_data_nn = nan(length(nn), data.channels, window_size + 1, length(test_indices));
    
        y_train_nn = nan(length(nn), length(train_indices));
        y_test_nn = nan(length(nn), length(test_indices));
    
        for n = 1:length(nn)
    
            train_data_nn(n, :, :, :) = data.eeg(:, nn(n) - window_size:nn(n), train_indices);
            test_data_nn(n, :, :, :) = data.eeg(:, nn(n) - window_size:nn(n), test_indices);

            y_train_nn(n, :) = data.laball(train_indices);
            y_test_nn(n, :) = data.laball(test_indices);
        end
    
        fs = data.fs;
    
        train_data = squeeze(train_data_nn(trained_window, :, :, :));
        x_train_temp = FeatureExtractor.waveletVariance(train_data);
        x_train_temp = permute(x_train_temp, [3 1 2]);
        x_train = x_train_temp(:, :);
        train_data = squeeze(train_data_nn(trained_window, :, :, :));
        x_train_temp = FeatureExtractor.statistic(train_data, fs, StatisticParameters("mean"));
        x_train_temp = permute(x_train_temp, [3 1 2]);
        x_train = cat(2,x_train,x_train_temp(:, :));
    
        y_train = y_train_nn(trained_window, :);
    
        [model] = lda_train(x_train, y_train);
    
        parfor n = 1:length(nn)
            disp([kf, n]);
    
            test_data = squeeze(test_data_nn(n, :, :, :));
            x_test_temp = FeatureExtractor.waveletVariance(test_data);
            x_test_temp = permute(x_test_temp, [3 1 2]);
            x_test = x_test_temp(:, :);
            test_data = squeeze(test_data_nn(n, :, :, :));
            x_test_temp = FeatureExtractor.statistic(test_data, fs, StatisticParameters("mean"));
            x_test_temp = permute(x_test_temp, [3 1 2]);
            x_test = cat(2, x_test, x_test_temp(:, :)); 
    
            y_test = y_test_nn(n, :);
    
            [y_pred] = lda_predict(model, x_test); % Test on testing data
    
            c_matrix = confusionmat(y_test, y_pred);
            [accuracy(n, kf), kappa(n, kf)] = stats_of_measure(c_matrix); % Estimate accuracy
    
            % Get chance level by permuting randomly the input matrix x_test
            permuted_inds = randsample(length(y_test), length(y_test));
            x_test_perm = x_test(permuted_inds, :);
    
            [y_pred] = lda_predict(model, x_test_perm); %Test on testing data
            
            c_matrix = confusionmat(y_test, y_pred); %Compute confusion matrix
            [accuracy_chance(n, kf), kappa_chance(n, kf)] = stats_of_measure(c_matrix); %Estimate accuracy
        end
    
        tEnd = toc(tStart);
        fprintf('Elapsed time for training and testing model is %0.4f seconds.\n', tEnd);
    end
end
