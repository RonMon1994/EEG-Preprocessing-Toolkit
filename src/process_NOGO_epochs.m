function process_NOGO_epochs(fileList, cleanFolder_NOGO, thresh_amp, thresh_sd)
    % This function specifically processes EEG files for NOGO epochs by applying detailed filtering,
    % baseline correction, and automatic rejection based on amplitude and standard deviation thresholds.
    % The resulting clean epochs are then saved into condition-specific subdirectories to maintain organized data.
    %
    % Inputs:
    %   fileList - Cell array containing the full paths to EEG .set files to be processed.
    %   cleanFolder_NOGO - Directory path where the processed files will be categorized and stored.
    %   thresh_amp - Numeric value specifying the amplitude threshold for automatic rejection of noisy epochs.
    %   thresh_sd - Numeric value specifying the standard deviation threshold for identifying and rejecting outlier epochs.
    %
    % The function first determines the experimental condition from each file name, ensuring appropriate data segmentation.
    % It then performs epoching around NOGO events, applies baseline corrections, and utilizes set thresholds to reject
    % epochs that do not meet quality standards. Optionally, further custom filtering can be applied to refine the epochs
    % further before saving the clean data.
    %
    % Example Usage:
    %   fileList = {'/path/to/EEG1_SIT.set', '/path/to/EEG2_WALK.set'};
    %   cleanFolder_NOGO = '/path/to/processed/NOGO';
    %   process_NOGO_epochs(fileList, cleanFolder_NOGO, 100, 3);
    %
    % Author: Ron Montaoriano
    % Date: 15.04.2024
    % Revision: 1.3
    % MATLAB version used for development: R2023b

    for i = 1:length(fileList)
        filePath = fileList{i};  % Get full path to each .set file in the list
        [~, setName, ~] = fileparts(filePath);  % Extract the base file name

        % Determine the experimental condition from the file name
        condition = '';
        if contains(filePath, 'SIT', 'IgnoreCase', true)
            condition = 'SIT';
        elseif contains(filePath, 'WALK', 'IgnoreCase', true)
            condition = 'WALK';
        else
            warning('Condition (SIT or WALK) could not be determined from the file path: %s', filePath);
            continue;  % Skip this file if the condition is not determinable
        end

        % Define the condition-specific subfolder within the NOGO directory
        conditionFolder = fullfile(cleanFolder_NOGO, condition);
        if ~exist(conditionFolder, 'dir')
            mkdir(conditionFolder);  % Create the folder if it does not exist
        end

        % Load the EEG data set from the file
        EEG = pop_loadset('filename', filePath);

        % Epoching for NOGO trials with a specific time window around the event
        EEG_NOGO = pop_epoch(EEG, {'NG-2', 'Ng-2'}, [-0.25 1], 'newname', 'processed epochs', 'epochinfo', 'yes');
        % Remove baseline using the time from start of the epoch to 0 ms
        EEG_NOGO = pop_rmbase(EEG_NOGO, [EEG_NOGO.xmin*1000 0], []);
        % Automatically reject epochs with excessive noise
        EEG_NOGO = pop_autorej(EEG_NOGO, 'nogui', 'on', 'threshold', thresh_amp, 'startprob', thresh_sd, 'eegplot', 'off');
        
        % Additional custom filtering function might be used here
        EEG_NOGO_filtered = filter_epochs_NOGO(EEG_NOGO);  % Assume filter_epochs_NOGO exists to further refine epochs
        
        % Save the processed EEG data only if non-empty after filtering
        if ~isempty(EEG_NOGO_filtered)
            cleanName_NOGO = [setName, '_NOGO_filtered.set'];  % Construct the file name with a specific suffix
            pop_saveset(EEG_NOGO_filtered, 'filename', cleanName_NOGO, 'filepath', conditionFolder);
            fprintf('Processed and saved NOGO epochs for %s in %s\n', setName, conditionFolder);
        end
    end
end
