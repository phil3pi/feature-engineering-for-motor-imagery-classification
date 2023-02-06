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

filename = "final-classifier";

% TODO: tested on different patient, performs bad (patient id 2)
parameter = {{WaveletVarianceParameters(),50},{StatisticParameters("mean"),50}};
try
        [accuracy, accuracy_chance, kappa, kappa_chance] = combination_train_classifier(data_250, data_50, 100, 20, parameter);
        
        print_measures(data_250.N, data_250.fs, 100, accuracy, accuracy_chance, kappa, kappa_chance, filename + ".fig");
catch ME
    fileID = fopen("0-" + filename + ".txt", 'w');
    fprintf(fileID, "%s\n", ME.identifier);
    fprintf(fileID, ME.message);
    disp(ME.message);
    fclose(fileID);
end
