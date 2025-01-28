function fileList = getAllFiles(dirName, filePattern)
    % Recursively searches through a directory and its subdirectories to find files that match a given pattern.
    % This function is useful for file management tasks such as gathering all files of a specific type within a directory tree.
    %
    % Inputs:
    %   dirName - A string specifying the directory to search through.
    %   filePattern - A string containing the pattern to match filenames against. Regular expressions are supported.
    %
    % Outputs:
    %   fileList - A cell array of strings, each string being the full path to a file that matches the filePattern.
    %
    % Example usage:
    %   fileList = getAllFiles('C:\MyData', '*.mat');
    %
    % Author: Ron Montaoriano
    % Date: 15.02.2024
    % Revision: 1.0
    % MATLAB version used for development: R2023b

    % Get the data for the current directory
    dirData = dir(dirName);      
    
    % Find the index for directories within the current directory data
    dirIndex = [dirData.isdir];  
    
    % Extract the names of files (not directories) and convert them to a cell array
    fileList = {dirData(~dirIndex).name}';  
    
    % If fileList is not empty, prepend the directory path to each file's name to create a full path
    if ~isempty(fileList)
        fileList = cellfun(@(x) fullfile(dirName, x), fileList, 'UniformOutput', false);
    end

    % Extract the names of all subdirectories
    subDirs = {dirData(dirIndex).name};    
    
    % Filter out the current ('.') and parent ('..') directories to avoid infinite recursion
    validIndex = ~ismember(subDirs, {'.', '..'});  
    
    % Loop over valid subdirectories
    for iDir = find(validIndex)                  
        % Construct the full path of the subdirectory
        nextDir = fullfile(dirName, subDirs{iDir});    
        
        % Recursively call getAllFiles on each subdirectory and concatenate the results with the current fileList
        fileList = [fileList; getAllFiles(nextDir, filePattern)];  
    end

    % Filter the fileList to include only files that match the filePattern
    % This uses a regular expression (regexpi) to match the pattern and filters fileList accordingly
    fileList = fileList(cellfun(@(x) ~isempty(regexpi(x, filePattern, 'once')), fileList));
end
