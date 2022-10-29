close all;clear all
sub=1;
Fs=250; %sampling rate
%Load data
load(sprintf('./Training Data/DATAall_cleaneog_A0%dT_Fs250',sub))
%Remove artifactual trials
% artifacts=find(artifactsall==1);
% eeg(:,:,artifacts)=[];
% laball(artifacts)=[];
[Channels,N,trials]=size(eeg);

%Create cross-validation indices (10-fold)
kfolds=10;
cvIndices = crossvalind('kfold',laball,kfolds);

%define window size
win=10;

%Train-test using sLDA and cross-validation
accuracy=nan(N,kfolds);
accuracy_chance=nan(N,kfolds);

for kf=1:kfolds
    indstest=find(cvIndices==kf);
    indstrain=find(cvIndices~=kf);
    for n=win+1:25:N
        disp([kf n])
        Xtrain=permute(eeg(:,n-win:n,indstrain),[3 1 2]); %Take win time points before the current time point up till the current time point (it's causal)
        Xtrain=Xtrain(:,:); %Xtrain is of dimension [number of training trials x number of features]
        Ytrain=laball(indstrain);
        Xtest=permute(eeg(:,n-win:n,indstest),[3 1 2]);
        Xtest=Xtest(:,:); %Xtest is of dimension [number of testing trials x number of features]
        Ytest=laball(indstest);
        [model_lda] = lda_train(Xtrain,Ytrain); %Train on training data
        [Ypred] = lda_predict(model_lda,Xtest); %Test on testing data
        c_matrix=confusionmat(Ytest,Ypred); %Compute confusion matrix
        [accuracy(n,kf)] = statsOfMeasure(c_matrix); %Estimate accuracy

        %Get chance level by permuting randomly the input matrix Xtest
        permuted_inds=randsample(length(Ytest),length(Ytest));
        Xtestperm=Xtest(permuted_inds,:);
        [Ypred] = lda_predict(model_lda,Xtestperm); %Test on testing data
        c_matrix=confusionmat(Ytest,Ypred); %Compute confusion matrix
        [accuracy_chance(n,kf)] = statsOfMeasure(c_matrix); %Estimate accuracy        
    end
end

mean_accuracy=100*nanmean(accuracy,2); %average over all fold
mean_accuracy_chance=100*nanmean(accuracy_chance,2); %average over all fold

%Plot the average testing accuracy as a function of time
time=((0:N-1)/Fs)-2; %in seconds; cue onset starts 2 seconds after the trial start. Cue onset is indicate with 0s

figure;plot(time(win+1:25:N),mean_accuracy(win+1:25:N));
hold on;plot(time(win+1:25:N),mean_accuracy_chance(win+1:25:N),'k:');
xlabel('s')
ylabel('Accuracy(%)')

