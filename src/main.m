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

data = Dataset(1,true);
data.removeArtifacts();
data.resample(50);

evaluation_data = Dataset(1,false);
evaluation_data.removeArtifacts();
evaluation_data.resample(50);

filename = "final-classifier";

try
    [accuracy, accuracy_chance, kappa, kappa_chance] = train_all_classifier(data, evaluation_data, 20);
    
    print_measures(data.N, data.fs, 20, accuracy, accuracy_chance, kappa, kappa_chance, filename + ".fig");
catch ME
    fileID = fopen("0-" + filename + ".txt", 'w');
    fprintf(fileID, "%s\n", ME.identifier);
    fprintf(fileID, ME.message);
    disp(ME.message);
    fclose(fileID);
end
