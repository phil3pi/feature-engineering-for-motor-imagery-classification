% clear workspace, functionspace and figures
close all;clear all;

addpath('classifiers/lda');
addpath('extractors/');
addpath('utils/');
addpath('tests/');
addpath('data/');

setup_multithreading(10);

data=Dataset(1);
data.removeArtifacts();
%data.removeOutliers("quartiles","spline");
%data.resample(50);

window_size = 100;
[accuracy,accuracy_chance,kappa,kappa_chance]=train_classifier(data,window_size);

%filename=sprintf('%s-%s-lvl-%s.pdf',w_perm(1),w_perm(2),w_perm(3));
tile=print_measures(data.N,data.fs,window_size,accuracy,accuracy_chance,kappa,kappa_chance);
%exportgraphics(tile,"save.pdf");
%end
