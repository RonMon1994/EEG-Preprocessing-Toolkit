function process_GO_epochs(fileList, cleanFolder_GO, thresh_amp, thresh_sd, thresh_resp)
    % This function processes EEG files specifically for GO epochs by applying comprehensive filtering, baseline correction,
    % and artifact rejection based on amplitude, standard deviation, and reaction times. Cleaned and refined epochs are then
    % saved in condition-specific subdirectories within the designated directory, facilitating further analysis.
    %
    % Inputs:
    %   fileList - Cell array of strings, each string representing the full path to an EEG .set file to be processed.
    %   cleanFolder_GO - String specifying the base directory where processed files will be organized and saved.
    %   thresh_amp - Numeric threshold for amplitude-based artifact rejection to eliminate abnormal signal spikes.
    %   thresh_sd - Numeric threshold for standard deviation in amplitude to identify and reject noisy epochs.
    %   thresh_resp - Numeric threshold for reaction time in milliseconds to filter out epochs with delayed responses.
    %
    % Usage:
    %   fileList = {'/path/to/data1_SIT.set', '/path/to/data2_WALK.set'};
    %   cleanFolder_GO = '/path/to/cleaned/GO_data';
    %   process_GO_epochs(fileList, cleanFolder_GO, 100, 3, 300);  % Example thresholds to illustrate setup
    %
    % The function first determines the experimental condition (e.g., SIT, WALK) from each file's path to ensure proper
    % categorization. It then loads the EEG dataset, extracts the 'GO' epochs based on predefined triggers, applies baseline
    % correction, and uses specified thresholds to reject epochs that exceed the set limits for amplitude and standard deviation.
    % Additionally, epochs not meeting the reaction time criteria are filtered out. Successful processing results in the storage
    % of the cleaned epochs in condition-specific folders.
    %
    % Author: Ron Montaoriano
    % Date: 15.04.2024
    % Revision: 1.3
    % MATLAB version used for development: R2023b

    for i = 1:length(fileList)
        filePath = fileList{i}; % Full path to the EEG .set file
        [~, setName, ~] = fileparts(filePath); % Extract the base name for use in the processed file name
        
        % Determine the condition based on the filePath for folder categorization
        condition = '';
        if contains(filePath, 'SIT', 'IgnoreCase', true)
            condition = 'SIT';
        elseif contains(filePath, 'WALK', 'IgnoreCase', true)
            condition = 'WALK';
        else
            warning('Condition (SIT or WALK) could not be determined from the file path: %s', filePath);
            continue;  % Skip this file if the condition is not determinable
        end

        % Define the condition-specific subfolder
        conditionFolder = fullfile(cleanFolder_GO, condition);
        if ~exist(conditionFolder, 'dir')
            mkdir(conditionFolder);  % Create the folder if it does not exist
        end

        % Load the dataset
        EEG = pop_loadset('filename', filePath);
        
        % Perform epoching for GO trials
        EEG_GO = pop_epoch(EEG, {'Go-2', 'GO-2'}, [-0.25 1], 'newname', 'processed epochs', 'epochinfo', 'yes');
        EEG_GO = pop_rmbase(EEG_GO, [EEG_GO.xmin*1000 0], []);
        EEG_GO = pop_autorej(EEG_GO, 'nogui', 'on', 'threshold', thresh_amp, 'startprob', thresh_sd, 'eegplot', 'off');
        EEG_GO_filtered = filter_epochs_GO(EEG_GO, thresh_resp);
        
        % Save the processed data
        if ~isempty(EEG_GO_filtered)
            cleanName_GO = [setName, '_GO_filtered.set'];  % Construct filename for the processed epochs
            pop_saveset(EEG_GO_filtered, 'filename', cleanName_GO, 'filepath', conditionFolder);
            fprintf('Processed and saved GO epochs for %s in %s\n', setName, conditionFolder);
        else
            fprintf('No epochs remained after filtering for %s\n', setName);
        end
    end
end