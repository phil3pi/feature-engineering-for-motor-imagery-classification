% LDA - MATLAB subroutine to perform linear discriminant analysis
% by Will Dwinnell and Deniz Sevis, modified by David Steyrl
%
% Use:
% model_lda       = lda_train(data_train,classlabels,CovEstMethod,PriorsEstMethod,PriorProb)
%
% model_lda       = model_lda.w = discovered linear coefficients (first column are the constants)
%                   model_lda.classlabel = classlabels of the training data
% data_train      = data for classifier's training (samples (observations) x features)
% classlabels     = class labels (samples (observations) x class label)
% CovEstMethod    = (optional) Which method for calculating the cov matrix should
%                   be used? 'shrinkage' (default) or 'standard'
% PriorsEstMethod = (optional) Which method for defining the prior
%                   probabilities should be used? 'equally' (default) or
%                   'calc' or 'given'
% PriorProb       = (optional) vector of prior class probabilities (probabilities per class x 1)
%
% Note: discriminant coefficients are stored in model_lda in the order of unique(classlabels)
%
% Dependences:
% cov_shrink.m
%
% Last modified: July-30-2014 by David Steyrl

function [model_lda] = lda_train(data_train,classlabels,CovEstMethod,PriorsEstMethod,PriorProb)

% Default calculation methods
if (nargin == 2)
    CovEstMethod = 'shrinkage';
    PriorsEstMethod = 'equally';
end

if (nargin == 3)
    PriorsEstMethod = 'equally';
end

% Determine size of input data
[n, m] = size(data_train);

% Discover and count unique class labels
ClassLabel = unique(classlabels);
k = length(ClassLabel);

% Initialize
nGroup     = NaN(k,1);     % Group counts
GroupMean  = NaN(k,m);     % Group sample means
PooledCov  = zeros(m,m);   % Pooled covariance
W  = NaN(k,m+1);           % model coefficients
model_lda=[];              % model initialization

% Loop over classes to perform intermediate calculations
for i = 1:k,
    % Establish location and size of each class
    Group      = (classlabels == ClassLabel(i));
    nGroup(i)  = sum(double(Group));
    
    % Calculate group mean vectors
    GroupMean(i,:) = mean(data_train(Group,:));
    
    % Accumulate pooled covariance information
    switch CovEstMethod
        case 'shrinkage'
            PooledCov = PooledCov + ((nGroup(i) - 1) / (n - k) ).* cov_shrink(data_train(Group,:));
%             [~, lam] = cov_shrink(data_train(Group,:));
        case 'standard'
            PooledCov = PooledCov + ((nGroup(i) - 1) / (n - k) ).* cov(data_train(Group,:));
        otherwise
            disp('Error. Unknown covariance estimation method.')
            return
    end
end

% Switch priors estimation method
switch PriorsEstMethod
	case 'equally'
        PriorProb = ones(k,1)/k;
	case 'calc'
        PriorProb = nGroup / n;
    case 'given'
        if (nargin ~= 5)
            disp('Error. Incongruous amount of input arguments.');
            return
        end
        if (length(PriorProb) ~= k)
            disp('Error. Incongruous amount of prior probabilities.');
            return
        end
    otherwise
        disp('Error. Unknown prior probabilities method.')
        return
end

% Loop over classes to calculate linear discriminant coefficients
for i = 1:k,
    % Intermediate calculation for efficiency
    % This replaces:  GroupMean(g,:) * inv(PooledCov)
    Temp = GroupMean(i,:) / PooledCov;
    
    % Constant
    W(i,1) = -0.5 * Temp * GroupMean(i,:)' + log(PriorProb(i));
    
    % Linear
    W(i,2:end) = Temp;
end

model_lda.w = W;
model_lda.classlabels = ClassLabel;
% model_lda.PooledCov = PooledCov;
% model_lda.lam = lam;

end % EOF