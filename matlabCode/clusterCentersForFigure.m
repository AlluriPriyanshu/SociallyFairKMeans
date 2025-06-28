clear;
close all;

data = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedData.csv");
svar = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedDataSVAR.csv");

datasep{1} = data(svar == 1, :);
datasep{2} = data(svar == 2, :);
datasep{3} = data(svar == 3, :);
datasep{4} = data(svar == 4, :);
datasep{5} = data(svar == 5, :);

ethnicity_dict = containers.Map({1, 2, 3, 4, 5}, {'Black', 'Other', 'Asian', 'Hispanic', 'White'});

viridis_color_scheme = [[253 231 37]; [68, 1, 84] ; [33, 145, 140]; [59, 82, 139]; [94 201, 98]; [255, 0, 0]; [0 0 255]];
viridis_transparencies = [1.5, 1.5, 1.5, 1.5, 0.8];
viridis_color_scheme(:,:) = viridis_color_scheme / 255;

colors = [
    0 0.4470 0.7410;
    0.8500 0.3250 0.0980;
    0.9290 0.6940 0.1250;
    0.4940 0.1840 0.5560;
    0.4660 0.6740 0.1880;
    0.3010 0.7450 0.9330;
    0.6350 0.0780 0.1840
];

S = 15;
S_ctr = 50;

datasetName = 'HMS';
datasetName = [datasetName, '_SociallyFairImplementation'];
filename = [datasetName, '_5_14_2024'];
load(filename);

% Define the specific pairs to plot
svar1 = 1;
svar2_combinations = [2, 5];

% Set up a tiled layout for side-by-side plots
t = tiledlayout(1, 2, 'TileSpacing', 'compact');

% Set consistent marker type for population data points
populationMarkerType = 'o';
fairCenterMarkerType = 's';  % square for fair centers
unfairCenterMarkerType = 'd';  % diamond for unfair centers

% Increase transparency for population data points
populationTransparency = 0.1;  % Increased transparency

tileIndex = 1;
for svar2 = svar2_combinations
    nexttile(tileIndex);
    tileIndex = tileIndex + 1;
    
    %Changes plotting to include entire population, not just bl and wh
    %{
    for svarX = 1:5
        scatter3(datasep{svarX}(:,1), datasep{svarX}(:,2), datasep{svarX}(:,3), S, colors(svarX,:), populationMarkerType, 'filled', ...
        'MarkerFaceAlpha', populationTransparency, 'MarkerEdgeColor', 'none');
        hold on;
    end
    %}

    % Plot population data points with increased transparency
    scatter3(datasep{svar1}(:,1), datasep{svar1}(:,2), datasep{svar1}(:,3), S, colors(svar1,:), populationMarkerType, 'filled', ...
        'MarkerFaceAlpha', populationTransparency, 'MarkerEdgeColor', 'none');
    hold on;
    scatter3(datasep{svar2}(:,1), datasep{svar2}(:,2), datasep{svar2}(:,3), S, colors(svar2,:), populationMarkerType, 'filled', ...
        'MarkerFaceAlpha', populationTransparency, 'MarkerEdgeColor', 'none');
    hold on;

    % Plot unfair centers with different shape
    scatter3(unfairCenters{svar1,svar2}(:,1), unfairCenters{svar1,svar2}(:,2), unfairCenters{svar1,svar2}(:,3), ...
        1.3*S_ctr, colors(6,:), unfairCenterMarkerType, 'filled', 'MarkerFaceAlpha', 1.0, 'MarkerEdgeColor', 'k', 'LineWidth', 1);
    hold on;

    % Plot fair centers with different shape
    scatter3(fairCenters{svar1,svar2}(:,1), fairCenters{svar1,svar2}(:,2), fairCenters{svar1,svar2}(:,3), ...
        1.3*S_ctr, colors(7,:), fairCenterMarkerType, 'filled', 'MarkerFaceAlpha', 1.0, 'MarkerEdgeColor', 'k', 'LineWidth', 1);
    hold on;

    xlabel('Flourishing score');
    ylabel('PHQ 9 score');
    zlabel('GAD 7 score');

    xlim([(min(data(:,1)) - 3), (3 + max(data(:,1)))]); 
    ylim([(min(data(:,2)) - 3), (3 + max(data(:,2)))]); 
    zlim([(min(data(:,3)) - 3), (3 + max(data(:,3)))]); 
    title(['', ethnicity_dict(svar1), ' vs ', ethnicity_dict(svar2)]);
end

% Simplified legend with three entries
L_population = scatter3(nan, nan, nan, S, 'k', populationMarkerType, 'filled');
L_unfairCenters = scatter3(nan, nan, nan, S, colors(6,:), unfairCenterMarkerType, 'filled');
L_fairCenters = scatter3(nan, nan, nan, S, colors(7,:), fairCenterMarkerType, 'filled');

lg = legend([L_population, L_unfairCenters, L_fairCenters], {'Population', 'Standard Centers', 'Socially Fair Centers'});
lg.Layout.Tile = 'north';

exportgraphics(gcf,['ClusterCentersK3.tif',],'Resolution',300)
