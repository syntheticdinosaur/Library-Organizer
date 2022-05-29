function [bibItem] = bibTexfromDoi(doi)
%   BIBTEXFROMDOI     Downloads bibliographic information in BibTex format.
%   [bibItem] = bibTexfromDoi(doi)
%
%   Uses the crossref.org API to retrieve bibliographic information based
%   on an articles DOI (digital object identifier) in BibTex format. 
%   Function uses a simplified access to crossref via a specialised URL.
%
%   ====INPUT=====
%   doi         string          DOI extracted from a single document
%
%   ====OUTPUT====
%   bibItem     string          Bibliographic information in BibTex format
%                               retrieved from crossref.org
%

% Check that the entry has a DOI and it is of sufficient length
if ismissing(doi) || strlength(doi) < 5
    % quit function execution if no valid DOI found
    bibItem = missing;
    return
end

% Options for webread function
WOptions = weboptions('ContentType','text', 'Timeout', 5000);
try
% Using this retrieve address instead of a specialised request header is
% easier, but might be broken by later changes to the crossref webpage.
retrieveAddress = "https://api.crossref.org/works/"+doi+"/transform/application/x-bibtex";
% Access the crossref.org API to get bibliographic information:
bibItem = string(webread(retrieveAddress, WOptions));
catch
    % If above was unsuccessful, the DOI could have been parsed incorrectly
    try
    % Clean the DOI from common trailing chars that hinder retrieval.
    doi = strip(doi, "both", ".");
    doi = strip(doi, "both", ",");
    doi = strip(doi, "both", " ");
    retrieveAddress = "https://api.crossref.org/works/"+doi+"/transform/application/x-bibtex";
    bibItem = string(webread(retrieveAddress, WOptions));
    catch
        % If modifying the DOI was futile, return missing and issue warning
        bibItem = missing;
        warning("DOI could not be resolved.");
    end
end

end
