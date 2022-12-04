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

kfolds=10;
rng('default') % set predefined random state for making results comparable
cv_indixes = crossvalind('kfold',data.laball,kfolds);

window_size=100;

% performance measures
nn=window_size+1:window_size:data.N;
accuracy=nan(length(nn),kfolds);
accuracy_chance=nan(length(nn),kfolds);
kappa=nan(length(nn),kfolds);
kappa_chance=nan(length(nn),kfolds);

% w_param = WaveletEntropyParameters();
% w_permutations = w_param.getPermutations;
% for w_perm=permute(w_permutations,[2 1])
%     disp(w_perm);
for kf=1:kfolds
    test_indices=find(cv_indixes==kf);
    train_indices=find(cv_indixes~=kf);

    % Pre-allocate a buffered matrix of all window sizes.
    % This reduces the memory overhead of parfor if the thread size
    % continues to increase. Without pre-allocation each thread would need
    % to copy the complete eeg dataset
    train_data_nn=nan(length(nn),data.channels,window_size+1,length(train_indices));
    test_data_nn=nan(length(nn),data.channels,window_size+1,length(test_indices));
    y_train_nn=nan(length(nn),length(train_indices));
    y_test_nn=nan(length(nn),length(test_indices));
    %         w_perm_nn=strings([length(nn),length(w_perm')]);
    for n=1:length(nn)
        train_data_nn(n,:,:,:)=data.eeg(:,nn(n)-window_size:nn(n),train_indices);
        test_data_nn(n,:,:,:)=data.eeg(:,nn(n)-window_size:nn(n),test_indices);
        y_train_nn(n,:)=data.laball(train_indices);
        y_test_nn(n,:)=data.laball(test_indices);
        %             w_perm_nn(n,:)=w_perm';
    end
    fs=data.fs;

    parfor n=1:length(nn)
        disp([kf n])
        train_data=squeeze(train_data_nn(n,:,:,:));
        %train_data=psd_extractor(train_data,fs);
        %train_data=wavelet_entropy_extractor(train_data,w_perm_nn(n,:));
        %train_data=wavelet_variance_extractor(train_data);
        %train_data=wavelet_extractor(train_data);
        train_data=ar_extractor(train_data,"aryule",4,false);
        %train_data=lyapunov_exponent_extractor(train_data,fs);
        x_train=permute(train_data,[3 1 2]); %Take win time points before the current time point up till the current time point (it's causal)
        x_train=x_train(:,:); % x_train is of dimension [number of training trials x number of features]
        y_train=y_train_nn(n,:);

        test_data=squeeze(test_data_nn(n,:,:,:));
        %test_data=psd_extractor(test_data,fs);
        %test_data=wavelet_entropy_extractor(test_data,w_perm_nn(n,:));
        %test_data=wavelet_variance_extractor(test_data);
        %test_data=wavelet_extractor(test_data);
        test_data=ar_extractor(test_data,"aryule",4,false);
        %test_data=lyapunov_exponent_extractor(test_data,fs);
        x_test=permute(test_data,[3 1 2]);
        x_test=x_test(:,:); % x_test is of dimension [number of testing trials x number of features]
        y_test=y_test_nn(n,:);

        [model_lda]=lda_train(x_train,y_train); % Train on training data
        [y_pred,scores,~]=lda_predict(model_lda,x_test); % Test on testing data

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
%filename=sprintf('%s-%s-lvl-%s.pdf',w_perm(1),w_perm(2),w_perm(3));
tile=print_measures(data,window_size,accuracy,accuracy_chance,kappa,kappa_chance);
%exportgraphics(tile,"save.pdf");
%end
