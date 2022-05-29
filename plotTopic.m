function [nameTopics, topicLabels] = plotTopic (topicModel, textContainer, options)
%   PLOTTOPIC   Plotter for Topic Modelling (Interactive Scatter/tSNE)
%   [nameTopics, topicLabels] = plotTopic(topicModel,textContainer,options)
%
%   Wordcloud and TSNE scatter plot of documents grouped by topics.
%   Includes option to rename topics after inspecting words in a wordcloud
%   topics. These topics can than be used as keywords for the bibliographic
%   entries.
%
%   ====INPUT=====
%   topicModel      topicModel Topic Model generated from tokenized text
%   textContainer   struct     Struct with bibliographic information for
%                              documents in topic model
%   -options-
%   topK            integer    specifies max number of topics
%                              to be put into topicLabels
%   plotSize        double 1x2 Specify x and y size of plot, e.g.
%                              [600,600]     
%
%   ====OUTPUT====
%   (Creates Figures)          Figures of the wordcloud plot and TSNE plot,
%                              respectively. 
%   nameTopics     cell array  List of names of topics
%   topicLabels    categorical Contains the topK most probable
%                              topics of each document

arguments
    topicModel
    textContainer struct
    options.topK int64 {mustBeInteger} = 1 % for presentation purpose
    options.plotSize = [600,600]
end

% Class checking for topicModel; currently only
if ~ismember(class(topicModel), ["ldaModel","lsaModel"])
    error("topicModel must be ldaModel or lsaModel but was: "+ ...
        "'"+class(topicModel)+"'")
    return
end

% Create list of generic topic names, i.e., 'Topic 1', 'Topic 2' ...
TopicList = strcat("Topic ", string(1:topicModel.NumTopics));

% Set basic plotting parameters
plotSize = options.plotSize;
bgColor = [0.8,0.8,0.8];

% Generate wordcloud plot; 
% Interactive plot enables renaming of topics and provides access to TSNE
% plot if the user wishes to see it
[cloudFig, nameTopics] = cloudPlotLDA(TopicList);

% Get list of all topic probabilities per document
topProbs = topicModel.DocumentTopicProbabilities;
% Get list of most probable topics for each document
[tProb, probIdx] = maxk(topProbs, options.topK, 2);
% Categorical array with topics assigned to each document
topicLabels = categorical(probIdx, 1:topicModel.NumTopics, nameTopics);


function [cloudFig, nameTopics] = cloudPlotLDA(TopicList)
    % Use generic topic names as default
    nameTopics = TopicList;
    % Initialise figure
    cloudFig = figure;
    cloudFig.Position = [20,20, plotSize];
    % Control Buttons
    % After renaming topics via GUI input, this button allows the new names
    % to be displayed in the wordcloud
    buttonRename  = uicontrol('Parent',cloudFig,'Style','pushbutton','String',...
    'Display new topic names','Units','normalized','Position',[0.0 0.0 0.2 0.1],...
    'Callback', @renameTopics, 'Visible','on');
    % This button produces a TSNE plot of the documents grouped by topics
    buttonTsne    = uicontrol('Parent',cloudFig,'Style','pushbutton','String',...
    'TSNE Plot','Units','normalized','Position',[0.2 0.0 0.2 0.1],...
    'Callback', {@tsnePlotButton, nameTopics}, 'Visible','on');

if topicModel.NumTopics == 1
    wordcloud(topicModel, 1)
else    
childPlots = {};
    for idx = 1:topicModel.NumTopics
        subplot(ceil(topicModel.NumTopics/2), 2, idx);
        childPlots{idx} = wordcloud(topicModel, idx);
        title(TopicList(idx))
    end    
end

% Allows to rename topics displayed in the wordcloud plot, i.e. replace
% generic names such as 'Topic 1' with meaningful topic names, e.g.
% 'Molecular Neuroscience'
nameTopics = inputdlg(TopicList,...
      'You may rename the topics here. Empty boxes will retain default values',...
      [1 50], TopicList); 

% Redraw the titles of the wordcloud plot with adjusted topic names

function renameTopics(~, ~)
    for plotIdx = 1:topicModel.NumTopics
        childPlots{plotIdx}.Title =  nameTopics{plotIdx};
    end
    drawnow
end    
end

% Plot documents in TSNE space and provide bibliographic information in
% tooltips
    function tsneFig = tsnePlot(~)
    % Basic fiure settings
    tsneFig = figure;
    tsneFig.Position = [-20,-20, plotSize];
    
    % TSNE dimensionality reduction of document probabilites
    topicTsne = tsne(topicModel.DocumentTopicProbabilities);
    % Create grouped scatter plot in TSNE space; Grouped by topics
    scatterTsne_back = gscatter(topicTsne(:,1), topicTsne(:,2), topicLabels(:,1));
    % Grouped scatter plots cannot be easily combined with custom datatips,
    % therefore a second regular scatter plot with transparent markers is
    % overlayed, allowing data points to have datatips/tooltips enabled.
    hold on
    % Do not include new datapoints in legend
    legend('AutoUpdate','off')
    scatterTsne = scatter(topicTsne(:,1), topicTsne(:,2), [], [1, 1, 1], ...
        'filled', 'MarkerFaceAlpha',0);
    % Adjust background color of plot
    set(gca,'color', bgColor)
    % Set datatips to bibliographic information; depends on ordered data as
    % it implicitly uses indices to matched entries to datapoints
    % Does not always work reliably yet.
    try
        dtRows = [dataTipTextRow("Title", [textContainer(:).title]),... 
            dataTipTextRow("Author(s)", [textContainer(:).author]), ...
            dataTipTextRow("File", string([textContainer(:).file])), ...
            dataTipTextRow("DOI", [textContainer(:).doi])];
       scatterTsne.DataTipTemplate.DataTipRows(1:length(dtRows)) = dtRows;
    catch
        warning("Error creating datatips.")
    end
end

% Function handle that can be used by GUI elements to access TSNE plot
function tsneFig = tsnePlotButton(~, ~, topics)
    tsneFig = tsnePlot(topics);
end

end