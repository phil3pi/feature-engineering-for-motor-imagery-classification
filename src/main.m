% clear workspace, functionspace and figures
close all; clear all;

addpath('classifiers/');
addpath('classifiers/lda');
addpath('classifiers/train-classifier/');
addpath('extractors/');
addpath('extractors/parameters/')
addpath('utils/');
addpath('tests/');
addpath('data/');

setup_multithreading(8);

number_of_subjects = 9;

accuracy = nan(14, number_of_subjects);
accuracy_chance = nan(14, number_of_subjects);
kappa = nan(14, number_of_subjects);
kappa_chance = nan(14, number_of_subjects);
model = cell(1,number_of_subjects);
shapley_object = cell(1,number_of_subjects);

max_accuracy = nan(number_of_subjects, 1);
max_kappa = nan(number_of_subjects, 1);

% windows calculated with 
% best_windows = get_classifier_windows;
best_windows = [8; 9; 8; 7; 7; 7; 9; 8; 8];

for subject_id=1:number_of_subjects
    
    data = Dataset(subject_id,true);
    data.removeArtifacts();
    data.resample(50);
    
    evaluation_data = Dataset(subject_id,false);
    evaluation_data.removeArtifacts();
    evaluation_data.resample(50);
    
    filename = sprintf('subject-%d-final-classifier',subject_id);
    
    try
        [accuracy(:,subject_id), accuracy_chance(:,subject_id), kappa(:,subject_id), kappa_chance(:,subject_id), model{subject_id}, shapley_object{subject_id}] = final_train_classifier(data, evaluation_data, 20, best_windows(subject_id));
        max_accuracy(subject_id) = max(accuracy(:,subject_id));
        max_kappa(subject_id) = max(kappa(:,subject_id));
        print_measures(data.N, data.fs, 20, accuracy(:,subject_id), accuracy_chance(:,subject_id), kappa(:,subject_id), kappa_chance(:,subject_id), filename + ".fig");
    catch ME
        fileID = fopen("0-" + filename + ".txt", 'w');
        fprintf(fileID, "%s\n", ME.identifier);
        fprintf(fileID, ME.message);
        disp(ME.message);
        fclose(fileID);
    end
end
mean_acc = mean(max_accuracy) * 100;
mean_kappa = mean(max_kappa);
classification_results = {accuracy; accuracy_chance; kappa; kappa_chance; mean_acc; mean_kappa};
writecell(classification_results,"classification-results.csv");

fprintf('average accuracy: %.2f%%\n', mean_acc);
fprintf('average kappa:    %.4f\n', mean_kappa);