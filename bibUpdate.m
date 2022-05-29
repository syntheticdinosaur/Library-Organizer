function [bibStruct]= bibUpdate(bibStruct, wordBag, nGrams, ...
    topicLabels, fileNames, options)
%   BIBUPDATE   Updates existing bibStruct with generated keywords.
%   [bibStruct] = bibUpdate(bibStruct, wordBag, nGrams, topicLabels, 
%                          fileNames, options)
%
%   CURRENTLY,  PREVIOUS KEYWORDS IN THE BIBTEX INFO ARE OVERWRITTEN.
%
%   Adds keywords to existing bibliographic information stored in a struct.
%   Keywords are based on word and nGram frequency information as well as 
%   topic modelling.
%
%   ====INPUT=====
%   bibStruct       struct           Struct containing bib. information
%   wordBag         bagOfWords       bag-of-words model of documents
%   nGrams          bagOfNgrams      bag-of-nGrams model of documents
%   topicLabels     categorical      Contains the most probable
%                                    topics of each document
%   fileNames       cell array       List of file locations
%   nTopWords       integer          Number of most frequent keywords to be
%                                    passed to keywords
%   -options-
%   fullFile        logical          true:  match entries by full file path 
%                                    false: match by file name only
%
%   ====OUTPUT====
%   bibStruct       struct           Struct with updated bibliography,
%                                    includes keywords extracted from
%                                    wordBag, nGram models and topic
%                                    modelling
                                    
arguments
    bibStruct struct
    wordBag bagOfWords
    nGrams  bagOfNgrams
    topicLabels categorical
    fileNames cell
    options.topKWords {mustBeInteger} = 4
    options.fullFile = false
end

% Extract keywords for each document

[~, keywordIdx] = maxk(wordBag.Counts, options.topKWords, 2);
wordList = wordBag.Vocabulary(keywordIdx);

[~, nGramIdx]   =maxk(nGrams.Counts, options.topKWords, 2);
NGramVocabulary = join(nGrams.Ngrams, " ", 2);
nGramList   = NGramVocabulary(nGramIdx);

topicList = join(string(topicLabels), ", ", 2);
delimSpace = ", ";

% List of keywords, combined as a single string per document
keywords = join(wordList, delimSpace, 2) + delimSpace + ...
    join(nGramList, delimSpace, 2) + delimSpace + topicList;

% Extract file path, independent of drive letter (e.g., ocmpatible with
% changing drive letters
% Mostly useful if the bibtex file was read from a reference manager.
%Perhaps option to only have file name but not path?
structFiles = fullfile([bibStruct.file]);
structFiles = extractAfter(structFiles, ":");


storedFiles = string(fileNames);
storedFiles = extractAfter(storedFiles, ":");

if ~options.fullFile
[~, structFiles, ~] = fileparts(structFiles);
[~, storedFiles, ~] = fileparts(storedFiles);
end


% Matching Indices based on file path and name
[~, matchedIdx] = ismember(structFiles, storedFiles);

% Assigning keywords to struct
matchedKeywords = keywords(matchedIdx(matchedIdx));
%[bibStruct.keywords] = matchedKeywords{:};
% Implement appending keywords instead of verwriting
[bibStruct.keywords] = matchedKeywords{:};

end
