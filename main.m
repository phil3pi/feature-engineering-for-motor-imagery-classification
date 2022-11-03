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

%Train-test using sLDA and cross-validation
accuracy=nan(N,kfolds);
accuracy_chance=nan(N,kfolds);
kappa=nan(N,kfolds);
kappa_chance=nan(N,kfolds);

for kf=1:kfolds
    test_indexes=find(cv_indixes==kf);
    train_indexes=find(cv_indixes~=kf);
    
    for n=window_size+1:25:N
        disp([kf n])
        train_data=eeg(:,n-window_size:n,train_indexes);
        %s_features_train=statistic_extractor(train_data);
        %train_data=horzcat(train_data, s_features_train);
        %train_data=s_features_train;
        x_train=permute(train_data,[3 1 2]); %Take win time points before the current time point up till the current time point (it's causal)
        x_train=x_train(:,:); % x_train is of dimension [number of training trials x number of features]
        y_train=laball(train_indexes);

        test_data=eeg(:,n-window_size:n,test_indexes);
        %s_features_test=statistic_extractor(test_data);
        %test_data=horzcat(test_data, s_features_test);
        %test_data=s_features_test;
        x_test=permute(test_data,[3 1 2]);
        x_test=x_test(:,:); % x_test is of dimension [number of testing trials x number of features]
        y_test=laball(test_indexes);

        [model_lda]=lda_train(x_train,y_train); % Train on training data
        [y_pred]=lda_predict(model_lda,x_test); % Test on testing data

        c_matrix=confusionmat(y_test,y_pred);
        [accuracy(n,kf),kappa(n,kf)] = statsOfMeasure(c_matrix); % Estimate accuracy

        % Get chance level by permuting randomly the input matrix x_test
        permuted_inds=randsample(length(y_test),length(y_test));
        x_test_perm=x_test(permuted_inds,:);
        [y_pred] = lda_predict(model_lda,x_test_perm); %Test on testing data
        c_matrix=confusionmat(y_test,y_pred); %Compute confusion matrix
        [accuracy_chance(n,kf),kappa_chance(n,kf)] = statsOfMeasure(c_matrix); %Estimate accuracy  
    end
end

mean_accuracy=100*nanmean(accuracy,2); %average over all fold
mean_accuracy_chance=100*nanmean(accuracy_chance,2); %average over all fold
mean_kappa=nanmean(kappa,2); %average over all fold
mean_kappa_chance=nanmean(kappa_chance,2); %average over all fold

%Plot the average testing accuracy as a function of time
sampling_rate=250;
time=((0:N-1)/sampling_rate)-2; %in seconds; cue onset starts 2 seconds after the trial start. Cue onset is indicate with 0s

% print accuracy value
figure;plot(time(window_size+1:25:N),mean_accuracy(window_size+1:25:N));
hold on;plot(time(window_size+1:25:N),mean_accuracy_chance(window_size+1:25:N),'k:');
xlabel('s')
ylabel('Accuracy(%)')
% print kappa value
figure;plot(time(window_size+1:25:N),mean_kappa(window_size+1:25:N));
hold on;plot(time(window_size+1:25:N),mean_kappa_chance(window_size+1:25:N),'k:');
xlabel('s')
ylabel('kappa')
