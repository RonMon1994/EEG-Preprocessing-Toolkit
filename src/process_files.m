function process_files(fileList, baseCleanFolder, chanRejThresh, lineNoiseCriterion)
    % This function automates the preprocessing of EEG files based on channel rejection and line noise criteria. 
    % It organizes the cleaned data by experimental conditions, which are inferred from the filenames (e.g., 'SIT', 'WALK'). 
    % The processed files are then saved within condition-specific subfolders in the specified base directory.
    %
    % Inputs:
    %   fileList - Cell array containing paths to EEG files to be processed.
    %   baseCleanFolder - Directory path where processed files are saved.
    %   chanRejThresh - Threshold value for channel rejection.
    %   lineNoiseCriterion - Threshold value for line noise rejection.
    %
    % The function scans each file, applies the specified preprocessing criteria, and saves the cleaned files into organized subfolders corresponding to their experimental conditions.
    %
    % Example usage:
    %   process_files({'/data/subject1_SIT.set', '/data/subject2_WALK.set'}, '/processed_data', 0.8, 4);
    %
    % Dependencies:
    %   pop_saveset - Function from EEGLAB used for saving the set files after processing.
    %   remove_chans - Hypothetical custom function for channel removal (should be replaced with actual processing function).
    %
    % Note:
    %   Ensure that 'pop_saveset' and any other processing functions (e.g., a real 'remove_chans') are available in the path.
    %
    % Author: Ron Montaoriano
    % Date: 15.02.2024
    % Revision: 1.0
    % MATLAB version used for development: R2023b

    % Initialize an array to store the number of channels removed from each file
    len_removed = zeros(length(fileList), 1);
    
    for i = 1:length(fileList)
        filePath = fileList{i}; % Full path to the current EEG file
        
        % Determine the experimental condition based on the file name
        condition = '';
        if contains(filePath, 'sit') %%% SIT
            condition = 'SIT';
        elseif contains(filePath, 'walk')
            condition = 'WALK';
        end

        % Ensure that a condition has been determined
        if isempty(condition)
            error('Condition could not be determined from the file path: %s', filePath);
        end
        
        % Define the path to the folder where the processed file will be saved, based on the condition
        cleanFolder = fullfile(baseCleanFolder, condition);

        % Create the condition-specific folder if it does not exist
        if ~exist(cleanFolder, 'dir')
            mkdir(cleanFolder); % This ensures that the directory structure is ready for file saving
        end

        % Extract the file name and extension from the full path
        [~, setName, ext] = fileparts(filePath);
        cleanName = [setName, '_chans', ext]; % Append a suffix to indicate that channels have been processed

        % Process the EEG data, applying channel rejection and line noise filtering
        % Here, remove_chans is a placeholder for actual data processing function you might use
        EEG_chans = remove_chans(filePath, chanRejThresh, lineNoiseCriterion);

        % Record the number of channels removed, if applicable
        if isfield(EEG_chans, 'first_removed_chans')
            len_removed(i) = length(EEG_chans.first_removed_chans);
        else
            len_removed(i) = 0;
        end

        % Save the processed EEG data to the designated clean folder
        outputPath = fullfile(cleanFolder, cleanName);
        pop_saveset(EEG_chans, 'filename', cleanName, 'filepath', cleanFolder);
    end
    
    % Display a summary of the processing
    fprintf('Processed %d files. Data saved in %s folder.\n', length(fileList), baseCleanFolder);
end
