function writeBibTex (bibStruct, filePath, options)
%   WRITEBIBTEX  Writes struct with bibliographic info to text file.
%   writeBibTex (bibStruct, filePath, options)
%
%   Takes a struct containing BibTex and additional keyword information. 
%   Outputs a .bib file that can be read by most reference management
%   programs (e.g., Zotero, Citavi or JabRef).
%
%   ====INPUT=====
%   bibStruct   struct  Struct containing the parsed bibtex information
%                       with added  generated keywords.
%   filePath    string  Path to .bib output file
%
%   -options-
%   mode        string  write mode to file; "w" overwrites existing, "a+"
%                       appends to existing contents
%   ====OUTPUT====
%   (saved .bib file)   .bib file saved to a location of your choosing.

arguments
    bibStruct struct
    filePath {mustBeText}
    options.mode {mustBeMember(options.mode, ["w","a+"])} = "w"
end

% Define the string format of BibTex entries with placeholders
texFormat = "  %s = {%s}";
% Define end of lines in the body of the entry
lineEnd = ", \r\n";
% Open or create file for .bib output
fileID = fopen(filePath, options.mode);
% Get all field names present in struct
keys = fieldnames(bibStruct);

% Iterate over idividual entries of struct
for entryIdx = 1:length(bibStruct)
    % Write first line defining basic properties of the entry
    % .abbr is a Bibtex handle, .type the kind of entry (e.g., article)
    entryString = "@"+bibStruct(entryIdx).type+...
        "{"+bibStruct(entryIdx).abbr+","+"\r"+"\n";
    fprintf(fileID, entryString);
    % Choose current struct for following loop; copied so that we do not
    % change original values
    currStruct = bibStruct(entryIdx); 
    % Set these to empty to prevent output to Bibtex file, as they are
    % invalid BibTex fields.
    currStruct.type = [];
    currStruct.abbr = [];
    % Iterate over fields of current struct
    for keyIdx = 1:length(keys)
        % Get field name and field value pairs
        currKey = keys(keyIdx);
        currKey = currKey{:};
        currVal = currStruct.(currKey);
        if currKey == "file" && ~contains(currVal, "\\")
            % single backward slashes (windows paths) must be escaped in order to be
            % read correctly by reference managers
            % if it doesn
            currVal = strrep(currVal, "\", "\\");
        end
        % Fields without contents are not written to file!
        if ~(isempty(currVal) || all(ismissing(currVal))) && (keyIdx < length(keys))
            %Check Buffer for string
            if exist("bufferedStrings", "var")
               fprintf(fileID, texFormat + lineEnd, ...
               bufferedStrings);
               clear bufferedStrings;
            end 
            %Assign current values to buffer
            bufferedStrings = [string(currKey), string(currVal)];
        % Buffering strings, i.e. not printing directly allows different
        % behaviour depending on whether we are in the main body or at the
        % end of the entry.
        end
        % Last entry must not end its line with a comma, therefore separate
        % loop
        if keyIdx == length(keys)
            % Write to text file from buffer if there is something to write
            if ~(isempty(currVal) || all(ismissing(currVal)))
               fprintf(fileID, texFormat + lineEnd, ...
               bufferedStrings);
               bufferedStrings = [string(currKey), string(currVal)];
            end
            try
            % Print last line of BibTex entry if possible   
            fprintf(fileID, texFormat + "\r\n" , bufferedStrings );
            catch
            end
        end
    end
    clear bufferedStrings
    % Print end of an entry (Curly braces and double newline)
    fprintf(fileID, "}\r\n\r\n");
end
fclose(fileID);