function processEEGWithFOOOF2(cleanFolder, peak_distance_Hz, min_peak_height_STD, plotting)
    % This function processes EEG files by calculating averaged epochs, performing FFT, and analyzing the
    % power spectral density (PSD) using the FOOOF (Fitting Oscillations & One Over F) algorithm. It extracts
    % frequency peaks based on specified parameters and saves detailed results in both MATLAB (.mat) and Excel
    % formats, which include absolute and relative power metrics for specified frequency bands.
    %
    % INPUTS:
    %   cleanFolder: String specifying the directory containing EEG .set files.
    %   peak_distance_Hz: Minimum distance between peaks in the frequency domain (in Hz) to be considered distinct.
    %   min_peak_height_STD: Minimum height of peaks, expressed in standard deviations above the mean, to qualify for detection.
    %   plotting: Boolean flag indicating whether to plot the PSD and FOOOF results for visual inspection.
    %
    % The function retrieves all .set files from the specified directory and performs the following operations for each file:
    %   1. Averages epochs across trials for each channel.
    %   2. Performs FFT on the averaged data to convert it from the time domain to the frequency domain.
    %   3. Applies the PSD_FOOOF function to model the spectral characteristics and identify significant peaks.
    %   4. Calculates absolute and relative power within standard EEG frequency bands (delta, theta, alpha, beta, gamma).
    %   5. Stores and saves the results in structured data formats for subsequent analysis and reporting.
    %
    % OUTPUTS:
    %   This function does not return any variables but saves results to files:
    %   - 'FOOOF_AllData.mat': A MATLAB file containing detailed results from the FOOOF analysis for all channels and files.
    %   - 'FOOOF_Summary_final2_NOGO.xlsx': An Excel file summarizing the key metrics for quick review and distribution.
    %
    % Example usage:
    %   processEEGWithFOOOF2('path/to/cleaned/data', 1, 1.5, true);

    % Define brain frequency bands (in Hz)
    delta_range = [0.1 4];
    theta_range = [4 8];
    alpha_range = [8 12];
    beta_range = [12 30];
    gamma_range = [30 100];  % Optional, depending on data resolution

    % Retrieve list of EEG files
    fileList = getAllFiles(cleanFolder, '.+\.set$');  % Assuming .set files

    % Initialize cell arrays to store results for all files
    all_data = {}; % This will hold all metrics across files and channels
    summary_table = {}; % This will hold data to be written into Excel

    % Loop through each file
    for i = 1:length(fileList)
        % Load EEG dataset
        EEG = pop_loadset('filename', fileList{i});

        % Calculate average across epochs for each channel
        averagedEEG = mean(EEG.data, 3);  % EEG.data is (channels x points x epochs)

        % Initialize matrix to store FFT results
        fftResults = zeros(size(averagedEEG));

        % Perform FFT on averaged data
        for ch = 1:size(averagedEEG, 1)  % Loop over each channel
            fftData = fft(averagedEEG(ch, :));  % Compute FFT
            fftResults(ch, :) = abs(fftData);  % Store magnitude of FFT results
        end

        % Frequency vector corresponding to the FFT results
        n = size(EEG.data, 2);  % number of time points
        Fs = EEG.srate;  % Sampling frequency
        f = (0:n-1) * (Fs/n);  % Frequency range

        % Limit the frequency range for analysis (typically 0 to Nyquist frequency)
        f_half = f(1:floor(n/2));  % Frequencies up to Nyquist
        fftResults_half = fftResults(:, 1:floor(n/2));  % FFT results up to Nyquist

        % Loop through each channel and apply PSD_FOOOF
        for ch = 1:size(fftResults_half, 1)
            data_vec = fftResults_half(ch, :);  % Use the half FFT spectrum
            [final_fit, aperiodic_params, peak_freqs, peak_widths, peak_heights, rmse] = ...
                PSD_FOOOF(data_vec, f_half, peak_distance_Hz, min_peak_height_STD, plotting);

            % Compute absolute power for each frequency band
            delta_power = sum(data_vec(f_half >= delta_range(1) & f_half <= delta_range(2)));
            theta_power = sum(data_vec(f_half >= theta_range(1) & f_half <= theta_range(2)));
            alpha_power = sum(data_vec(f_half >= alpha_range(1) & f_half <= alpha_range(2)));
            beta_power = sum(data_vec(f_half >= beta_range(1) & f_half <= beta_range(2)));
            gamma_power = sum(data_vec(f_half >= gamma_range(1) & f_half <= gamma_range(2)));

            % Total power across all frequencies
            total_power = sum(data_vec);

            % Compute relative power (percentage of total power)
            relative_delta = delta_power / total_power;
            relative_theta = theta_power / total_power;
            relative_alpha = alpha_power / total_power;
            relative_beta = beta_power / total_power;
            relative_gamma = gamma_power / total_power;

            % Store data in the 'all_data' cell array for saving to a .mat file
            all_data{i, ch}.final_fit = final_fit;
            all_data{i, ch}.aperiodic_params = aperiodic_params;
            all_data{i, ch}.peak_freqs = peak_freqs;
            all_data{i, ch}.peak_widths = peak_widths;
            all_data{i, ch}.peak_heights = peak_heights;
            all_data{i, ch}.rmse = rmse;
            all_data{i, ch}.absolute_delta = delta_power;
            all_data{i, ch}.absolute_theta = theta_power;
            all_data{i, ch}.absolute_alpha = alpha_power;
            all_data{i, ch}.absolute_beta = beta_power;
            all_data{i, ch}.absolute_gamma = gamma_power;
            all_data{i, ch}.relative_delta = relative_delta;
            all_data{i, ch}.relative_theta = relative_theta;
            all_data{i, ch}.relative_alpha = relative_alpha;
            all_data{i, ch}.relative_beta = relative_beta;
            all_data{i, ch}.relative_gamma = relative_gamma;

            % Extract just the file name from the full path
            [~, fileName, ext] = fileparts(fileList{i});
            fullFileName = [fileName, ext];  % Combine the base file name with its extension

            % Prepare a summary row for the Excel file (without final_fit)
            summary_table{end+1, 1} = fullFileName;  % File name (e.g., HC001_sit_chans_ICA_processed_GO_filtered.set)
            summary_table{end, 2} = ch;  % Channel number
            summary_table{end, 3} = aperiodic_params.C;  % Aperiodic parameter C
            summary_table{end, 4} = aperiodic_params.A;  % Aperiodic parameter A
            summary_table{end, 5} = aperiodic_params.B;  % Aperiodic parameter B
            summary_table{end, 6} = num2str(peak_freqs);  % Peak frequencies (as string to fit in one cell)
            summary_table{end, 7} = num2str(peak_widths);  % Peak widths (as string to fit in one cell)
            summary_table{end, 8} = num2str(peak_heights);  % Peak heights (as string to fit in one cell)
            summary_table{end, 9} = rmse;  % RMSE
            summary_table{end, 10} = delta_power;  % Absolute Delta Power
            summary_table{end, 11} = theta_power;  % Absolute Theta Power
            summary_table{end, 12} = alpha_power;  % Absolute Alpha Power
            summary_table{end, 13} = beta_power;  % Absolute Beta Power
            summary_table{end, 14} = gamma_power;  % Absolute Gamma Power
            summary_table{end, 15} = relative_delta;  % Relative Delta Power
            summary_table{end, 16} = relative_theta;  % Relative Theta Power
            summary_table{end, 17} = relative_alpha;  % Relative Alpha Power
            summary_table{end, 18} = relative_beta;  % Relative Beta Power
            summary_table{end, 19} = relative_gamma;  % Relative Gamma Power
        end
    end

    % Save the 'all_data' variable to a .mat file (contains final_fit, aperiodic_params, etc.)
    save('FOOOF_AllData.mat', 'all_data');

    % Prepare and write the Excel file
    summary_header = {'File Name', 'Channel', 'Aperiodic C', 'Aperiodic A', 'Aperiodic B', ...
                      'Peak Frequencies', 'Peak Widths', 'Peak Heights', 'RMSE', ...
                      'Absolute Delta Power', 'Absolute Theta Power', 'Absolute Alpha Power', ...
                      'Absolute Beta Power', 'Absolute Gamma Power', ...
                      'Relative Delta Power', 'Relative Theta Power', 'Relative Alpha Power', ...
                      'Relative Beta Power', 'Relative Gamma Power'};
    summary_table = [summary_header; summary_table];  % Add header to table
    writecell(summary_table, 'FOOOF_Summary_final2_NOGO.xlsx');  % Write to Excel file

    disp('Data saved successfully to FOOOF_AllData.mat and FOOOF_Summary.xlsx');
end
