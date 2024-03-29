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

data_250 = Dataset(1, true);
data_250.removeArtifacts();

data_50 = Dataset(1, true);
data_50.removeArtifacts();
data_50.resample(50);

classifiers = ["slda", "svm", "naive-bayes", "neural-network", "knn", "ensemble"];

for classifier = classifiers
    parameter = {{WaveletVarianceParameters(), 50}, {StatisticParameters("mean"), 50}};
    filename = sprintf('waveletVariance-50hz-statistic-mean-50hz-%s', classifier);

    try
        [accuracy, accuracy_chance, kappa, kappa_chance] = multiple_features_train_classifier(data_250, data_50, 100, 20, parameter, classifier);

        print_measures(data_250.N, data_250.fs, 100, accuracy, accuracy_chance, kappa, kappa_chance, filename + ".fig");
    catch ME
        fileID = fopen("0-" + filename + ".txt", 'w');
        fprintf(fileID, "%s\n", ME.identifier);
        fprintf(fileID, ME.message);
        disp(ME.message);
        fclose(fileID);
    end

end
