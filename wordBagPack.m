function [wordBag, nGrams] = wordBagPack(preprocessedText, options)
%   WORDBAGPACK     Prepares bag-of-words and bag-of-n-Grams from text
%   [wordBag, nGrams] = wordBagPack(preprocessedText,options)
%
%   Wrapper for MATLAB bagOfWords and bagOfNgram functions
%
%   ====INPUT=====
%   preprocessedText tokenizedDoc      tokenized text of a document
%
%   -options-
%   nWordRare       integer            max. occurence to remove rare words
%   nGramRare       integer            max. occurence to remove rare nGrams
%   nGramLength     integer            length of n-Grams, i.e. '2' leads to
%                                      bi-Grams, such as 'neuron doctrine'
%
%   ====OUTPUT====
%   wordBag         bagOfWords         Bag of words from tokenized text
%   biGrams         bagOfNgrams        Bag of N-Grams from tokenized text
arguments
    preprocessedText    tokenizedDocument
    options.nWordRare   {mustBeInteger}  = 3
    options.nGramRare   {mustBeInteger}  = 2
    options.nGramLength {mustBeInteger}  = 2
end
% Bag of Words
wordBag = bagOfWords(preprocessedText);
wordBag = removeInfrequentWords(wordBag, options.nWordRare);
% Bag of N-Grams
nGrams = bagOfNgrams(preprocessedText, 'NgramLengths', options.nGramLength);
nGrams = removeInfrequentNgrams(nGrams, options.nGramRare);
end