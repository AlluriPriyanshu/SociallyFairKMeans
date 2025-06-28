clear;
close all;

data = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedData.csv");

svar = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedDataSVAR.csv");


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

S = 25;
datasetName = 'HMS';
datasetName = [datasetName, '_SociallyFairImplementation'];
filename = [datasetName, '_5_14_2024'];
load(filename);

for svar1 = 1:4
    for svar2 = svar1+1:5
        scatter3(fairCenters{svar1,svar2}(:,1), fairCenters{svar1,svar2}(:,2), fairCenters{svar1,svar2}(:,3), 'filled')
        hold on;
    end
end

datasep{1} = data(svar == 1, :);
datasep{2} = data(svar == 2, :);
datasep{3} = data(svar == 3, :);
datasep{4} = data(svar == 4, :);
datasep{5} = data(svar == 5, :);

ethnicity_dict = containers.Map({1, 2, 3, 4, 5}, {'Black', 'Other', 'Asian', 'Hispanic', 'White'});

centroids = cell(5,4);
medioids = cell(5,4);

for i = 1:5
    for feature = 1:3
        centroids{i,feature} = mean(datasep{i}(:,feature));
        medioids{i,feature} = median(datasep{i}(:,feature));
    end
end

for i = 1:5
    if i <=5
        scatter3(datasep{i}(:,1), datasep{i}(:,2), datasep{i}(:,3), S,colors(i,:), 'filled');
        %scatter3(centroids{i,1}, centroids{i,2}, centroids{i, 3}, 'filled')
        %scatter3(medioids{i,1}, medioids{i,2}, medioids{i, 3}, 'filled')
        hold on;
    end
end

legend('Black', 'Other', 'Asian', 'Hispanic', 'White');

xlim([5, 60]); % Set x-axis limits from 0 to 1
ylim([5, 40]); % Set y-axis limits from 0 to 1
zlim([5, 30]); % Set z-axis limits from 0 to 1

title('');
xlabel('Diener score');
ylabel('PHQ 9 score');
zlabel('GAD 7 score');