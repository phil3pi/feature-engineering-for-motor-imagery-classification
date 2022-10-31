% clear workspace, functionspace and figures
close all;clear all;

patient_id=1;
% here eeg, laball, artifactsall is loaded
load(sprintf('./Training Data/DATAall_cleaneog_A0%dT_Fs250',patient_id));

%Remove artifactual trials
artifacts=find(artifactsall==1);
eeg(:,:,artifacts)=[];
laball(artifacts)=[];
[channels,N,trials]=size(eeg);

% resolve outliers
outliers=isoutlier(eeg(1,:,:),"quartiles",2);
outlier_indexes=find(outliers==1);
number_of_outliers=length(outlier_indexes);
fprintf('Number of outliers detected: %d.\n', number_of_outliers);

eeg_preprocessed=nan(channels,N,trials);
disp("Preprocessing channel: ")
for c=1:channels
    fprintf('%d, ',c);
    eeg_preprocessed(c,:,:)=filloutliers(eeg(c,:,:),"linear","quartiles");
end

% important set predefined random state in order to compare results
kfolds=10;
rng('default')
cvIndices = crossvalind('kfold',laball,kfolds);

plot(1:1:1500,eeg(1,:,1));
