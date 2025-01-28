function results = processERPFiles(fileList_ERP)
    % This function processes ERP files to calculate P3 and N2 components for specified electrodes
    % within EEG datasets. The function identifies relevant time windows for each component based on the EEG data
    % and computes the mean ERP values within those windows. The results are structured by subject and condition,
    % providing a comprehensive analysis of cognitive response markers across different experimental settings.
    %
    % Inputs:
    %   fileList_ERP - A cell array containing paths to EEG .set files for ERP analysis.
    %
    % Outputs:
    %   results - A structure array containing calculated P3 and N2 values, along with associated metadata
    %             such as subject type, assignment type, and subject ID, organized by electrode.
    %
    % The function initializes by setting up electrode labels, loading the first EEG file to establish
    % the time indices, and defining windows for P3 and N2 component analysis. It then iterates through
    % each file, extracting necessary subject and condition information, and calculates the ERP components
    % for selected electrodes using specific time windows defined earlier.
    %
    % Example Usage:
    %   fileList = {'/path/to/data1.set', '/path/to/data2.set'};
    %   results = processERPFiles(fileList);
    %
    % Author: Ron Montaoriano
    % Date: 15.04.2024
    % Revision: 1.0
    % MATLAB version used for development: R2023b

    % Define electrode labels and initialize results structure
    electrodeLabels = {'E6', 'E34','Fz','Pz'};
    results = struct();

    % Load the first file to setup time indices
    EEG = pop_loadset('filename', fileList_ERP{1});
    x = EEG.times;  % the time axis from -0.25s to 1s
    zero_i = find(x == 0);
    time_i = zero_i:length(x); % time axis from 0s to 1s
    time = x(time_i);
    
    % Setup P3 and N2 calculation windows
    [~, P3_time_start] = min(abs(250 - time));  % 250 - 500 ms
    [~, P3_time_end] = min(abs(500 - time));
    P3_times = [P3_time_start, P3_time_end];
    
    [~, N2_time_start] = min(abs(200 - time));  % 200 - 350 ms
    [~, N2_time_end] = min(abs(350 - time));
    N2_times = [N2_time_start, N2_time_end];

    % Iterate through each file in the list
    for i = 1:length(fileList_ERP)
        % Load EEG data
        EEG = pop_loadset('filename', fileList_ERP{i});
        
        % Parse assignment type and subject type from filename
        [assignmentType, subjectType, subjectID] = parseFilename(fileList_ERP{i});
        
        % Find electrode indices
        electrodeIndices = find(ismember({EEG.chanlocs.labels}, electrodeLabels));

        % Process each electrode
        for idx = electrodeIndices
            % Calculate mean ERP
            ERP = mean(EEG.data(idx, :, :), 3);

            % Calculate P3 and N2 using calc_P3N2_aroundPeakDip function
            results(i).assignmentType = assignmentType;
            results(i).subjectType = subjectType;
            results(i).subjectID = subjectID;
            results(i).(EEG.chanlocs(idx).labels) = calc_P3N2_aroundPeakDip(ERP, P3_times, N2_times, 100, time);
        end
    end
end

function [assignmentType, subjectType, subjectID] = parseFilename(filename)
    % Parses the filename to extract assignment type (e.g., SIT or WALK), subject type (e.g., HC or PD), and a unique subject ID.
    % This function is crucial for categorizing EEG data files in studies where filenames encode experimental conditions and participant details.
    %
    % Inputs:
    %   filename - A string containing the full path or name of the EEG data file.
    %
    % Outputs:
    %   assignmentType - A string representing the assignment type extracted from the filename ('SIT', 'WALK', or 'UNKNOWN').
    %   subjectType - A string representing the subject type extracted from the filename ('HC', 'PDM', 'PD', or 'UNKNOWN').
    %   subjectID - A string representing the subject ID extracted from the filename, typically following a convention like 'HC001'.
    %
    % The function first checks for assignment type keywords ('SIT', 'WALK'). If neither is found, it defaults to 'UNKNOWN'.
    % It then looks for subject type indicators ('HC', 'PDM', 'PD'), again defaulting to 'UNKNOWN' if none match.
    % Finally, it attempts to extract a numeric subject ID based on known prefixes ('HC', 'PDM_', 'PDM', 'PD').
    %
    % Example Usage:
    %   [type, subtype, id] = parseFilename('path/to/EEGfile_SIT_HC001.set');
    %   % Returns: type = 'SIT', subtype = 'HC', id = '001'
    %
    % Author: Ron Montaoriano
    % Date: 15.04.2024
    % Revision: 1.0
    % MATLAB version used for development: R2023b

    % Extract assignment type (SIT or WALK) and subject type (HC or PD) from filename
    if contains(filename, 'SIT')
        assignmentType = 'SIT';
    elseif contains(filename, 'WALK')
        assignmentType = 'WALK';
    else
        assignmentType = 'UNKNOWN';
    end
    
    if contains(filename(end-80:end), 'HC')
        subjectType = 'HC';
    elseif contains(filename(end-80:end), 'PDM')
        subjectType = 'PDM';
    elseif contains(filename(end-80:end), 'PD')
        subjectType = 'PD';
    else
        subjectType = 'UNKNOWN';
    end

    % Extract subject ID (assuming it follows HC or PD in the filename, e.g., HC001 or PD002)
    subjectIDPattern = '(HC|PDM_|PDM|PD)\d+';
    subjectIDMatches = regexp(filename(end-80:end), subjectIDPattern, 'match');
    if ~isempty(subjectIDMatches)
        subjectID = subjectIDMatches{1}(end-2:end);
    else
        subjectID = 'UNKNOWN';
    end
