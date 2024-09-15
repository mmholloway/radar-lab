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
subdir = 'subdir_100m';

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

amps = amps.amps;
coh = coh.coh;
date_pair = date_pair.date_pair;
doy_pair = doy_pair.doy_pair;
ints = ints.ints;
phase = phase.phase;
unw_phase = unw_phase.unw_phase;
N = size(doy_pair,2);

%% Get an average coherence file
avecc = mean(coh,3);
cor_mask = avecc;
% alpha = 0.17; % 0.15 clears out bottom of river and lakes in top LH corner well but doesn't clean river in top RH corner - maybe 0.17 is a bit too much too
alpha = 1e-5;
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
no_x_tix = 7;
no_y_tix = 5;
[pix, labels] = igram_latlong(subdir,no_x_tix,no_y_tix);
no_x_tix = no_x_tix + 1;
no_y_tix = no_y_tix + 1;

% if (~isfolder('IG Error Plots'))
%     mkdir('IG Error Plots');
% end

for i=[17 35 44]
    fig = figure('Name',strcat("Alpha value = ",num2str(alpha)));
    tiledlayout(2,2)
    nexttile
    % INT FIG w/ MASK %
    imagesc(angle(ints(:,:,i).*mask).','AlphaData',imAlpha')
    title(['Wrapped Interferogram #',num2str(i)],[date_pair{1,i},' - ', date_pair{2,i}])
    colorbar
    % probably a better way to do this, but setting manually lat/lon
    % will need to change this depending on your region
    set(gca,'XTick',pix(1,1:no_x_tix))      %~pixel values corresponding to long.
    set(gca,'XTickLabel',labels(1,1:no_x_tix))
    set(gca,'YTick',pix(2,1:no_y_tix))      %~pixel values corresponding to lat.
    set(gca,'YTickLabel',labels(2,1:no_y_tix))
    xlabel('Longitude (degrees)')
    ylabel('Latitude (degrees)')

    % COH FIG %
    nexttile
    imagesc(coh(:,:,i).')
    title(['Coherence #',num2str(i)],[date_pair{1,i},' - ', date_pair{2,i}])
    colorbar
    % probably a better way to do this, but setting manually lat/lon
    % will need to change this depending on your region
    set(gca,'XTick',pix(1,1:no_x_tix))      %~pixel values corresponding to long.
    set(gca,'XTickLabel',labels(1,1:no_x_tix))
    set(gca,'YTick',pix(2,1:no_y_tix))      %~pixel values corresponding to lat.
    set(gca,'YTickLabel',labels(2,1:no_y_tix))
    xlabel('Longitude (degrees)')
    ylabel('Latitude (degrees)')

    % UNW PHASE w/ MASK %
    nexttile
    imagesc((unw_phase(:,:,i).*mask).','AlphaData',imAlpha')
    title(['Unwrapped Phase #',num2str(i)],[date_pair{1,i},' - ', date_pair{2,i}])
    colorbar
    xlabel(colorbar, '[cm]')
    % probably a better way to do this, but setting manually lat/lon
    % will need to change this depending on your region
    set(gca,'XTick',pix(1,1:no_x_tix))      %~pixel values corresponding to long.
    set(gca,'XTickLabel',labels(1,1:no_x_tix))
    set(gca,'YTick',pix(2,1:no_y_tix))      %~pixel values corresponding to lat.
    set(gca,'YTickLabel',labels(2,1:no_y_tix))
    xlabel('Longitude (degrees)')
    ylabel('Latitude (degrees)')

    % % this is setting limits on the color bar (helpful to bring bounds in)
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

    % Save file
    % exportgraphics(fig,strcat('C:\Users\mmpho\OneDrive - Washington University in St. Louis\Year 3\Research_Git\IG Error Plots\',num2str(alpha),'_',num2str(i),'.png'))
    % close;
end
