function [accuracy, accuracy_chance, kappa, kappa_chance] = multiple_features_train_classifier(data, data_50, window_size_250, window_size_50, extractor_parameters, model_type)
    %MULTIPLE_FEATURES_TRAIN_CLASSIFIER Summary of this function goes here
    %   Detailed explanation goes here
    arguments
        data Dataset;
        data_50 Dataset;
        window_size_250 {mustBeNumeric};
        window_size_50 {mustBeNumeric};
        extractor_parameters (1, :) cell;
        model_type string;
    end

    kfolds = 10;
    rng('default') % set predefined random state for making results comparable
    cv_indixes = crossvalind('kfold', data.laball, kfolds);
    % performance measures
    nn_250 = window_size_250 + 1:window_size_250:data.N;
    nn_50 = window_size_50 + 1:window_size_50:data_50.N;

    assert(length(nn_250) == length(nn_50), "Length of nn_250 is not equal to nn_50, should never happen!");

    accuracy = nan(length(nn_250), kfolds);
    accuracy_chance = nan(length(nn_250), kfolds);
    kappa = nan(length(nn_250), kfolds);
    kappa_chance = nan(length(nn_250), kfolds);

    tStart = tic;

    for kf = 1:kfolds
        test_indices = find(cv_indixes == kf);
        train_indices = find(cv_indixes ~= kf);

        % Pre-allocate a buffered matrix of all window sizes.
        % This reduces the memory overhead of parfor if the thread size
        % continues to increase. Without pre-allocation each thread would need
        % to copy the complete eeg dataset
        train_data_nn_250 = nan(length(nn_250), data.channels, window_size_250 + 1, length(train_indices));
        test_data_nn_250 = nan(length(nn_250), data.channels, window_size_250 + 1, length(test_indices));

        train_data_nn_50 = nan(length(nn_50), data_50.channels, window_size_50 + 1, length(train_indices));
        test_data_nn_50 = nan(length(nn_50), data_50.channels, window_size_50 + 1, length(test_indices));

        y_train_nn = nan(length(nn_250), length(train_indices));
        y_test_nn = nan(length(nn_250), length(test_indices));

        for n = 1:length(nn_250)
            train_data_nn_250(n, :, :, :) = data.eeg(:, nn_250(n) - window_size_250:nn_250(n), train_indices);
            test_data_nn_250(n, :, :, :) = data.eeg(:, nn_250(n) - window_size_250:nn_250(n), test_indices);

            train_data_nn_50(n, :, :, :) = data_50.eeg(:, nn_50(n) - window_size_50:nn_50(n), train_indices);
            test_data_nn_50(n, :, :, :) = data_50.eeg(:, nn_50(n) - window_size_50:nn_50(n), test_indices);

            y_train_nn(n, :) = data.laball(train_indices);
            y_test_nn(n, :) = data.laball(test_indices);
        end

        parfor n = 1:length(nn_250)
            disp([kf n])
            empty_training_vector = true;

            for i = 1:length(extractor_parameters)

                if isempty(extractor_parameters{i})
                    continue;
                end

                parameters = extractor_parameters{i}{1};
                fs = extractor_parameters{i}{2};

                if fs == 250
                    train_data = squeeze(train_data_nn_250(n, :, :, :));
                else
                    train_data = squeeze(train_data_nn_50(n, :, :, :));
                end

                switch parameters.name
                    case "psd"
                        train_data = FeatureExtractor.psd(train_data, fs, parameters);
                    case "waveletEntropy"
                        train_data = FeatureExtractor.waveletEntropy(train_data, parameters);
                    case "waveletVariance"
                        train_data = FeatureExtractor.waveletVariance(train_data);
                    case "waveletCorrelation"
                        train_data = FeatureExtractor.waveletCorrelation(train_data);
                    case "statistic"
                        train_data = FeatureExtractor.statistic(train_data, fs, parameters);
                    case "ar"
                        train_data = FeatureExtractor.ar(train_data, parameters);
                    case "arPsd"
                        train_data = FeatureExtractor.arPsd(train_data, fs, parameters);
                    case "lyapunov"
                        train_data = FeatureExtractor.lyapunovExponent(train_data, fs);
                    otherwise
                        error("Invalid extraction method. Only support: psd, waveletEntropy, waveletCorrelation, statistic, ar, arPsd, lyapunov.");
                end

                x_train_temp = permute(train_data, [3 1 2]); %Take win time points before the current time point up till the current time point (it's causal)

                if empty_training_vector
                    x_train = x_train_temp(:, :);
                    empty_training_vector = false;
                else
                    x_train = cat(2, x_train, x_train_temp(:, :)); % x_train is of dimension [number of training trials x number of features]
                end

            end

            empty_training_vector = true;

            for i = 1:length(extractor_parameters)

                if isempty(extractor_parameters{i})
                    continue;
                end

                parameters = extractor_parameters{i}{1};
                fs = extractor_parameters{i}{2};

                if fs == 250
                    test_data = squeeze(test_data_nn_250(n, :, :, :));
                else
                    test_data = squeeze(test_data_nn_50(n, :, :, :));
                end

                switch parameters.name
                    case "psd"
                        test_data = FeatureExtractor.psd(test_data, fs, parameters);
                    case "waveletEntropy"
                        test_data = FeatureExtractor.waveletEntropy(test_data, parameters);
                    case "waveletVariance"
                        test_data = FeatureExtractor.waveletVariance(test_data);
                    case "waveletCorrelation"
                        test_data = FeatureExtractor.waveletCorrelation(test_data);
                    case "statistic"
                        test_data = FeatureExtractor.statistic(test_data, fs, parameters);
                    case "ar"
                        test_data = FeatureExtractor.ar(test_data, parameters);
                    case "arPsd"
                        test_data = FeatureExtractor.arPsd(test_data, fs, parameters);
                    case "lyapunov"
                        test_data = FeatureExtractor.lyapunovExponent(test_data, fs);
                    otherwise
                        error("Invalid extraction method. Only support: psd, waveletEntropy, waveletCorrelation, statistic, ar, arPsd, lyapunov.");
                end

                x_test_temp = permute(test_data, [3 1 2]);

                if empty_training_vector
                    x_test = x_test_temp(:, :); % x_test is of dimension [number of testing trials x number of features]
                    empty_training_vector = false;
                else
                    x_test = cat(2, x_test, x_test_temp(:, :));
                end

            end

            y_test = y_test_nn(n, :);
            y_train = y_train_nn(n, :);

            % Train on training data
            switch model_type
                case "slda"
                    [model] = lda_train(x_train, y_train);
                case "svm"
                    [model] = fitcecoc(x_train, y_train);
                case "naive-bayes"
                    [model] = fitcnb(x_train, y_train);
                case "neural-network"
                    [model] = fitcnet(x_train, y_train);
                case "knn"
                    [model] = fitcknn(x_train, y_train);
                case "ensemble"
                    [model] = fitcensemble(x_train, y_train);
                otherwise
                    error("Invalid Model type, use one of these: slda, svm, naive-bayes, neural-network, knn, ensemble")
            end

            if model_type == "slda"
                [y_pred] = lda_predict(model, x_test); % Test on testing data
            else
                [y_pred] = predict(model, x_test); % Test on testing data
            end

            c_matrix = confusionmat(y_test, y_pred);
            [accuracy(n, kf), kappa(n, kf)] = stats_of_measure(c_matrix); % Estimate accuracy

            % Get chance level by permuting randomly the input matrix x_test
            permuted_inds = randsample(length(y_test), length(y_test));
            x_test_perm = x_test(permuted_inds, :);

            if model_type == "slda"
                [y_pred] = lda_predict(model, x_test_perm); %Test on testing data
            else
                [y_pred] = predict(model, x_test_perm); %Test on testing data
            end

            c_matrix = confusionmat(y_test, y_pred); %Compute confusion matrix
            [accuracy_chance(n, kf), kappa_chance(n, kf)] = stats_of_measure(c_matrix); %Estimate accuracy

        end

    end

    tEnd = toc(tStart);
    fprintf('Elapsed time for training and testing model is %0.4f seconds.\n', tEnd);
end
