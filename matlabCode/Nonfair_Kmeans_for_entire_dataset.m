% Clear the workspace and close all figures
clear;
close all;

% Set the random seed for reproducibility
randomSeed = 12345;
rng(randomSeed);

% Define the number of clusters
k = 3; % Adjust this value as needed

% Read the data from the CSV file
dataAll = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedData.csv");

% Perform k-means clustering on the first three columns (excluding race)
[idx, C] = kmeans(dataAll(:,1:3), k);

% Extract the race column
race = dataAll(:,4);

% Define the ethnicity dictionary
ethnicity_dict = containers.Map({1, 2, 3, 4, 5}, {'Black', 'Other', 'Asian', 'Hispanic', 'White'});

% Initialize a matrix to store the count of each race in each cluster
raceCounts = zeros(k, 5); % 5 is the number of races

% Calculate the number of individuals in each race within each cluster
for i = 1:k
    for j = 1:5
        raceCounts(i, j) = sum((idx == i) & (race == j));
    end
end

% Calculate the total number of individuals in each race in the entire dataset
totalRaceCounts = zeros(1, 5);
for j = 1:5
    totalRaceCounts(j) = sum(race == j);
end

% Convert counts to percentages (percentage of people in each race that are in each cluster)
racePercentages = (raceCounts ./ totalRaceCounts) * 100;

% Convert the racePercentages matrix to a table with race names
raceNames = values(ethnicity_dict);
raceTable = array2table(racePercentages, 'VariableNames', raceNames, 'RowNames', strcat('Cluster_', string(1:k)));

% Display the race breakdown in each cluster as percentages
disp('Percentage of people in each race that are in each cluster:');
disp(raceTable);

% Create the bar chart
figure;
bar(racePercentages);
xlabel('Cluster'); % Changed from 'Cluster Number' to 'Cluster Name'
ylabel('Percentage');
title('Percentage of Each Race in Each Cluster');
legend(raceNames, 'Location', 'BestOutside');

% Define new cluster names
clusterNames = {'Getting By', 'Struggling', ' flourishing'}; % Change these names as needed

% Set the new cluster names as XTickLabels
set(gca, 'XTickLabel', clusterNames);
xtickangle(45);

% Adjust the figure to make sure everything fits
set(gcf, 'Position', [100, 100, 1200, 600]);

% Visualize the clustering result
viridis_transparencies = [1.5, 1.5, 1.5, 1.5, 0.8];
markerType = ['s', 'd', 'p', 'h', '^'];

colors = [
    0 0.4470 0.7410;
    0.8500 0.3250 0.0980;
    0.9290 0.6940 0.1250;
    0.4940 0.1840 0.5560;
    0.4660 0.6740 0.1880;
    0.3010 0.7450 0.9330;
    0.6350 0.0780 0.1840
];

S = 8;
S_ctr = 25;

figure;
scatter3(dataAll(:,1), dataAll(:,2), dataAll(:,3), 10, idx, 'filled');
hold on;
scatter3(C(:,1), C(:,2), C(:,3), 1.3*S_ctr, colors(6,:), 'filled', 'MarkerFaceAlpha', 1.0, 'MarkerEdgeColor', 'k', 'LineWidth', 1);
title('K-means Clustering (3D)');
xlabel('Diener score');
ylabel('PHQ 9 score');
zlabel('GAD 7 score');
legend("Non-Fair Kmeans Centers");

hold off;
