function [accuracy,accuracy_chance,kappa,kappa_chance] = train_classifier(data,window_size,method)
%TRAIN_CLASSIFIER Summary of this function goes here
%   Detailed explanation goes here
kfolds=10;
rng('default') % set predefined random state for making results comparable
cv_indixes = crossvalind('kfold',data.laball,kfolds);

% performance measures
nn=window_size+1:window_size:data.N;
accuracy=nan(length(nn),kfolds);
accuracy_chance=nan(length(nn),kfolds);
kappa=nan(length(nn),kfolds);
kappa_chance=nan(length(nn),kfolds);

tStart = tic;
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
    for n=1:length(nn)
        train_data_nn(n,:,:,:)=data.eeg(:,nn(n)-window_size:nn(n),train_indices);
        test_data_nn(n,:,:,:)=data.eeg(:,nn(n)-window_size:nn(n),test_indices);
        y_train_nn(n,:)=data.laball(train_indices);
        y_test_nn(n,:)=data.laball(test_indices);
    end
    fs=data.fs;

    parfor n=1:length(nn)
        disp([kf n])
        train_data=squeeze(train_data_nn(n,:,:,:));
        switch method
            case "psd"
                train_data=FeatureExtractor.psd(train_data,fs,["delta","theta","alpha","beta","gamma","high-gamma","broad"],["std"]);
            case "waveletEntropy"
                train_data=FeatureExtractor.waveletEntropy(train_data,WaveletEntropyParameters("Shannon","modwt",4));
            case "waveletVariance"
                train_data=FeatureExtractor.waveletVariance(train_data);
            case "waveletCorrelation"
                train_data=FeatureExtractor.waveletCorrelation(train_data);
            case "statistic"
                train_data=FeatureExtractor.statistic(train_data,fs,["slope"]);
            case "ar"
                train_data=FeatureExtractor.ar(train_data,"aryule",4,false);
            case "arPsd"
                train_data=FeatureExtractor.arPsd(train_data,fs,"pburg",4,["delta","theta","alpha","beta","gamma","high-gamma","broad"],["median"]);
            case "lyapunov"
                train_data=FeatureExtractor.lyapunovExponent(train_data,fs);
            otherwise
                error("Invalid extraction method. Only support: psd, waveletEntropy, waveletCorrelation, statistic, ar, arPsd, lyapunov.");
        end
        x_train=permute(train_data,[3 1 2]); %Take win time points before the current time point up till the current time point (it's causal)
        x_train=x_train(:,:); % x_train is of dimension [number of training trials x number of features]
        y_train=y_train_nn(n,:);

        test_data=squeeze(test_data_nn(n,:,:,:));
        switch method
            case "psd"
                test_data=FeatureExtractor.psd(test_data,fs,["delta","theta","alpha","beta","gamma","high-gamma","broad"],["std"]);
            case "waveletEntropy"
                test_data=FeatureExtractor.waveletEntropy(test_data,WaveletEntropyParameters("Shannon","modwt",4));
            case "waveletVariance"
                test_data=FeatureExtractor.waveletVariance(test_data);
            case "waveletCorrelation"
                test_data=FeatureExtractor.waveletCorrelation(test_data);
            case "statistic"
                test_data=FeatureExtractor.statistic(test_data,fs,["slope"]);
            case "ar"
                test_data=FeatureExtractor.ar(test_data,"aryule",4,false);
            case "arPsd"
                test_data=FeatureExtractor.arPsd(test_data,fs,"pburg",4,["delta","theta","alpha","beta","gamma","high-gamma","broad"],["median"]);
            case "lyapunov"
                test_data=FeatureExtractor.lyapunovExponent(test_data,fs);
            otherwise
                error("Invalid extraction method. Only support: psd, waveletEntropy, waveletCorrelation, statistic, ar, arPsd, lyapunov.");
        end
        x_test=permute(test_data,[3 1 2]);
        x_test=x_test(:,:); % x_test is of dimension [number of testing trials x number of features]
        y_test=y_test_nn(n,:);

        [model_lda]=lda_train(x_train,y_train); % Train on training data
        [y_pred,~,~]=lda_predict(model_lda,x_test); % Test on testing data

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
tEnd = toc(tStart);
fprintf('Elapsed time for training and testing model is %0.4f seconds.\n',tEnd);
end

