function [tokenDoc] = preprocessingText(textString, options)
% PRECPROCESSINGTEXT  Produces tokenized text from individual raw texts. 
% [tokenDoc] = preprocessingText(textString, options)
%
%  Tokenization reduces the text to a form that is more suitable for
%  subsequent algorithmic analysis by simplyifing words, merging words that 
%  have the same lexicalic origin and deleting certain
%  text elements such as infrequent or short words.
%
%   ====INPUT=====
%   textString    string       Raw text of a single document.
%
%   -options-
%   nLetterShort  integer      Only words longer than this are kept
%   StopWords     string array User-defined words to be removed 
%                              from tokenized text.
%   nounOnly      logical      reduces tokenized text to nouns only;
%                              Increases speed, but makes nGrams less
%                              accurate or sensible.
%   removeNonWord logical      remove digits and web addresses from text
%   ====OUTPUT====
%   tokenDoc      tokenizedDoc Processed text of the pdf document

arguments
    textString string {mustBeText}
    options.nLetterShort (1,1) double {mustBeInteger}       = 2
    options.StopWords (1,:) string {mustBeText}             = strings
    options.NounOnly (1,1) logical {mustBeNumericOrLogical} = false
    options.removeNonWord  logical {mustBeNumericOrLogical} = true
end

% Tokenize document
tokenDoc = tokenizedDocument(textString);
% Add information about functions of individual words, e.g. 'noun',
% 'adjective' etc.
tokenDoc = addPartOfSpeechDetails(tokenDoc);
% Remove standard stop words
tokenDoc = removeStopWords(tokenDoc);
% Punctuation is unimportant for alter analysis
tokenDoc = erasePunctuation(tokenDoc);

% Extract table with part of speech details; allows to remove words of
% specified type subsequently.
tkD = tokenDetails(tokenDoc);
% Remove non-word strings from text, such as numbers and web adresses
if options.removeNonWord
    numTokens = tkD.Type == "digits" ;
    webTokens = tkD.Type == "web-adress";
    tokenDoc = removeWords(tokenDoc, tkD.Token(numTokens, :) );
    tokenDoc = removeWords(tokenDoc, tkD.Token(webTokens, :) );
    clear numTokens webTokens
end

% Reduce text to nouns only, enables faster topic modelling later 
if options.NounOnly
    nounTokens = contains(string(tkD.PartOfSpeech), "noun");
    tokenDoc = removeWords(tokenDoc, tkD.Token(~nounTokens, :));
    clear nounTokens
end

clear tkD
% Removal of short words that are often not important for topics
tokenDoc = removeShortWords(tokenDoc, options.nLetterShort);
% Remove user specified stopwords
tokenDoc = removeWords(tokenDoc, options.StopWords, 'IgnoreCase', true);
% Reduce words to their word stem, reducing the possible forms of words
% i.e., 'build', 'built', 'building' would all become 'build'
tokenDoc = normalizeWords(tokenDoc,Style="lemma");
end


