% LDA - MATLAB subroutine to predict class memberships with linear discriminant analysis
% by David Steyrl
%
% Use:
% [predicted_classes, linear_scores, class_probabilities] = lda_predict(model_lda,data_test)
%
% predicted_classes = vector of predicted class memberships (samples (observations) x classlabels)
% model_lda         = model_lda.w = linear coefficients (first column are the constants)
%                     model_lda.classlabel = classlabels of the training data
% data_test         = data with unknown class belonging (samples (observations) x features)
%
% Last modified: Jan-29-2016 by David Steyrl

function [predicted_classes, linear_scores, class_probabilities] = lda_predict(model_lda,data_test)

% Determine size of the test data
[n, ~] = size(data_test);

% Calulcate linear scores for training data
linear_scores = [ones(n,1), data_test] * model_lda.w';

% Calculate class probabilities
class_probabilities = exp(linear_scores) ./ repmat(sum(exp(linear_scores),2),[1 length(model_lda.classlabels)]);

% Calculate class membership
[~, ind_class] = max(linear_scores,[],2);
predicted_classes = NaN(n,1);
for ind = 1:n
    predicted_classes(ind) = model_lda.classlabels(ind_class(ind));
end

end % EOF