function [accuracy, accuracy_chance, kappa, kappa_chance, model, explainer] = final_train_classifier(data, evaluation_data, window_size, trained_window)
    %FINAL_TRAIN_CLASSIFIER Summary of this function goes here
    %   Detailed explanation goes here
    arguments
        data Dataset;
        evaluation_data Dataset;
        window_size {mustBeNumeric};
        trained_window {mustBeNumeric};
    end

    rng('default') % set predefined random state for making results comparable
    % performance measures
    nn = window_size + 1:window_size:data.N;

    accuracy = nan(length(nn), 1);
    accuracy_chance = nan(length(nn), 1);
    kappa = nan(length(nn), 1);
    kappa_chance = nan(length(nn), 1);

    tStart = tic;

    [~, ~, training_trials] = size(data.eeg);
    [~, ~, evaluation_trials] = size(evaluation_data.eeg);

    % Pre-allocate a buffered matrix of all window sizes.
    % This reduces the memory overhead of parfor if the thread size
    % continues to increase. Without pre-allocation each thread would need
    % to copy the complete eeg dataset
    train_data_nn = nan(length(nn), data.channels, window_size + 1, training_trials);
    test_data_nn = nan(length(nn), data.channels, window_size + 1, evaluation_trials);

    y_train_nn = nan(length(nn), training_trials);
    y_test_nn = nan(length(nn), evaluation_trials);

    for n = 1:length(nn)
        train_data_nn(n, :, :, :) = data.eeg(:, nn(n) - window_size:nn(n), :);
        test_data_nn(n, :, :, :) = evaluation_data.eeg(:, nn(n) - window_size:nn(n), :);

        y_train_nn(n, :) = data.laball;
        y_test_nn(n, :) = evaluation_data.laball;
    end

    fs = data.fs;

    train_data = squeeze(train_data_nn(trained_window, :, :, :));
    x_train_temp = FeatureExtractor.waveletVariance(train_data);
    x_train_temp = permute(x_train_temp, [3 1 2]);
    x_train = x_train_temp(:, :);
    train_data = squeeze(train_data_nn(trained_window, :, :, :));
    x_train_temp = FeatureExtractor.statistic(train_data, fs, StatisticParameters("mean"));
    x_train_temp = permute(x_train_temp, [3 1 2]);
    x_train = cat(2, x_train, x_train_temp(:, :));

    y_train = y_train_nn(trained_window, :);

    [model] = lda_train(x_train, y_train);

    % calculate shapley values
    merged_data = cat(2, x_train, permute(y_train, [2 1]));
    tbl = array2table(merged_data);
    blackbox = fitcecoc(tbl, 'merged_data67', ...
        'PredictorNames', tbl.Properties.VariableNames(1:66), ...
        'ClassNames', [1 2 3 4]);
    queryPoint = tbl(end, :);

    explainer = shapley(blackbox, 'QueryPoint', queryPoint);

    %explainer.ShapleyValues
    %plot(explainer);

    parfor n = 1:length(nn)
        disp([trained_window, n]);

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
        [accuracy(n), kappa(n)] = stats_of_measure(c_matrix); % Estimate accuracy

        % Get chance level by permuting randomly the input matrix x_test
        permuted_inds = randsample(length(y_test), length(y_test));
        x_test_perm = x_test(permuted_inds, :);

        [y_pred] = lda_predict(model, x_test_perm); %Test on testing data

        c_matrix = confusionmat(y_test, y_pred); %Compute confusion matrix
        [accuracy_chance(n), kappa_chance(n)] = stats_of_measure(c_matrix); %Estimate accuracy
    end

    tEnd = toc(tStart);
    fprintf('Elapsed time for training and testing model is %0.4f seconds.\n', tEnd);
end
