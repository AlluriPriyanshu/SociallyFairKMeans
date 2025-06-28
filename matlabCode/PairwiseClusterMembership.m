% Priyanshu Alluri
clear;
close all;

dateString = '_5_14_2024';
dateString = '_4_26_2020';
ethnicity_dict = containers.Map({1, 2, 3, 4, 5}, {'Black', 'Other', 'Asian', 'Hispanic', 'White'});

calcCost_data = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedData.csv");
comparativeCosts = cell(4,4);
unnormalizedCompCosts = cell(4,4);
svar = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedDataSVAR.csv");
originalData = calcCost_data;

calcCost_data = normalizeData(calcCost_data);
numBootstrapIters = 10000;

datasep{1} = calcCost_data(svar == 1, :);
datasep{2} = calcCost_data(svar == 2, :);
datasep{3} = calcCost_data(svar == 3, :);
datasep{4} = calcCost_data(svar == 4, :);
datasep{5} = calcCost_data(svar == 5, :);

% cell that stores the data associated with each sample
calcCost_data = datasep;
dataTemp = [calcCost_data{1}; calcCost_data{2}; calcCost_data{3}; calcCost_data{4}; calcCost_data{5}];
ns = [size(calcCost_data{1}, 1), size(calcCost_data{2}, 1), size(calcCost_data{3}, 1), ...
    size(calcCost_data{4}, 1), size(calcCost_data{5}, 1)];

% Concatenate data into one matrix
CCdatawoPCA = dataTemp;

colors = [
    0 0.4470 0.7410;
    0.8500 0.3250 0.0980;
    0.9290 0.6940 0.1250;
    0.4940 0.1840 0.5560;
    0.4660 0.6740 0.1880;
    0.3010 0.7450 0.9330;
    0.6350 0.0780 0.1840
];

% Create a figure for the subplots
figure;

% Counter for subplot indexing
subplotIdx = 1;

% Loop over the combinations of svar1 and svar2
for svar1 = 1:4
    for svar2 = svar1+1:5

        datasetName = 'HMS';
        svar1_name = ethnicity_dict(svar1);
        svar2_name = ethnicity_dict(svar2);
        datasetName = [datasetName, '_', svar1_name, 'vs', svar2_name];
        filename = [datasetName, dateString];
        load(filename);

        numCenters = 3;

        k = 3; % k is equal to numCenters
        dataAll(:,5) = clusteringN{3}(1,:);
        race = dataAll(:, 4);
        clusters = dataAll(:, 5);

        %stores the centerIndices in order to give: Flourishing, Getting By, and Struggling (in that order)
        centerLabels = [];

        placeholder = sort(centersN{3}(:,1),'descend');
        for plcIdx = 1:k
            for center = 1:k
                if placeholder(plcIdx) == centersN{3}(center,1)
                    centerLabels(plcIdx) = center;
                end
            end
        end
        


        % Define the number of clusters
        k = max(clusters);

        % Initialize a matrix to store the count of each race in each cluster
        raceCounts = zeros(k, 5); % 5 is the number of races

        % Calculate the number of individuals in each race within each cluster
        for i = 1:k
            for j = 1:5
                raceCounts(i, j) = sum((clusters == i) & (race == j));
            end
        end

        % Calculate the total number of individuals in each race in the entire dataset
        totalRaceCounts = zeros(1, 5);
        for j = 1:5
            totalRaceCounts(j) = sum(race == j);
        end

        % Convert counts to percentages (percentage of each race within each cluster)
        racePercentages = (raceCounts ./ totalRaceCounts) * 100;

        % Convert the racePercentages matrix to a table with race names
        raceNames = values(ethnicity_dict);
        raceTable = array2table(racePercentages, 'VariableNames', raceNames, 'RowNames', strcat('Cluster_', string(1:k)));

        raceTableCopy = raceTable;
        racePercentagesCopy = racePercentages;
        for center= 1:k
            raceTable(center,:) = raceTableCopy(centerLabels(center),:);
            racePercentages(center,:) = racePercentagesCopy(centerLabels(center),:);
        end

        % Identify columns with any NaN values
        colsWithNaN = any(isnan(racePercentages), 1);
        
        % Remove those columns
        racePercentages(:, colsWithNaN) = [];

        % Display the race breakdown in each cluster as percentages
        disp('Percent Race in Cluster:');
        disp(raceTable);

        % Create a subplot for each comparison
        subplot(4, 3, subplotIdx);
        b = bar(racePercentages, 'grouped');

        b(1).FaceColor = colors(svar1,:);
        b(2).FaceColor = colors(svar2,:);
        %xlabel('Cluster Name');
        ylabel('Percentage in Cluster');
        title([svar1_name, ' vs ', svar2_name]);
        ylim([0,100]);

        % Define new cluster names
        clusterNames = {'Flourishing', 'Getting By', 'Struggling'}; % Change these names as needed

        % Set the new cluster names as XTickLabels
        set(gca, 'XTickLabel', clusterNames);
        xtickangle(45);

        % Increment the subplot index
        subplotIdx = subplotIdx + 1;
    end
end

% Adjust the figure to make sure everything fits
set(gcf, 'Position', [100, 100, 1200, 1200]);

% Add the legend to the tiled layout
legendColors = colors(1:5, :); % assumes 5 groups
dummyBars = gobjects(length(legendColors), 1);
hold on; 

for i = 1:length(legendColors)
    dummyBars(i) = bar(nan, nan, 'FaceColor', legendColors(i, :));
end

% Define race names for the legend
raceNames = values(ethnicity_dict);

% Create the legend outside the tiled layout
lgd = legend(dummyBars, raceNames, 'Orientation', 'vertical', 'Location', 'none');
lgd.Position = [0.75, 0.15, 0.1, 0.1];  % Adjust these values