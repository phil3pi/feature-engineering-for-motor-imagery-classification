% clear workspace, functionspace and figures
close all;clear all;

addpath('classifiers/');
addpath('classifiers/lda');
addpath('extractors/');
addpath('extractors/parameters/')
addpath('utils/');
addpath('tests/');
addpath('data/');

setup_multithreading(10);

data=Dataset(1);
data.removeArtifacts();
%data.removeOutliers("quartiles","spline");
%data.resample(50);

window_size = 100;

methods = ["psd", "waveletEntropy", "waveletCorrelation", "statistic", "ar", "arPsd", "lyapunov"];
for method=methods
    [accuracy,accuracy_chance,kappa,kappa_chance]=train_classifier(data,window_size,method);

    filename=sprintf('%s.fig',method);
    print_measures(data.N,data.fs,window_size,accuracy,accuracy_chance,kappa,kappa_chance,filename);
end