%% Accessing InSAR Data Using MATLAB
% * Author:                  Miranda Holloway
% * Date:                    Created 3/18/2023, Last Edited 3/18/2024
%
% This code is originally adapted from post_process_data_ascending.m
% written by Dr. Roger Michaelides.

close all;
clc;
clearvars;

%% Load all of the InSAR files you are considering

% Add in the filepath to the folder containing our data
fldr = 'subdir1'; %%%%% CHANGE THIS TO THE NAME OF THE FOLDER YOU WANT
addpath(strcat('C:\Users\mmpho\sent_test\',fldr)); % I store all relevant InSAR data in subdirectories under the main directory 'sent_test''

% Don't think we need this?
% [A geoR]=geotiffread('20200717_20200810.tif');

% Define image size
% Values taken from dem.rsc
nr = 7200; % number of x (range) pixels (WIDTH in dem.rsc)
naz = 3600; % number of y (azimuth) pixels (FILE_LENGTH in dem.rsc)

n = 16; % number of SLCs

% Read in interferogram .out files
Bperp0 = load('Bperp.out');
Tm0 = load('Tm.out');
deltime0 = load('deltime.out');
timedeltas0 = load('timedeltas.out');

Bperp1=zeros(size(Bperp0));
Tm1=zeros(size(Tm0));
deltime1=zeros(size(deltime0));

cells2 = importdata('sbas_list');
N2=length(cells2);

sbas_dates0 = string(cells2.textdata);
sbas_data0 = string(cells2.data);
cells = importdata('intlist');
N = length(cells);
lambda = 5.6; % wavelength %%%%%%%%%%%%%%%%%%%%%% WHAT IS THIS FOR US??

unw_phase=zeros(nr,naz,N);
%uni=zeros(nr,naz,N);
amps=zeros(nr,naz,N);
ints=zeros(nr,naz,N);
coh=zeros(nr,naz,N);
%uni=zeros(nr,naz,N);
date_pair=cell(2,N);
doy_pair=cell(2,N);

% Read in the unwrapped phase (unw), coherence (coh), amplitude (amp) and
% unimodally-corrected unwrapped phase (uni)
for i=1:N
    disp(i)
    strint = cells{i};
    strint1 = strcat('ints/',strint);
    strunw1 = strrep(strint,'.int','.unw');
    strunw = strcat('unws/',strunw1);
    stramp1 = strrep(strint,'.int','.amp');
    stramp = strcat('amps/',stramp1);
    strcc1 = strrep(strint,'.int','.cc');
    strcc = strcat('ccs/',strcc1);
    struni1 = strrep(strint,'.int','.int');
    struni = strcat('ints/',struni1);

    % Correlations
    filename_c=sprintf('%s',strcc);
    fid=fopen(filename_c);
    dat=fread(fid,[2*nr,inf],'float','ieee-le');
    temp=dat((nr+1):end,:);
    coh(:,:,i)=temp;
    fclose(fid);

    % Unwrapped phase
    filename=sprintf('%s',strunw);
    fid=fopen(filename);
    dat=fread(fid,[2*nr,inf],'float','ieee-le');
    temp=dat(nr+1:end,:);
    unw_phase(:,:,i)=temp;
    fclose(fid);
    
    % Interferograms
    filename=sprintf('%s',struni);
    fid=fopen(filename);
    dat=fread(fid,[2*nr,inf],'float','ieee-le');
    temp=dat(1:2:end,1:naz)+1i*dat(2:2:end,1:naz);
    phase(:,:,i)=temp;
    fclose(fid);
    
    % Amplitude
    filename=sprintf('%s',strint1);
    fid=fopen(filename);
    dat=fread(fid,[2*nr,inf],'float','ieee-le');
    temp=dat(1:2:2*nr-1,:)+1i*dat(2:2:2*nr,:);
    ints(:,:,i)=temp;
    fclose(fid);
    
    % Amplitude
    filename=sprintf('%s',stramp);
    fid=fopen(filename);
    dat=fread(fid,[2*nr,inf],'float','ieee-le');
    temp=dat(1:2:2*nr-1,:)+1i*dat(2:2:2*nr,:);
    amps(:,:,i)=temp;
    fclose(fid);
    
    % Date information
    split1=strsplit(strint,'_');
    strint2=split1{2};
    split2=strsplit(strint2,'.');
    d1=split1{1};
    d2=split2{1};

    date1=strcat(d1(5:6),'/',d1(7:8),'/',d1(1:4));
    date2=strcat(d2(5:6),'/',d2(7:8),'/',d2(1:4));

    date1_vec=datetime(date1,'InputFormat','MM/dd/yyyy');
    date2_vec=datetime(date2,'InputFormat','MM/dd/yyyy');

    doy1=day(date1_vec,'dayofyear');
    doy2=day(date2_vec,'dayofyear');

    date_pair{1,i}=date1;
    date_pair{2,i}=date2;
    doy_pair{1,i}=doy1;
    doy_pair{2,i}=doy2;
end