%Generates a 3d plot of each fair pair as one panel plot
clear;
close all;

data = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedData.csv");

svar = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedDataSVAR.csv");

datasep{1} = data(svar == 1, :);
datasep{2} = data(svar == 2, :);
datasep{3} = data(svar == 3, :);
datasep{4} = data(svar == 4, :);
datasep{5} = data(svar == 5, :);

centroids = cell(5,4);
medioids = cell(5,4);
for i = 1:5
    for feature = 1:3
        centroids{i,feature} = mean(datasep{i}(:,feature));
        medioids{i, feature} = median(datasep{i}(:, feature));
    end
end


ethnicity_dict = containers.Map({1, 2, 3, 4, 5}, {'Black', 'Other', 'Asian', 'Hispanic', 'White'});

viridis_color_scheme =[[253 231 37]; [68, 1, 84] ; [33, 145, 140]; [59, 82, 139]; [94 201, 98]; [255, 0, 0]; [0 0 255]];

viridis_color_scheme(:,:) = viridis_color_scheme/255;

colors = [
    0 0.4470 0.7410;
    0.8500 0.3250 0.0980;...
    0.9290 0.6940 0.1250;...
    0.4940 0.1840 0.5560;...
    0.4660 0.6740 0.1880;...
    0.3010 0.7450 0.9330;...
    0.6350 0.0780 0.1840...
];

S = 10;




% Create a new figure
figure;

% Define the positions for the subplots
pos1 = [0.25, 0.55, 0.2, 0.4]; % Top-left plot
pos2 = [0.55, 0.55, 0.2, 0.4]; % Top-right plot
pos3 = [0.1, 0.05, 0.2, 0.4];  % Bottom-left plot
pos4 = [0.4, 0.05, 0.2, 0.4];  % Bottom-center plot
pos5 = [0.7, 0.05, 0.2, 0.4];  % Bottom-right plot


% Create the top-left plot
subplot('Position', pos1);
h1 = scatter3(datasep{1}(:,1), datasep{1}(:,2), datasep{1}(:,3),S,colors(1,:), 'filled', 'DisplayName',ethnicity_dict(1));
title('Black');
xlabel('Diener score');
ylabel('PHQ 9 score');
zlabel('GAD 7 score');

% Create the top-right plot
subplot('Position', pos2);
h2 = scatter3(datasep{2}(:,1), datasep{2}(:,2), datasep{2}(:,3),S,colors(2,:), 'filled', 'DisplayName',ethnicity_dict(2));
title('Other');

% Create the bottom-left plot
subplot('Position', pos3);
h3 = scatter3(datasep{3}(:,1), datasep{3}(:,2), datasep{3}(:,3),S,colors(3,:), 'filled', 'DisplayName',ethnicity_dict(3));
title('Asian');
xlabel('Diener score');
ylabel('PHQ 9 score');
zlabel('GAD 7 score');


% Create the bottom-center plot
subplot('Position', pos4);
h4 = scatter3(datasep{4}(:,1), datasep{4}(:,2), datasep{4}(:,3),S,colors(4,:), 'filled', 'DisplayName',ethnicity_dict(4));
title('Hispanic');

% Create the bottom-right plot
subplot('Position', pos5);
h5 = scatter3(datasep{5}(:,1), datasep{5}(:,2), datasep{5}(:,3),S,colors(5,:), 'filled', 'DisplayName',ethnicity_dict(5));
title('White');


allHandles = [h1, h2, h3, h4, h5];

% Create a single legend
%legend(allHandles, 'Location', 'northeastoutside');
legend(allHandles, 'Position', [0.75, 0.75, 0.2, 0.1], 'Orientation', 'vertical');

