function [textStruct] = getBibInfo(nFiles, fileNames, options)
%   GETBIBINFO  Retrieves bibliographic information and text of given files
%   [textStruct] = getBibInfo(nFiles, fileNames, options)
%
%   Iterates over fileNames, extracts texts from given pdf files, attempts
%   to retrieve bibliographic information via the DOI in a document. Gives
%   out a struct containing the extracted bibliographic information.
%
%   ====INPUT=====
%   nFiles          integer         Number of files detected in folder
%   fileNames       cell array      List of files parsed from folder
%
%   -options-
%   downloadBibTex  logical         Download additional BibTex info for a
%                                   given doi from crossref.org
%
%   ====OUTPUT====
%   textStruct      struct          Struct containing extracted text of pdf
%                                   as well as retrieved bibliographic 
%                                   information.
%                                   -fields-
%                                   text, doi, file, optional: bibtex

arguments
    nFiles double {mustBeNumeric}
    fileNames cell
    options.downloadBibTex logical {mustBeNumericOrLogical} = true
end

% Initialise struct to be filled with text and bibliographic entries later
textStruct(nFiles) = struct();
% Initialise waitbar to track progess
progBar = waitbar(0, "Please Wait", Name = "Preprocessing text...");
for idx = 1:nFiles
    waitbar(idx/nFiles, progBar);
    % Fetch text from pdf file
    textStruct(idx).text = extractFileText(fileNames(idx));
    % Retrieve DOI and assign to field
    doi = getDoi(textStruct(idx).text);
    textStruct(idx).doi = doi;
    % Add field with file location to struct
    textStruct(idx).file = fileNames(idx);
    if options.downloadBibTex
        textStruct(idx).bibtex = bibTexfromDoi(doi);
    end
    if idx == nFiles
        %Signal end of preprocessing
        waitbar(1, progBar, "Bibliographic info retrieved." + ...
            " You may close this window now.")
    end
end