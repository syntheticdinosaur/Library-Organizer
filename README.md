# LIBRARYORGANIZER - Topic Modelling and Key Word Assignment for scientific articles

## Problem

![This image shows a Mary Kondo Meme](https://github.com/syntheticdinosaur/Library-Organizer/blob/master/docs/images/MarieKondoArticleOrga.jpg | width= 500)

Digital libraries of scientists can be messy. Various pdfs from various fields and subfields are gathered
and often, it is not easy to gain an overview, i.e. identify common topics across multiple articles. At
times documents (especially grey literature) are not properly keyworded, hindering searches in one’s
library. Further, it could be useful to see how close or how distant different articles, books, etc. in the
library are in regard to the topics they cover.
For this project, I would like to make use of MATLABs text processing / natural language processing
toolbox as it provides many useful inbuilt functions for this task.

## Background
A simple, but effective approach to summarise and categorize documents has been the ‘bag of
words’ or ‘bag of N-grams’ family of models, which reduce the text to a frequency count of words
(e.g., “neuron”) or N-grams (e.g. a bigram, “neural dynamics”) in documents. It assumes that what a
text is about can be faithfully approximated by its word content alone (of course, the clearing of
common words, so called stop words is necessary).
Based on these summarisations of individual texts, themes or topics can be extracted from a
collection of texts. This is referred to as topic modelling. A topic can be understood as a collection of
words or N-grams that often occur together across documents. This then allows to also assign topics
to the documents themselves, providing a way to assess the content similarity of documents.
Depending of the modelling method, such topic assignments can be exclusive or non-exclusive.

## Function:
Collection of MATLAB functions to perform topic modelling on a collection of scientific articles.
Extracted topics, as well as automatically generated keywords, get written to a BibTex file for late rimport into a reference manager of your choice.

## Dependencies:
MATLAB 2022a
TEXT ANALYTICS & MACHINE LEARNING AND STATISTICS TOOLBOXES

## How to:
Prepare folder with articles/book chapters that you want to analysis (preferably .pdf format) and select it in the GUI.
As a start, you can choose the 20 articles included in "Example Articles".
Default options in GUI dialogues are hinted in blue and should work fine for first tries with the program.
The numbers of topics to be extracted (e.g., research fields/directions) must be based on your intuition, normally, 3-10 can be a good fit depending on the number of files and their diversity in content.
