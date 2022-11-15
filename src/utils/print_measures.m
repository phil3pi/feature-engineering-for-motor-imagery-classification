function [t] = print_measures(data,window_size,accuracy,accuracy_chance,kappa,kappa_chance,roc_X,roc_Y,roc_AUC)
%PRINT_MEASURES Summary of this function goes here
%   Detailed explanation goes here
roc_enabled=true;
if nargin < 9
    roc_enabled=false;
end
time=((0:data.N-1)/data.fs)-2; %in seconds; cue onset starts 2 seconds after the trial start. Cue onset is indicate with 0s
%
% Below is only plotting stuff
%
t=tiledlayout(inline_if(roc_enabled,3,2),1);
t.TileSpacing='loose';
title(t,'Performance measures of classification')
nexttile;
% plot the average testing accuracy as a function of time
% print accuracy value
mean_accuracy=100*mean(accuracy,2); %average over all fold
mean_accuracy_chance=100*mean(accuracy_chance,2); %average over all fold
plot(time(window_size+1:window_size:data.N),mean_accuracy);
hold on;
plot(time(window_size+1:window_size:data.N),mean_accuracy_chance,'k:');
xlabel('time [s]')
ylabel('accuracy [%]')
ylim([10 100])

nexttile;
% plot the average testing kappa value as a function of time
% print kappa value
mean_kappa=mean(kappa,2); %average over all fold
mean_kappa_chance=mean(kappa_chance,2); %average over all fold
plot(time(window_size+1:window_size:data.N),mean_kappa);
hold on;
plot(time(window_size+1:window_size:data.N),mean_kappa_chance,'k:');
xlabel('time [s]')
ylabel('cohen`s kappa')
ylim([0 1])
hold off;
if roc_enabled
    nexttile;
    plot(roc_X,roc_Y)
    xlabel('False positive rate') 
    ylabel('True positive rate')
    title('ROC for Classification by LDA')
    legend(sprintf('AUC: %0.2f%%',roc_AUC),'Location','southeast')
end
end