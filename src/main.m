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

% PsdParameters(FrequencyBand.getAllBands,StatisticParameters("std"))
% StatisticParameters("mean")
parameter = {ArPsdParameters("pyulear",6,StatisticParameters("min"),FrequencyBand.getAllBands),StatisticParameters("mean")};

try
    [accuracy, accuracy_chance, kappa, kappa_chance] = fixed_train_classifier(data_250, 100, parameter);

    print_measures(data_250.N, data_250.fs, 100, accuracy, accuracy_chance, kappa, kappa_chance, "final-classifier.fig");
catch ME
    fileID = fopen("final-classifier.txt", 'w');
    fprintf(fileID, "%s\n", ME.identifier);
    fprintf(fileID, ME.message);
    disp(ME.message);
    fclose(fileID);
end
