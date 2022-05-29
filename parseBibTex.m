function [bibStruct] = parseBibTex (bibFile, options)
%   PARSEBIBTEX     Reads a BibTex file (.bib) and converts it to a struct.
%   [bibStruct] = parseBibTex (bibFile, options)
%
%   Reads BibTex formatted text either from a text file specified via a
%   file path or from individual text entries of a struct, e.g. if
%   bibliographic info was retrieved via an online service.
%   Puts out a struct array with uniform fields containing the
%   corresponding information for a bibliographic item.
%
%   ====INPUT=====
%   bibFile         string     Path to BibTex file (.bib) containing 
%                     OR       bibliographic information
%                   struct     Struct containing BibTex information 
%   -options-
%   cleanContent    logical    true:  Field values are stripped of braces. 
%                              false: Contents are read as is.
%                              |Example  options.cleanContent = true
%                                       "{{fMRI}} study" -> "fMRI study"
%   ====OUTPUT====
%   bibStruct       struct    Contains the parsed information from the
%                             Bibtex file, e.g. author, year, title

arguments 
    bibFile
    options.cleanContent logical {mustBeNumericOrLogical} = true
end

% Class checking for bibFile; must be text string or a struct
if ~ismember(class(bibFile), ["string", "char", "struct"])
    error("bibFile must be string, char or struct, but was: "+ ...
        "'"+class(bibFile)+"'")
    return
end

% pattern that seperates bibliographic entries from each other
sepPattern = "@" + alphanumericsPattern + "{";
% pattern for the individual fields, e.g. "title = "
entryPattern = lettersPattern + " =" + whitespacePattern + ...
wildcardPattern + lineBoundary;

% Check if bibFile is a string pointing to a valid file on disk
if (isstring(bibFile) || ischar(bibFile)) && isfile(bibFile)
    bibTexFile = extractFileText(bibFile);
% Fetch individual entries
    entries = [split(bibTexFile, sepPattern)];
% If bibFile is a struct, extract info from there    
elseif isstruct(bibFile)
    % Fetch individual entries
    entries = [bibFile(:).bibtex];
    entries = entries(~ismissing(entries));
    % Create a single string formatted like a regular BibTex file
    % containing all entries
    bibTexFile = strjoin(entries, '\n\n');
else
    % If no valid file could be retrieved, give error message.
    error("bibFile must point to a valid textfile or be a struct containing" + ...
        " BibTex formatted strings.")
end

% Omit empty entries
entries = entries(strlength(entries) > 1);
% BibTex files contain information about doc type, e.g. "article", "book"
% and a shorthand handle of an entry. Necessary to write a valid BibTex
% file later.
entryTypes = extractBetween(bibTexFile, lineBoundary + "@", "{");
entryAbbr = extractBetween(bibTexFile, "@" + wildcardPattern + "{", ",");

% Extract all unique keys across the entire database; necessary to
% build a struct array that can hold all entries at once (i.e., in a single
% struct array all structs must have the same fields)
uniqueKeys = cellstr(unique(extractBefore(extract(bibTexFile, entryPattern), " =")))';

% Initialise struct array with given unique fields and empty values
dummyVals = cellstr(strings(length(uniqueKeys), 1))';
dummyStruct = [uniqueKeys; dummyVals];
bibStruct(length(entries)) = struct(dummyStruct{:});

% Waitbar to track progress
progressParseBib = waitbar(0, "BibTex information is being converted to struct." + ...
    " Please wait.", 'windowstyle', 'modal');
%Write fields for each entry recognized
for idx = 1:length(entries)
    % Set entry type and bibTex abbreviation of title as fields in struct.
    bibStruct(idx).type = entryTypes(idx);
    bibStruct(idx).abbr = entryAbbr(idx);
    % Extract field names and values from individual entry
    fieldNames = extractBefore(extract(entries(idx), entryPattern), " =");
    fieldContents = extractBetween(entries(idx), " = ", ...
        wildcardPattern(1) + lineBoundary);
    % Clean trailing comma
    fieldContents = strip(fieldContents, "right",",");
    % Basic check that we parsed fields and contents correctly
    assert((length(fieldNames) == length(fieldContents)), ...
        "Number of fields does not match number of values to be distributed." + ...
        "Was the file in BibTex format?")
    if options.cleanContent
        % Clean content to receive valid BibTex entries that do not cause
        % parsing errors when writing them to another file later.
            fieldContents = erase(fieldContents, ["{", "}"]);
            fieldContents = deblank(fieldContents);
            fieldContents = strip(fieldContents, "right",",");
    end
    for fieldIdx = 1:length(fieldNames)
        % Write fields and values to struct
        currField = fieldNames(fieldIdx);
        bibStruct(idx).(currField) = fieldContents(fieldIdx);
    end
    % Add information about the file location
    if isstruct(bibFile)
       bibStruct(idx).file = bibFile(idx).file;
    end
    waitbar(idx/length(entries), progressParseBib)
    if idx == length(entries)
            waitbar(1, progressParseBib, "Done! You may close this window now.")
    end
end