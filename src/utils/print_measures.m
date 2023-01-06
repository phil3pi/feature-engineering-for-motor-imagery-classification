function [t] = print_measures(N,fs,window_size,accuracy,accuracy_chance,kappa,kappa_chance,filename)
%PRINT_MEASURES Creates a plot of the accuracy and kappa measures
arguments
    N {mustBeNumeric};
    fs {mustBeNumeric};
    window_size {mustBeNumeric};
    accuracy (:,:) {mustBeNumeric};
    accuracy_chance (:,:) {mustBeNumeric};
    kappa (:,:) {mustBeNumeric};
    kappa_chance (:,:) {mustBeNumeric};
    filename string;
end
time=((0:N-1)/fs)-2; %in seconds; cue onset starts 2 seconds after the trial start. Cue onset is indicate with 0s
%
% Below is only plotting stuff
%
t=tiledlayout(2,1);
t.TileSpacing='loose';
%title(t,'Performance measures of classification')
nexttile;
% plot the average testing accuracy as a function of time
% print accuracy value
mean_accuracy=100*mean(accuracy,2); %average over all fold
mean_accuracy_chance=100*mean(accuracy_chance,2); %average over all fold
plot(time(window_size+1:window_size:N),mean_accuracy);
hold on;
plot(time(window_size+1:window_size:N),mean_accuracy_chance,'k:');
xlabel('time [s]')
ylabel('accuracy [%]')
ylim([10 100])

nexttile;
% plot the average testing kappa value as a function of time
% print kappa value
mean_kappa=mean(kappa,2); %average over all fold
mean_kappa_chance=mean(kappa_chance,2); %average over all fold
plot(time(window_size+1:window_size:N),mean_kappa);
hold on;
plot(time(window_size+1:window_size:N),mean_kappa_chance,'k:');
xlabel('time [s]')
ylabel('cohen`s kappa')
ylim([0 1])
hold off;

if filename ~= ""
    filename = sprintf("%0.2f-%s",max(mean_accuracy),filename);
    savefig(filename);
    fprintf("Saved plot as %s\n",filename);
end
end