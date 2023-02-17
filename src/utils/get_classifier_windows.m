function best_window = get_classifier_windows()
    %GET_CLASSIFIER_WINDOWS Calculates the best window for each subject where the
    % final classifier should be trained on
    number_of_subjects = 9;

    best_window = nan(number_of_subjects, 1);

    for subject_id = 1:number_of_subjects

        data = Dataset(subject_id, true);
        data.removeArtifacts();
        data.resample(50);

        % only test windows that are interesting after init-phase (where
        % imagery occurs
        min_window_index = 5; % 2 sec
        max_window_index = 10; % 4 sec
        max_accuracy = nan(max_window_index - min_window_index + 1, 1);

        for window = min_window_index:max_window_index
            disp([subject_id, window]);
            [acc, ~, ~, ~] = get_best_classifier_window(data, 20, window);

            max_accuracy(window - min_window_index + 1) = max(mean(acc, 2));

            disp("t\n");
        end

        [max_acc, max_acc_index] = max(max_accuracy);
        best_window(subject_id) = min_window_index - 1 + max_acc_index;
        fprintf('Max-Accuracy of %0.4f%% at %dth window.\n', 100 * max_acc, best_window(subject_id));
    end

end
