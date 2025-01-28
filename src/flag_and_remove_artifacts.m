function flag_and_remove_artifacts(fileList, baseCleanFolder)
    % Automates the process of artifact removal in EEG datasets by applying Independent Component Analysis (ICA) 
    % classifications through ICLabel. The function loads EEG datasets, classifies components using ICLabel, 
    % selectively removes components identified as artifacts, and saves the cleaned datasets in condition-specific folders.
    % This streamlined artifact removal enhances the quality of EEG data for further analysis.
    %
    % Inputs:
    %   fileList - Cell array of strings; each string is the full path to an EEG .set file.
    %   baseCleanFolder - String specifying the base directory under which cleaned files will be saved, organized by condition.
    %
    % Outputs:
    %   None. The function saves the cleaned EEG datasets to disk.
    %
    % Usage:
    %   flag_and_remove_artifacts({'/path/to/data1.set', '/path/to/data2.set'}, '/path/to/cleaned/data');
    %
    % The function uses ICLabel's classification system to identify artifact components such as eye movements, muscle noise,
    % and line noise, and then removes these components to purify the EEG signal. The processed datasets are stored in
    % directories that are named according to the experimental condition identified from the file names, promoting organized data management.
    %
    % Author: Ron Montaoriano
    % Date: 04.04.2024
    % Revision: 1.6
    % MATLAB version used for development: R2023b

    components_removed = []; % Initialize an array to record the number of components removed from each file

    % Iterate through each file in the provided list
    for i = 1:length(fileList)
        filePath = fileList{i}; % Full path to the current .set file
        
        % Extract the base file name for naming the cleaned file
        [~, setName, ~] = fileparts(filePath); 

        % Determine the experimental condition (SIT or WALK) from the file name
        if contains(filePath, 'SIT', 'IgnoreCase', true)
            condition = 'SIT';
        elseif contains(filePath, 'WALK', 'IgnoreCase', true)
            condition = 'WALK';
        else
            % If condition cannot be determined, throw an error
            error('Condition (SIT or WALK) could not be determined from the file path: %s', filePath);
        end

        % Define the condition-specific folder for saving the cleaned file
        cleanFolder = fullfile(baseCleanFolder, condition);

        % Create the condition-specific folder if it does not already exist
        if ~exist(cleanFolder, 'dir')
            mkdir(cleanFolder);
        end

        % Name for the cleaned file indicating artifact removal
        cleanName = [setName, '_processed.set']; 

        % Load the EEG dataset
        EEG = pop_loadset('filename', filePath);
        EEG.history = [EEG.history, newline, 'loaded file: ', filePath];
        EEG = eeg_checkset(EEG);

        % Check for ICLabel classifications and remove identified artifact components
        if isfield(EEG.etc, 'ic_classification') && isfield(EEG.etc.ic_classification, 'ICLabel')
            % Identify artifacts based on ICLabel classifications and a sum threshold
            % artifacts_sums = sum(EEG.etc.ic_classification.ICLabel.classifications(:,2:6), 2);
            % ica_artifacts = find(artifacts_sums > 0.5); % Customize threshold as needed
            EEG = pop_icflag(EEG, [NaN NaN;0.8 1;0.5 1;0.8 1;0.8 1;0.8 1;NaN NaN]); 
            ica_artifacts = find(EEG.reject.gcompreject==1);
            

            % Remove identified artifact components
            EEG = pop_subcomp(EEG, ica_artifacts, 0);
            history_comment = 'ICA + removing components based on ICLabel';
            EEG.history = [EEG.history, newline, history_comment];
            EEG = eeg_checkset(EEG);
            components_removed(i) = length(ica_artifacts); % Record number of components removed
        else
            % If ICLabel classifications are not found, issue a warning
            warning('%s does not have ICLabel classifications. Skipping IC artifact removal.', setName);
            components_removed(i) = 0; % Record that no components were removed
        end

        % Optionally remove specified channels
        EEG = pop_select(EEG, 'nochannel', {'EOG1', 'EOG2', 'EOG3', 'EOG4', 'E61', 'E62', 'E63', 'E64'});
        EEG.history = [EEG.history, newline, 'Removed specified channels'];
        EEG = eeg_checkset(EEG);

        % Save the cleaned EEG dataset in the condition-specific folder
        pop_saveset(EEG, 'filename', cleanName, 'filepath', cleanFolder);
        fprintf('Artifact removal and saving: %s\n', fullfile(cleanFolder, cleanName)); % Output processing summary
    end
end
