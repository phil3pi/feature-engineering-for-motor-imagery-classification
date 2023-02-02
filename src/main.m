% clear workspace, functionspace and figures
close all; clear all;

addpath('classifiers/');
addpath('classifiers/lda');
addpath('extractors/');
addpath('extractors/parameters/')
addpath('utils/');
addpath('tests/');
addpath('data/');

setup_multithreading(8);

data_250 = Dataset(1);
data_250.removeArtifacts();

data_50 = Dataset(1);
data_50.removeArtifacts();
data_50.resample(50);

parameter_list = get_parameters_combinations();
for i=2:length(parameter_list)
    parameter = parameter_list(i,1:6);
    filename = "combination";
    for j=1:length(parameter)
        if ~isempty(parameter{j})
            filename = filename + sprintf("-%s",parameter{j}.name);
        end
    end
    try
        [accuracy, accuracy_chance, kappa, kappa_chance] = fixed_train_classifier(data_250, 100, parameter);
        
        print_measures(data_250.N, data_250.fs, 100, accuracy, accuracy_chance, kappa, kappa_chance, filename + ".fig");
    catch ME
        fileID = fopen("0-" + filename + ".txt", 'w');
        fprintf(fileID, "%s\n", ME.identifier);
        fprintf(fileID, ME.message);
        disp(ME.message);
        fclose(fileID);
    end
end
