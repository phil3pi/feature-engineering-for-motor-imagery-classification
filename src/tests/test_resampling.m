% clear workspace, functionspace and figures
close all;clear all;

data=Dataset(1);
data.removeArtifacts();
data.resampleData(50);
t = data.eeg;