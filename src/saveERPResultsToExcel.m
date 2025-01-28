function saveERPResultsToExcel(results, filename)
    % This function compiles and saves ERP analysis results into an Excel file. It organizes data by subject ID,
    % assignment type, subject type, and electrode, including detailed metrics such as amplitudes and latencies
    % for P3 and N2 components. It is designed to facilitate data review and sharing in research environments.
    %
    % Inputs:
    %   results - Array of structures containing ERP data and metadata for each subject and session.
    %   filename - String specifying the path and name of the Excel file to save the results.
    %
    % The function initializes arrays for storing ERP data from multiple subjects across different conditions.
    % It iterates through each result entry, checking for available data for predefined electrode pairs.
    % If data is available, it extracts and organizes P3 and N2 component data into structured arrays.
    % Finally, it compiles these arrays into a table and writes this table to an Excel file.
    %
    % Example Usage:
    %   results = [struct('subjectID', '001', 'assignmentType', 'SIT', 'subjectType', 'HC', 'E6', ERP_data_struct), ...];
    %   saveERPResultsToExcel(results, 'ERP_Results.xlsx');
    %
    % Author: Ron Montaoriano
    % Date: 15.04.2024
    % Revision: 1.0
    % MATLAB version used for development: R2023b

    % Initialize table arrays
    subjectID = {};
    assignmentType = {};
    subjectType = {};
    electrode = {};
    P3_amplitude = [];
    P3_latency_start = [];
    P3_latency_end = [];
    P3_latency_ms = [];
    N2_amplitude = [];
    N2_latency_start = [];
    N2_latency_end = [];
    N2_latency_ms = [];

    % Process each file
    for i = 1:length(results)
        % Check for the presence of data in E6/Fz or E34/Pz pairs
        if isfield(results(i), 'E6') || isfield(results(i), 'Fz') || isfield(results(i), 'E34') || isfield(results(i), 'Pz')
            electrodePairs = {'E6', 'Fz'; 'E34', 'Pz'};  % Electrode pairs
            for j = 1:size(electrodePairs, 1)
                % Determine which electrode to use for this pair
                if isfield(results(i), electrodePairs{j, 1}) && ~isempty(getfield(results(i), electrodePairs{j, 1}))
                    currentElectrode = electrodePairs{j, 1};
                elseif isfield(results(i), electrodePairs{j, 2}) && ~isempty(getfield(results(i), electrodePairs{j, 2}))
                    currentElectrode = electrodePairs{j, 2};
                else
                    continue;  % Skip this pair if no data is available
                end
                
                % Access data safely
                subjectID{end+1, 1} = results(i).subjectID;
                assignmentType{end+1, 1} = results(i).assignmentType;
                subjectType{end+1, 1} = results(i).subjectType;
                disp(subjectType)
                if strcmp(subjectType{end},'PDM') && strcmp(assignmentType{end},'WALK') && strcmp(subjectID{end},'014')
                    disp("gg")
                end
                electrode{end+1, 1} = currentElectrode;
                erp_data = getfield(results(i), currentElectrode);
                
                if ~isempty(erp_data)
                    % Append ERP data to the respective lists
                    P3_amplitude(end+1, 1) = erp_data.P3;
                    P3_latency_start(end+1, 1) = erp_data.P3_latency(1);
                    P3_latency_end(end+1, 1) = erp_data.P3_latency(2);
                    P3_latency_ms(end+1, 1) = erp_data.P3_latency_ms;

                    N2_amplitude(end+1, 1) = erp_data.N2;
                    N2_latency_start(end+1, 1) = erp_data.N2_latency(1);
                    N2_latency_end(end+1, 1) = erp_data.N2_latency(2);
                    N2_latency_ms(end+1, 1) = erp_data.N2_latency_ms;
                else
                    % Append NaNs if data is empty
                    P3_amplitude(end+1, 1) = NaN;
                    P3_latency_start(end+1, 1) = NaN;
                    P3_latency_end(end+1, 1) = NaN;
                    P3_latency_ms(end+1, 1) = NaN;

                    N2_amplitude(end+1, 1) = NaN;
                    N2_latency_start(end+1, 1) = NaN;
                    N2_latency_end(end+1, 1) = NaN;
                    N2_latency_ms(end+1, 1) = NaN;
                end
            end
        end
    end

    % Create a table from the data
    T = table(subjectID, assignmentType, subjectType, electrode, P3_amplitude, P3_latency_start, P3_latency_end, P3_latency_ms, N2_amplitude, N2_latency_start, N2_latency_end, N2_latency_ms, ...
              'VariableNames', {'SubjectID', 'AssignmentType', 'SubjectType', 'Electrode', 'P3_Amplitude', 'P3_Latency_Start', 'P3_Latency_End', 'P3_Latency_ms', 'N2_Amplitude', 'N2_Latency_Start', 'N2_Latency_End', 'N2_Latency_ms'});

    % Write the table to an Excel file
    writetable(T, filename);
    disp(['Data saved to Excel file: ', filename]);
end
