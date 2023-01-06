% Simple Cohen's kappa (version 1.0.0)
% Implemented by Elliot Layden
function kappa = cohens_kappa(C)
    % Matlab function computes Cohen's kappa from observed categories and predicted categories
    % https://github.com/elayden/cohensKappa
    n = sum(C(:)); % get total N
    C = C ./ n; % Convert confusion matrix counts to proportion of n
    r = sum(C, 2); % row sum
    s = sum(C); % column sum
    expected = r * s; % expected proportion for random agree
    po = sum(diag(C)); % Observed proportion correct
    pe = sum(diag(expected)); % Proportion correct expected
    kappa = (po - pe) / (1 - pe); % Cohen's kappa
end
