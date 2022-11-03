
function [acc,kappa] = statsOfMeasure(c_matrix)
%Compute accuracy based on the confusion matrix c_matrix
n_class=size(c_matrix,1);
TP=zeros(1,n_class);
FN=zeros(1,n_class);
FP=zeros(1,n_class);
TN=zeros(1,n_class);
for i=1:n_class
    TP(i)=c_matrix(i,i);
    FN(i)=sum(c_matrix(i,:))-c_matrix(i,i);
    FP(i)=sum(c_matrix(:,i))-c_matrix(i,i);
    TN(i)=sum(c_matrix(:))-TP(i)-FP(i)-FN(i);
end

P=TP+FN;
N=FP+TN;
acc=sum((TP)./(P+N));
% calculate cohen's kappa measure
% used the following kappa calculation described here:
% https://de.mathworks.com/matlabcentral/answers/505881-how-to-get-accuracy-rate-error-rate-precission-recall-and-kappa-for-fitglm-model
P0=(TP+TN)./(P+N);
Pe=(((TP+FP)./(P+N)).*((TP+FN)./(P+N)))+(((TN+FN)./(P+N)).*((FP+TN)./(P+N)));
kappa=sum((P0-Pe)./(1-Pe));

end