end

function timepoints = calc_P3N2_aroundPeakDip(EEG_data, P3_times, N2_times, calc_window, time)
    % This function calculates the P3 and N2 ERP components around their respective peak and dip points
    % within specified time windows. It uses envelope methods to accurately pinpoint these features in the EEG data.
    %
    % Inputs:
    %   EEG_data - A vector of EEG data from a single electrode.
    %   P3_times - Indices [start, end] defining the time window for the P3 component calculation.
    %   N2_times - Indices [start, end] defining the time window for the N2 component calculation.
    %   calc_window - The time window in milliseconds around the peak or dip to average the data.
    %   time - A vector of time points corresponding to EEG data indices, used for latency calculations.
    %
    % Outputs:
    %   timepoints - A structure containing calculated values and latencies for P3 and N2 components:
    %       .P3 - Mean amplitude of the P3 component within the specified window.
    %       .P3_latency - [start, end] indices for the P3 component within the total recording.
    %       .P3_latency_point - The index point of maximum P3 within its window.
    %       .P3_latency_ms - Time in milliseconds of the peak P3 point relative to the start of the time window.
    %       .N2 - Mean amplitude of the N2 component within the specified window.
    %       .N2_latency - [start, end] indices for the N2 component within the total recording.
    %       .N2_latency_point - The index point of minimum N2 within its window.
    %       .N2_latency_ms - Time in milliseconds of the dip N2 point relative to the start of the time window.
    %
    % Example usage:
    %   EEG_data = eeg_data_channel;  % e.g., data from channel Fz
    %   P3_window = [250, 500];  % time indices for P3
    %   N2_window = [200, 350];  % time indices for N2
    %   calc_window = 100;  % milliseconds around the peak/dip for averaging
    %   time_vector = EEG.times;  % vector of time points
    %   results = calc_P3N2_aroundPeakDip(EEG_data, P3_window, N2_window, calc_window, time_vector);
    %
    % The function utilizes the envelope method to find peaks (P3) and dips (N2) within the specified
    % windows and calculates the mean amplitude around these points, providing valuable metrics for ERP analysis.


    % Calculate P3 and N2 around peak and dip using specified windows
    window_s = calc_window / 4; % converting ms to timepoints assuming 250 Hz
    data = EEG_data;  % assuming data is a vector from a single electrode
    
    % Envelope calculation
    [envHigh, envLow] = envelope(data, 1, 'peak');
    
    % Find P3
    [max_P3, max_P3_i] = max(envHigh(P3_times(1):P3_times(2)));
    P3_start = P3_times(1) + max_P3_i - window_s;
    P3_end = P3_times(1) + max_P3_i + window_s;
    
    % Find N2
    [min_N2, min_N2_i] = min(envLow(N2_times(1):N2_times(2)));
    N2_start = N2_times(1) + min_N2_i - window_s;
    N2_end = N2_times(1) + min_N2_i + window_s;

    % Store results
    timepoints.P3 = mean(data(P3_start:P3_end));
    timepoints.P3_latency = [P3_start, P3_end];
    timepoints.P3_latency_point = max_P3_i;
    timepoints.P3_latency_ms = time(P3_times(1) + max_P3_i); % latency in ms

    timepoints.N2 = mean(data(N2_start:N2_end));
    timepoints.N2_latency = [N2_start, N2_end];
    timepoints.N2_latency_point = min_N2_i;
    timepoints.N2_latency_ms = time(N2_times(1) + min_N2_i); % latency in ms
end

