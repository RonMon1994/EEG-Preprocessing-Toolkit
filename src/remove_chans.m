function EEG = remove_chans(setPath, chan_criterion, lineNoise_criterion)
    % This function preprocesses an EEG dataset by performing several critical operations: loading the data, 
    % applying filters, removing bad channels based on specified criteria, and re-referencing the data 
    % while excluding specific channels, including a VREF channel. It leverages EEGLAB's functionality to 
    % ensure high-quality preprocessing suitable for subsequent analyses.
    %
    % Inputs:
    %   setPath - String specifying the path to the .set file to be processed.
    %   chan_criterion - Numeric threshold for channel rejection based on statistical properties.
    %   lineNoise_criterion - Numeric threshold for line noise rejection.
    %
    % Output:
    %   EEG - The preprocessed EEGLAB EEG structure, ready for further analysis.
    %
    % Example usage:
    %   EEG = remove_chans('path/to/yourdata.set', 0.8, 4);
    %
    % The function follows these steps:
    % 1. Load the EEG file using the path provided.
    % 2. Apply a basic FIR bandpass filter to the data.
    % 3. Identify and remove bad channels based on the specified criteria.
    % 4. Re-reference the data excluding specified eye channels and the VREF channel.
    % 5. Update EEG history with all performed operations for traceability.
    %
    % Author: Ron Montaoriano
    % Date: 15.02.2024
    % Revision: 1.0
    % MATLAB version used for development: R2023b

    % Load the EEG dataset
    EEG = pop_loadset('filename', setPath);
    history_comment = ['loaded file: ', setPath];
    EEG.history = history_comment;
    EEG = eeg_checkset(EEG);

    % Document the MATLAB version used for processing
    EEG.matlab_version = version;

    % Ensure consistent channel labels across subjects by using the original channel locations
    EEG.chanlocs = EEG.urchanlocs;

    % Apply FIR filter to the data for basic bandpass filtering
    EEG = pop_eegfiltnew(EEG, 'locutoff', 0.5, 'hicutoff', 40);
    EEG.setname = 'FIR';
    history_comment = 'Performed FIR [0.5 40]';
    EEG.history = [EEG.history, newline, history_comment];
    EEG = eeg_checkset(EEG);

    % Remove bad channels based on the provided criteria
    EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion', 'off', 'ChannelCriterion', chan_criterion,...
                            'LineNoiseCriterion', lineNoise_criterion, 'Highpass', 'off',...
                            'BurstCriterion', 'off', 'WindowCriterion', 'off', 'BurstRejection', 'off',...
                            'Distance', 'Euclidian');
    EEG.setname = 'bad channels removed';
    history_comment = ['Removed bad channels with channel criterion: ', num2str(chan_criterion),...
                       ', lineNoise criterion: ', num2str(lineNoise_criterion)];
    EEG.history = [EEG.history, newline, history_comment];
    if isfield(EEG.chaninfo, 'removedchans')
        EEG.first_removed_chans = EEG.chaninfo.removedchans;
    end

    % Apply average reference, excluding specified channels and removing the VREF channel
    labels = {EEG.chanlocs.labels};
    ex_channs = {'EOG1', 'EOG2', 'EOG3', 'EOG4', 'E61', 'E62', 'E63', 'E64', 'VREF'}; % Channels to exclude
    ex_member = ismember(labels, ex_channs);
    ex_idxs = find(ex_member == 1);

    EEG = pop_reref(EEG, [], 'exclude', ex_idxs);
    EEG.setname = 'REF';
    history_comment = 'Averaged reference excluding eye channels and VREF';
    EEG.history = [EEG.history, newline, history_comment];
    EEG.ex_idxs = ex_idxs;
    EEG = eeg_checkset(EEG);

    % Finally, remove the VREF channel if present
    EEG = pop_select(EEG, 'rmchannel', {'VREF'});
    EEG.setname = 'REF64';
    EEG = eeg_checkset(EEG);
    history_comment = 'Removed channel: VREF';
    EEG.history = [EEG.history, newline, history_comment];
    EEG = eeg_checkset(EEG);
end
