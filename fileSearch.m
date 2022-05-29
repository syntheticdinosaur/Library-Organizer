function[fileDir, fileNames, nFiles] = fileSearch(options)
%   FILESEARCH        Extract list of files from specified folder.
%   [fileDir, fileNames, nFiles] = fileSearch(options)
%
%   Helper function to scan a directory for a certain type of files at a
%   specified depth. Normally asks user for GUI based input, but this can
%   be bypassed to work with a programmatically given folder location.
%
%   ====INPUT=====
%   -options-
%   folderPath  string          programmatically pass folder path, bypass
%                               GUI user input
%   searchDepth string          How deep to look for pdf files in folder.
%                               Full:   Look into folder and all subfolders
%                               First:  Do not look into subfolders
%                               Second: Look into folder and 
%                                       direct subfolders 
%   fileExt     string          file extension of files to be extracted
%
%   ====OUTPUT====
%   fileDir     string          directory of all files
%   fileNames   cell array      File locations of found files
%   nFiles      double          Number of files found  

arguments
    options.folderPath = []
    options.searchDepth {mustBeMember(options.searchDepth, ...
        ["full", "first", "second"])}  = "full"
    options.fileExt {mustBeTextScalar} = "pdf"
end

% Check whether a path was programatically specified; If not, ask user for
% GUI input
if isempty(options.folderPath)
    folderPath = uigetdir("", "choose folder containing pdf files");
else
    % Check whether a valid folder was passed, quit if not
    if ~isfolder(options.folderPath)
        error("Could not resolve " + options.folderPath)
        return
    end
    folderPath = options.folderPath
end

% specifiy file extension with wildcard
fileExt = "*."+options.fileExt

% Search through directory at given depth
switch options.searchDepth
    case "full"
        % Search in all subdirectories
        fileDir = dir(fullfile(folderPath,"**", fileExt));
        fileNames = fullfile({fileDir.folder}, {fileDir.name});
    case "first"
        % Only search directly in folder
        fileDir = dir(fullfile(folderPath, fileExt));
        fileNames = fullfile({fileDir.folder}, {fileDir.name});
    case "second"
        fileDir = dir(fullfile(folderPath, fileExt));
        fileNames = fullfile({fileDir.folder}, {fileDir.name});
        fileDir = dir(folderPath);
        dirList = [fileDir.isdir];
        % Create list of direct subfolders, not including 'deeper'
        % subfolders
        subDir  = fileDir(dirList);
        % starting from 3 excludes "." and ".." directories
        for subFolderIdx = 3:length(subDir)
            fileDir = dir(fullfile(folderPath, subDir(subFolderIdx).name, fileExt));
            fileNames = [fileNames, fullfile({fileDir.folder}, {fileDir.name})];
        end   
        clear dirList
end

% Get number of files; Check whether it is sufficient for topic analysis.
nFiles = length(fileNames);
    if nFiles == 0
        % No file found, perhaps wrong folder. Quit execution
        error("No " +options.fileExt + " file(s) in specified folder detected." + ...
           " Please check directory and search depth settings. " + ...
           "Current settings: Search depth '" + options.searchDepth + ...
           "'. File Extension '" +options.fileExt+"'.")
    elseif nFiles < 11
        % Very few files detected; not enough for good topic extraction
            warning("Only " + nFiles + " " + options.fileExt + ...
                " files detected. " +...
                "Please check directory and search depth settings. " + ...
                "Current settings: Search depth '" + options.searchDepth + ...
                "'. File Extension '" +options.fileExt+"'.")
    end
end