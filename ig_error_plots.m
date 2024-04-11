%% Interferogram Error Plots
% * Author:                  Miranda Holloway
% * Date:                    Created 4/2/2023, Last Edited 4/___/2024
%
% This code is originally adapted from interferogram_error_plots.m written
% by Alexander Nguyen.
%

clc;
clearvars;
close all;

%% Pull in data

% Define subdirectory to use
subdir = "subdir_100m";

% Either pull in data with the insar2mat() function
% [amps,coh,ints,phase,unw_phase,date_pair,doy_pair,N] = insar2mat(subdir,1,1,1,1,1);

% Or pull in .mat files from the subdirectory
addpath(strcat('C:\Users\mmpho\sent_test\',subdir,'\Processed .mat Files'))
amps = load('amps_data.mat');
coh = load('coherence_data.mat');
ints = load('int_data.mat');
phase = load('phase_data.mat');
unw_phase = load('unw_phase_data.mat');
date_pair = load('date_pair_data.mat');
doy_pair = load('doy_pair_data.mat');
N = size(doy_pair,2);

%% Get an average coherence file 
avecc = mean(coh,3);
cor_mask = avecc;
alpha = 0.17; % 0.15 clears out bottom of river and lakes in top LH corner well but doesn't clean river in top RH corner - maybe 0.17 is a bit too much too
cor_mask(cor_mask<alpha) = nan;
cor_mask(cor_mask>alpha) = 1;
mask = cor_mask;

% Making 2 x 2 plot of wrapped, coherence, unwrapped, and unw distribution

%setting alpha channel to recognize NaN values in mask, setting to black
imAlpha=ones(size(mask));
imAlpha(isnan(mask))=0;
% set(gca,'color',0*[1 1 1]);

%looping through all interferograms
%CAREFUL, time taken will depend on # of ints and processing power

for i=38:40
    figure('Name',strcat("Alpha value = ",num2str(alpha)));
    tiledlayout(2,2)
    nexttile
    % INT FIG w/ MASK %
    imagesc(angle(ints(:,:,i).*mask).','AlphaData',imAlpha')
    title(['Wrapped Interferogram #',num2str(i)],[date_pair{1,i},' - ', date_pair{2,i}])
    colorbar
    % probably a better way to do this, but setting manually lat/lon
    % will need to change this depending on your region
    %set(gca,'XTick',[378 756 1134 1512 1890])      %~pixel values corresponding to long.
    %set(gca,'XTickLabel',[-153.79 -153.37 -152.95 -152.53 -152.11])
    %set(gca,'YTick',[254 508 762 1016])      %~pixel values corresponding to lat.
    %set(gca,'YTickLabel',[70.81 70.67 70.53 70.38])
    %xlabel('Longitude')
    %ylabel('Latitude')

    % COH FIG %
    nexttile
    imagesc(coh(:,:,i).')
    title(['Coherence #',num2str(i)],[date_pair{1,i},' - ', date_pair{2,i}])
    colorbar
    % probably a better way to do this, but setting manually lat/lon
    % will need to change this depending on your region
    %set(gca,'XTick',[378 756 1134 1512 1890])      %~pixel values corresponding to long.
    %set(gca,'XTickLabel',[-153.79 -153.37 -152.95 -152.53 -152.11])
    %set(gca,'YTick',[254 508 762 1016])      %~pixel values corresponding to lat.
    %set(gca,'YTickLabel',[70.81 70.67 70.53 70.38])
    %xlabel('Longitude')
    %ylabel('Latitude')

    % UNW PHASE w/ MASK %
    nexttile
    imagesc((unw_phase(:,:,i).*mask).','AlphaData',imAlpha')
    title(['Unwrapped Phase #',num2str(i)],[date_pair{1,i},' - ', date_pair{2,i}])
    colorbar
    xlabel(colorbar, '[cm]')
    % probably a better way to do this, but setting manually lat/lon
    % will need to change this depending on your region
    %set(gca,'XTick',[378 756 1134 1512 1890])      %~pixel values corresponding to long.
    %set(gca,'XTickLabel',[-153.79 -153.37 -152.95 -152.53 -152.11])
    %set(gca,'YTick',[254 508 762 1016])      %~pixel values corresponding to lat.
    %set(gca,'YTickLabel',[70.81 70.67 70.53 70.38])
    %xlabel('Longitude')
    %ylabel('Latitude')
    % was plotting points (representing ice core sites) on top of image
    %axis on
    %hold on
    %plot(346, 403, 'rx','Linewidth', 2,'MarkerSize',10)
    %plot(514, 386, 'rx','Linewidth', 2,'MarkerSize',10)
    %plot(418, 360, 'rx','Linewidth', 2,'MarkerSize',10)
    %plot(192, 298, 'rx','Linewidth', 2,'MarkerSize',10)
    %plot(235, 370, 'wx','Linewidth', 2,'MarkerSize',10)
    %plot(264, 374, 'wx','Linewidth', 2, 'MarkerSize',10)
    %plot(276, 161, 'wx','Linewidth', 2,'MarkerSize',10)
    %plot(275, 161, 'wx','Linewidth', 2,'MarkerSize',10)
    %plot(1123, 694, 'rx','Linewidth', 2,'MarkerSize',10)
    
    % this is setting limits on the color bar (helpful to bring bounds in)
    stats_array = squeeze(unw_phase(:,:,i).*mask);
    row_stats_array = (stats_array(:));

    percent5 = prctile(row_stats_array,5);
    percent95 = prctile(row_stats_array,95);
    clim([percent5 percent95])

    % UNW PHASE HISTOGRAM DISTRIBUTION %
    nexttile
    histogram((unw_phase(:,:,i).*mask).')
    title(['Unwrapped Phase Distribution #',num2str(i)],[date_pair{1,i},' - ', date_pair{2,i}])
    set(gcf, 'Position', get(0, 'Screensize')); %forcing  automatic full screen resolution
    %figure
end
