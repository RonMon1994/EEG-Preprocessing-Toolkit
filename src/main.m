% Unified EEG Preprocessing Script for EEGLAB
% This script automates the entire EEG preprocessing workflow using EEGLAB, aimed at preparing EEG data for further analysis. The workflow includes initial data cleaning, channel rejection, ICA for artifact identification and removal, and condition-specific epoch extraction for experimental conditions such as GO and NOGO. The script supports comprehensive data handling from raw input through to the preparation of data for ERP analysis, ensuring robust artifact handling and data integrity.
%
% Author: Ron Montaoriano
% Date: 04.04.2024
% Revision: 2.0
% MATLAB version used for development: R2023b
%
% The script performs the following main steps:
% 1. Initial Setup: Prepares the MATLAB environment and initializes EEGLAB without the GUI.
% 2. Global Parameters Definition: Sets thresholds for data cleaning and paths for file management.
% 3. Initial Preprocessing: Filters out noisy channels and prepares data for ICA.
% 4. Perform ICA: Applies Independent Component Analysis to identify and label artifact components.
% 5. Artifact Removal: Removes unwanted components based on ICA results.
% 6. Epoch Processing: Segregates the data into meaningful epochs according to experimental conditions.
% 7. ERP Processing: Calculates and stores Event-Related Potentials for further analysis.
%
% The script is structured to facilitate modifications and adjustments as needed for specific dataset requirements or preprocessing preferences.

%% === Initial Setup ===
% Clear the workspace and command window for a clean start
clear; clc;

% Add EEGLAB to MATLAB's search path and initialize it without the GUI
eeglabPath = '/home/ronm/Academic/ThesisResearch/Deep Brain Stimulation Project/eeglab2024.0';
addpath(eeglabPath);
eeglab nogui; % Starts EEGLAB in no GUI mode for script automation

%% === Define Global Parameters ===
% These parameters are crucial for the preprocessing steps that follow
chanRejThresh = 0.8; % Threshold for channel rejection
lineNoiseCriterion = 4; % Threshold for line noise rejection
filePattern = '.+\.set$'; % Regular expression to match EEG data files (.set format)

% Define paths for data at different processing stages
OriginalFolder      = '/media/ronm/Ron_Disk/Raw data_VGNG_HC&PD';
InitialCleaningStep = '/home/ronm/Academic/ThesisResearch/Deep Brain Stimulation Project/ZOYA/ZOYA/InitialCleaningStepfinal';
ICACleaningStep     = '/home/ronm/Academic/ThesisResearch/Deep Brain Stimulation Project/ZOYA/ZOYA/ICACleaningStepfinal';
FinalCleanFolder    = '/home/ronm/Academic/ThesisResearch/Deep Brain Stimulation Project/ZOYA/ZOYA/FinalCleanFolderfinal';

% Paths for saving processed GO and NOGO epochs
cleanFolder_GO   = '/home/ronm/Academic/ThesisResearch/Deep Brain Stimulation Project/ZOYA/ZOYA/cleanFolder_GOfinal2';
cleanFolder_NOGO = '/home/ronm/Academic/ThesisResearch/Deep Brain Stimulation Project/ZOYA/ZOYA/cleanFolder_NOGOfinal2';

% paths for saving ERPs
ERPFolder = '/home/ronm/Academic/ThesisResearch/Deep Brain Stimulation Project/ZOYA/ZOYA/ERPfinal';
%% === Step 1: Initial Preprocessing ===
% Retrieve all EEG .set files from the original data folder
fileList = getAllFiles(OriginalFolder, filePattern); % Custom function to get a list of all files matching the pattern
% Perform initial cleaning and bad channel removal on the retrieved files
process_files(fileList, InitialCleaningStep, chanRejThresh, lineNoiseCriterion); % Custom function for initial data cleaning

%% === Step 2: Perform ICA ===
% Update the file list for the next processing step and perform ICA
fileList = getAllFiles(InitialCleaningStep, filePattern);
perform_ica(fileList, ICACleaningStep); % Custom function to apply ICA and label components

%% === Step 3: Artifact Removal ===
% After ICA, update the file list and remove artifact components based on ICA labels
fileList = getAllFiles(ICACleaningStep, filePattern);
flag_and_remove_artifacts(fileList, FinalCleanFolder); % Custom function to flag and remove artifacts

%% === Epoch Processing ===
% Define additional thresholds for noise filtering and reaction time for epoch processing
thresh_amp = 100; % Amplitude threshold for epoch rejection
thresh_sd = 3; % Standard deviation threshold for epoch rejection
thresh_resp = 100; % Reaction time threshold for GO epochs

% Process GO epochs
fileList_epochs = getAllFiles(FinalCleanFolder, filePattern); % Update the file list for epoch processing
process_GO_epochs(fileList_epochs, cleanFolder_GO, thresh_amp, thresh_sd, thresh_resp); % Custom function to process GO epochs

% Process NOGO epochs
process_NOGO_epochs(fileList_epochs, cleanFolder_NOGO, thresh_amp, thresh_sd); % Custom function to process NOGO epochs

%% === ERP Processing ===


fileList_GO_ERP = getAllFiles(cleanFolder_GO, filePattern); % Update the file list for ERP processing
fileList_NOGO_ERP = getAllFiles(cleanFolder_NOGO, filePattern);


GO_results = processERPFiles(fileList_GO_ERP);
NOGO_results = processERPFiles(fileList_NOGO_ERP);

saveERPResultsToExcel(GO_results, 'ERP_GoResultsfinal.xlsx');
saveERPResultsToExcel(NOGO_results, 'ERP_NoGoResultsfinal.xlsx');

%%
% processEEGAndFFT(cleanFolder_GO)
% allResults = processEEGAndFFT1(cleanFolder_GO);


peak_distance_Hz = 1;         % Separate peaks by at least 1 Hz
min_peak_height_STD = 1.5;    % Detect peaks at 1.5 standard deviations above the mean
plotting = false;              % Enable plotting to inspect the results visually
% processEEGWithFOOOF(cleanFolder_GO, peak_distance_Hz, min_peak_height_STD, plotting)
processEEGWithFOOOF2(cleanFolder_NOGO, peak_distance_Hz, min_peak_height_STD, plotting) % for folder

