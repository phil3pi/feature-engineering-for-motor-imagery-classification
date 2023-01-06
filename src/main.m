% clear workspace, functionspace and figures
close all;clear all;

addpath('classifiers/');
addpath('classifiers/lda');
addpath('extractors/');
addpath('extractors/parameters/')
addpath('utils/');
addpath('tests/');
addpath('data/');

setup_multithreading(8);

data=Dataset(1);
data.removeArtifacts();
%data.removeOutliers("quartiles","spline");

sampling_rates = [250,50,25];
window_sizes = [100,20,10];

for i=1:length(sampling_rates)
    data.resample(sampling_rates(i));
    %parametersList = StatisticParameters.getPermutations;
    %parametersList = PsdParameters.getPermutations;
    %parametersList = WaveletEntropyParameters.getPermutations;
    %parametersList = [WaveletVarianceParameters()];
    %parametersList = [WaveletCorrelationParameters()];
    parametersList = ArParameters.getPermutations;
    %parametersList = ArPsdParameters.getPermutations;
    %parametersList = [LyapunovParameters()];
    for parameter=parametersList
        try
            [accuracy,accuracy_chance,kappa,kappa_chance]=train_classifier(data,window_sizes(i),parameter);

            filename=sprintf('%shz-%s-%s.fig',string(sampling_rates(i)),string(window_sizes(i)),parameter.toString);
            print_measures(data.N,data.fs,window_sizes(i),accuracy,accuracy_chance,kappa,kappa_chance,filename);
        catch ME
            filename=sprintf('0-%shz-%s-%s.txt',string(sampling_rates(i)),string(window_sizes(i)),parameter.toString);
            fileID = fopen(filename,'w');
            fprintf(fileID,"%s\n",ME.identifier);
            fprintf(fileID,ME.message);
            disp(ME.message);
            fclose(fileID);
        end
    end
end