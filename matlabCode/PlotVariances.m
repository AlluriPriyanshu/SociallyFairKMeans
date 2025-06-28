clear;
close all;

% Load the data from the CSV files
data = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedData.csv");
svar = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedDataSVAR.csv");

% Separate the data based on the 'svar' variable
datasep{1} = data(svar == 1, :);
datasep{2} = data(svar == 2, :);
datasep{3} = data(svar == 3, :);
datasep{4} = data(svar == 4, :);
datasep{5} = data(svar == 5, :);

% Create dictionaries for ethnicity and feature names
ethnicity_dict = containers.Map({1, 2, 3, 4, 5}, {'Black', 'Other', 'Asian', 'Hispanic', 'White'});
feature_dict = containers.Map({1, 2, 3}, {'Diener', 'PHQ-9', 'GAD-7'});

% Calculate variances for each group and feature
for svar = 1:5
    for feature = 1:3
        variance(svar, feature) = var(datasep{svar}(:, feature));
    end
end

% Define categorical labels for the x-axis
x = categorical({'Black', 'Other', 'Asian', 'Hispanic', 'White'});
x = reordercats(x, {'Black', 'Other', 'Asian', 'Hispanic', 'White'});

% Define y-axis limits for each feature
ylims_upper = [65, 40, 40];
ylims_lower = [45, 20, 20];

% Plot variances as bar graphs
for plotIndex = 1:3
    subplot(1, 3, plotIndex)
    % Use the bar function to create a bar graph
    bar(x, variance(:, plotIndex), 'FaceColor', [0.3, 0.5, 0.5]);
    
    % Set y-axis limits for better visualization
    ylim([ylims_lower(plotIndex), ylims_upper(plotIndex)]);
    
    % Set the title for each subplot
    title(['Variance by race in ', feature_dict(plotIndex)])
    
    % Optional: Set x and y labels
    xlabel('Ethnicity')
    ylabel('Variance')
end

exportgraphics(gcf,['plottedVariances.tif',],'Resolution',300)

