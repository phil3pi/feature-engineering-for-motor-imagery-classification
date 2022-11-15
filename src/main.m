% clear workspace, functionspace and figures
close all;clear all;

addpath('classifiers/lda');
addpath('extractors/');
addpath('utils/');
addpath('tests/');
addpath('data/');

% TODO: take care for out of memory exception
setup_multithreading(12);

data=Dataset(1);
data.remove_artifacts();

% important set predefined random state in order to compare results
kfolds=10;
rng('default')
cv_indixes = crossvalind('kfold',data.laball,kfolds);

% number of samples
window_size=100;

% performance measures
nn=window_size+1:window_size:data.N;
accuracy=nan(length(nn),kfolds);
accuracy_chance=nan(length(nn),kfolds);
kappa=nan(length(nn),kfolds);
kappa_chance=nan(length(nn),kfolds);

% ROC curve variables
roc_X_nn=zeros(length(nn),length(find(cv_indixes==1))+1,kfolds);
roc_Y_nn=zeros(length(nn),length(find(cv_indixes==1))+1,kfolds);
roc_AUC_nn=zeros(length(nn),1,kfolds);
roc_counter=0;

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
    fs=data.fs;

    parfor n=1:length(nn)
        disp([kf n])
        
        train_data=squeeze(train_data_nn(n,:,:,:));
        train_data=psd_extractor(train_data,fs);
        x_train=permute(train_data,[3 1 2]); %Take win time points before the current time point up till the current time point (it's causal)
        x_train=x_train(:,:); % x_train is of dimension [number of training trials x number of features]
        y_train=y_train_nn(n,:);

        test_data=squeeze(test_data_nn(n,:,:,:));
        test_data=psd_extractor(test_data,fs);
        x_test=permute(test_data,[3 1 2]);
        x_test=x_test(:,:); % x_test is of dimension [number of testing trials x number of features]
        y_test=y_test_nn(n,:);

        [model_lda]=lda_train(x_train,y_train); % Train on training data
        [y_pred,scores,~]=lda_predict(model_lda,x_test); % Test on testing data
        
        c_matrix=confusionmat(y_test,y_pred);
        [accuracy(n,kf),kappa(n,kf)] = stats_of_measure(c_matrix); % Estimate accuracy

        % print roc curve
        calculation_counter=0;
        for label=1:4 % iterate of all classification labels
            if isempty(find(y_pred==label, 1))
                continue
            end
            if length(roc_X_nn(n,:,kf))-(length(y_pred))-1~=0
                break
            end
            [X_temp,Y_temp,~,AUC_temp]=perfcurve(y_pred,scores(:,label),label);
            %length_difference=length(roc_X_nn(n,:,kf))-length(X_temp);
            roc_X_nn(n,:,kf)=roc_X_nn(n,:,kf)+permute(X_temp,[2,1]);
            roc_Y_nn(n,:,kf)=roc_Y_nn(n,:,kf)+permute(Y_temp,[2,1]);
            roc_AUC_nn(n,:,kf)=roc_AUC_nn(n,:,kf)+AUC_temp;
            calculation_counter=calculation_counter+1;
        end
        if calculation_counter~=0
            roc_X_nn(n,:,kf)=roc_X_nn(n,:,kf)./calculation_counter;
            roc_Y_nn(n,:,kf)=roc_Y_nn(n,:,kf)./calculation_counter;
            roc_AUC_nn(n,:,kf)=roc_AUC_nn(n,:,kf)./calculation_counter;
            roc_counter=roc_counter+1;
        end

        % Get chance level by permuting randomly the input matrix x_test
        permuted_inds=randsample(length(y_test),length(y_test));
        x_test_perm=x_test(permuted_inds,:);
        [y_pred] = lda_predict(model_lda,x_test_perm); %Test on testing data
        c_matrix=confusionmat(y_test,y_pred); %Compute confusion matrix
        [accuracy_chance(n,kf),kappa_chance(n,kf)] = stats_of_measure(c_matrix); %Estimate accuracy  
    end
end

print_measures(data,window_size,accuracy,accuracy_chance,kappa,kappa_chance);

roc_X=sum(squeeze(sum(roc_X_nn,1)),2)./roc_counter;
roc_Y=sum(squeeze(sum(roc_Y_nn,1)),2)./roc_counter;
roc_AUC=100*(sum(squeeze(sum(roc_AUC_nn,1)))./roc_counter);
figure;
plot(roc_X,roc_Y)
xlabel('False positive rate') 
ylabel('True positive rate')
title('ROC for Classification by LDA')
legend(sprintf('AUC: %0.2f%%',roc_AUC),'Location','southeast')