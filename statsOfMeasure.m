
function [acc] = statsOfMeasure(c_matrix)
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

end
