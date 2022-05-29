function [doi] = getDoi (textFile)
%   GETDOI  retrieve DOI (digital object identifier) from a text.
%   [doi] = getDoi (textFile)
%
%   It is assumed that the first DOI to appear in a text is
%   the DOI assigned to the document.
%   DOI patterns implemented work best for recent DOIs. Legacy
%   DOIs might require different patterns.
%
%   ====INPUT=====
%   textFile    string          Contains text from a single document
%
%   ====OUTPUT====
%   doi         string          first DOI extracted from document

arguments
    textFile string {mustBeText}
end
% Patterns that describe the usual structure of a DOI
DoiPattern1 = "10.\d{4,9}/[-._;()/:a-z0-9A-Z]+";
DoiPattern2 = "[/^10.1002/[^\s]+$/i]";

% First pattern covers most recent DOIs.
% Returns <missing> if not successful
doi  = regexp(textFile, DoiPattern1, 'match', 'once');

% Second pattern is used if the first one is unsuccessful
if ismissing(doi) || ~exist("doi", "var")
    doi  = regexp(textFile, DoiPattern2, 'match', 'once');
    % set DOIs that are too short to missing
    if strlength(doi) < 5
        doi = missing;
    end
end
end
