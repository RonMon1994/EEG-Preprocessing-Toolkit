function perform_ica(fileList, baseCleanFolder)
    % This function applies Independent Component Analysis (ICA) to EEG datasets to identify and label both artifacts
    % and brain sources within the EEG signals. After processing, the datasets are saved in a structured manner within 
    % subdirectories organized by experimental conditions inferred from the file names. This function is crucial for 
    % the preprocessing pipeline, facilitating the isolation of clean EEG data for subsequent analyses.
    %
    % Inputs:
    %   fileList - A cell array containing strings; each string is the full path to an EEG .set file.
    %   baseCleanFolder - A string specifying the base directory under which the processed files will be organized 
    %                     and saved according to their experimental condition.
    %
    % The function leverages a predefined ICA stopping criterion to ensure the algorithm's convergence and robustness.
    % Additionally, it uses ICLabel to automatically classify the independent components, aiding in the efficient
    % identification of artifacts and brain signals.
    %
    % Example usage:
    %   perform_ica({'/data/subject1_SIT.set', '/data/subject2_WALK.set'}, '/processed_data');
    %
    % Author: Ron Montaoriano
    % Date: 15.02.2024
    % Revision: 1.0
    % MATLAB version used for development: R2023b

    criteria = 1E-10; % ICA stopping criteria for algorithm convergence

    % Iterate over each file in the list
    for i = 1:length(fileList)
        filePath = fileList{i}; % Full path to the current .set file
        
        % Extract the base file name for use in creating the processed file name
        [~, setName, ~] = fileparts(filePath); % Extract file name without extension
        
        % Determine the experimental condition from the file path for organized processing and storage
        if contains(filePath, 'SIT', 'IgnoreCase', true)
            condition = 'SIT';
        elseif contains(filePath, 'WALK', 'IgnoreCase', true)
            condition = 'WALK';
        else
            % If the condition cannot be determined, throw an error and halt processing
            error('Condition (SIT or WALK) could not be determined from the file path: %s', filePath);
        end
        
        % Set the path to the condition-specific folder where the processed file will be saved
        cleanFolder = fullfile(baseCleanFolder, condition);
        
        % Create the condition-specific folder if it does not already exist
        if ~exist(cleanFolder, 'dir')
            mkdir(cleanFolder);
        end
        
        % Name for the file after ICA processing, indicating the processing step has been applied
        cleanName = [setName, '_ICA.set'];

        % Load the dataset from the specified file path
        EEG = pop_loadset('filename', filePath);
        EEG.history = [EEG.history, newline, 'loaded file: ', filePath];
        EEG = eeg_checkset(EEG);
        rng(42);

        % Perform ICA to decompose the EEG signals into independent components
        EEG = pop_runica(EEG, 'icatype', 'runica', 'extended', 1, 'stop', criteria, 'interrupt', 'on');
        
        % Automatically label the ICA components using ICLabel for later artifact rejection or analysis
        EEG = pop_iclabel(EEG, 'default');

        % Save the processed EEG dataset with ICA applied in the specified clean folder
        pop_saveset(EEG, 'filename', cleanName, 'filepath', cleanFolder);
        
        % Print a summary message indicating the processing completion and file saving
        fprintf('ICA processed and saved: %s\n', fullfile(cleanFolder, cleanName));
    end
end
