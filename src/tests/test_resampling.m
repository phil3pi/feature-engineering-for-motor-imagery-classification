% clear workspace, functionspace and figures
close all; clear all;

data = Dataset(1);
data.removeArtifacts();
data.resample(50);
t = data.eeg;
