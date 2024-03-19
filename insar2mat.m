%% Accessing InSAR Data Using MATLAB - Function
% * Author:                  Miranda Holloway
% * Date:                    Created 3/19/2023, Last Edited 3/19/2024
%
% This code is originally adapted from post_process_data_ascending.m
% written by Dr. Roger Michaelides and InSAR_to_MATLAB.m written by Miranda
% Holloway.

close all;
clc;
clearvars;

%% Testing function code

amp = 1;
cc = 1;
int = 1;
unw = 1;

filepath = 'C:\Users\mmpho\sent_test\';
fldr = 'subdir1';

addpath(strcat(filepath,fldr));

% Read dem.rsc to get image size
dat = split(fileread(strcat(filepath,fldr,'\dem.rsc')));
dem_rsc = cell(((length(dat)-1)/2),2);
idx = 1;
for i = 1:(length(dat) - 1)
    if (mod(i,2) == 0)
        % Index is even
        % Value itself
        dem_rsc{idx,2} = str2double(dat{i});
        idx = idx + 1;
    else
        % Index is odd
        % Value title
        dem_rsc{idx,1} = dat{i};
    end
end

% Define image size
% Values taken from dem.rsc
nr = dem_rsc{1,2}; % number of x (range) pixels (WIDTH in dem.rsc)
naz = dem_rsc{2,2}; % number of y (azimuth) pixels (FILE_LENGTH in dem.rsc)

cells2 = importdata('sbas_list');
N2 = length(cells2);


%% Function to do this

function done = insar2mat(dir)
    addpath(strcat('C:\Users\mmpho\sent_test\',dir));

    % Read dem.rsc to get image size
    fid = fopen('dem.rsc');
    dat = fscanf(fid,'%s %f');
    
    format_spec = '%s %f';

    done = 1;
end