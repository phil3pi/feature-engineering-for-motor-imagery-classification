% clear workspace, functionspace and figures
close all;clear all;

addpath('classifiers/');
addpath('extractors/');
addpath('utils/');
addpath('tests/')

% TODO: take care for out of memory exception
setup_multithreading(8);

patient_id=1;
% here eeg, laball, artifactsall is loaded
load(sprintf('../dataset/Training Data/DATAall_cleaneog_A0%dT_Fs250',patient_id));

%Remove artifactual trials
artifacts=find(artifactsall==1);
eeg(:,:,artifacts)=[];
laball(artifacts)=[];
[channels,N,trials]=size(eeg);

% resolve outliers
% outliers=isoutlier(eeg(1,:,:),"quartiles",2);
% outlier_indexes=find(outliers==1);
% number_of_outliers=length(outlier_indexes);
% fprintf('Number of outliers detected: %d.\n', number_of_outliers);
% 
% eeg_preprocessed=nan(channels,N,trials);
% disp("Preprocessing channel: ")
% for c=1:channels
%     fprintf('%d, ',c);
%     eeg_preprocessed(c,:,:)=filloutliers(eeg(c,:,:),"linear","quartiles");
% end

% important set predefined random state in order to compare results
kfolds=10;
rng('default')
cv_indixes = crossvalind('kfold',laball,kfolds);

% number of samples
window_size=10;
fs=250; % sampling rate

%Train-test using sLDA and cross-validation

nn=window_size+1:window_size:N;
accuracy=nan(length(nn),kfolds);
accuracy_chance=nan(length(nn),kfolds);
kappa=nan(length(nn),kfolds);
kappa_chance=nan(length(nn),kfolds);
for kf=1:kfolds
    test_indexes=find(cv_indixes==kf);
    train_indexes=find(cv_indixes~=kf);
    
    parfor n=1:length(nn)
        disp([kf n])
        train_data=eeg(:,nn(n)-window_size:nn(n),train_indexes);
        %train_data=psd_extractor(train_data,fs);
        %s_features_train=statistic_extractor(train_data);
        %train_data=horzcat(train_data, s_features_train);
        %train_data=s_features_train;
        x_train=permute(train_data,[3 1 2]); %Take win time points before the current time point up till the current time point (it's causal)
        x_train=x_train(:,:); % x_train is of dimension [number of training trials x number of features]
        y_train=laball(train_indexes);

        test_data=eeg(:,nn(n)-window_size:nn(n),test_indexes);
        %test_data=psd_extractor(test_data,fs);
        %s_features_test=statistic_extractor(test_data);
        %test_data=horzcat(test_data, s_features_test);
        %test_data=s_features_test;
        x_test=permute(test_data,[3 1 2]);
        x_test=x_test(:,:); % x_test is of dimension [number of testing trials x number of features]
        y_test=laball(test_indexes);

        [model_lda]=lda_train(x_train,y_train); % Train on training data
        [y_pred]=lda_predict(model_lda,x_test); % Test on testing data

        c_matrix=confusionmat(y_test,y_pred);
        [accuracy(n,kf),kappa(n,kf)] = stats_of_measure(c_matrix); % Estimate accuracy

        % Get chance level by permuting randomly the input matrix x_test
        permuted_inds=randsample(length(y_test),length(y_test));
        x_test_perm=x_test(permuted_inds,:);
        [y_pred] = lda_predict(model_lda,x_test_perm); %Test on testing data
        c_matrix=confusionmat(y_test,y_pred); %Compute confusion matrix
        [accuracy_chance(n,kf),kappa_chance(n,kf)] = stats_of_measure(c_matrix); %Estimate accuracy  
    end
end
time=((0:N-1)/fs)-2; %in seconds; cue onset starts 2 seconds after the trial start. Cue onset is indicate with 0s
%
% Below is only plotting stuff
%
t=tiledlayout(2,1);
t.TileSpacing='loose';
title(t,'Performance measures of classification')
nexttile;
% plot the average testing accuracy as a function of time
% print accuracy value
mean_accuracy=100*mean(accuracy,2); %average over all fold
mean_accuracy_chance=100*mean(accuracy_chance,2); %average over all fold
plot(time(window_size+1:window_size:N),mean_accuracy);
hold on;
plot(time(window_size+1:window_size:N),mean_accuracy_chance,'k:');
xlabel('time [s]')
ylabel('accuracy [%]')
ylim([10 50])

nexttile;
% plot the average testing kappa value as a function of time
% print kappa value
mean_kappa=mean(kappa,2); %average over all fold
mean_kappa_chance=mean(kappa_chance,2); %average over all fold
plot(time(window_size+1:window_size:N),mean_kappa);
hold on;
plot(time(window_size+1:window_size:N),mean_kappa_chance,'k:');
xlabel('time [s]')
ylabel('cohen`s kappa')
ylim([0 1])

