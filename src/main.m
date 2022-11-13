% clear workspace, functionspace and figures
close all;clear all;

addpath('classifiers/lda');
addpath('extractors/');
addpath('utils/');
addpath('tests/');
addpath('data/');

% TODO: take care for out of memory exception
setup_multithreading(8);

data=Dataset(1);
data.remove_artifacts();

% important set predefined random state in order to compare results

kfolds=10;
rng('default')
cv_indixes = crossvalind('kfold',data.laball,kfolds);

% number of samples
window_size=10;

%Train-test using sLDA and cross-validation

nn=window_size+1:window_size:data.N;
accuracy=nan(length(nn),kfolds);
accuracy_chance=nan(length(nn),kfolds);
kappa=nan(length(nn),kfolds);
kappa_chance=nan(length(nn),kfolds);
for kf=1:kfolds
    test_indexes=find(cv_indixes==kf);
    train_indexes=find(cv_indixes~=kf);
    
    % Pre-allocate a buffered matrix of all window sizes. 
    % This reduces the memory overhead of parfor if the thread size 
    % continues to increase. Without pre-allocation each thread would need
    % to copy the complete eeg dataset
    train_data_nn=nan(length(nn),data.channels,window_size+1,length(train_indexes));
    test_data_nn=nan(length(nn),data.channels,window_size+1,length(test_indexes));
    y_train_nn=nan(length(nn),length(train_indexes));
    y_test_nn=nan(length(nn),length(test_indexes));
    for n=1:length(nn)
        train_data_nn(n,:,:,:)=data.eeg(:,nn(n)-window_size:nn(n),train_indexes);
        test_data_nn(n,:,:,:)=data.eeg(:,nn(n)-window_size:nn(n),test_indexes);
        y_train_nn(n,:)=data.laball(train_indexes);
        y_test_nn(n,:)=data.laball(test_indexes);
    end

    parfor n=1:length(nn)
        disp([kf n])
        
        train_data=squeeze(train_data_nn(n,:,:,:));
        %train_data=psd_extractor(train_data,fs);
        %s_features_train=statistic_extractor(train_data);
        %train_data=horzcat(train_data, s_features_train);
        %train_data=s_features_train;
        x_train=permute(train_data,[3 1 2]); %Take win time points before the current time point up till the current time point (it's causal)
        x_train=x_train(:,:); % x_train is of dimension [number of training trials x number of features]
        y_train=y_train_nn(n,:);

        test_data=squeeze(test_data_nn(n,:,:,:));
        %test_data=psd_extractor(test_data,fs);
        %s_features_test=statistic_extractor(test_data);
        %test_data=horzcat(test_data, s_features_test);
        %test_data=s_features_test;
        x_test=permute(test_data,[3 1 2]);
        x_test=x_test(:,:); % x_test is of dimension [number of testing trials x number of features]
        y_test=y_test_nn(n,:);

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

print_measures(data,window_size,accuracy,accuracy_chance,kappa,kappa_chance);