clear;
close all;

randomSeed=12345;
rng(randomSeed);

datasetName = 'HMS';

% Create a dictionary mapping input values to corresponding labels
ethnicity_dict = containers.Map({1, 2, 3, 4, 5}, {'Black', 'Other', 'Asian', 'Hispanic', 'White'});

load("dataDiff.mat")

data = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedData.csv");

svar = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedDataSVAR.csv");
colors = [
    0 0.4470 0.7410;
    0.8500 0.3250 0.0980;...
    0.9290 0.6940 0.1250;...
    0.4940 0.1840 0.5560;...
    0.4660 0.6740 0.1880;...
    0.3010 0.7450 0.9330;...
    0.6350 0.0780 0.1840...
];



S = 5;
S_ctr = 25;

datasetName = 'HMS';
datasetName = [datasetName, '_SociallyFairImplementation'];
filename = [datasetName, '_5_14_2024'];
load(filename);

viridis_color_scheme =[[253 231 37]; [68, 1, 84] ; [33, 145, 140]; [59, 82, 139]; [94 201, 98]; [255, 0, 0]; [0 0 255]];
viridis_transparencies = [1.5, 1.5, 1.5, 1.5, 0.8];
viridis_color_scheme(:,:) = viridis_color_scheme/255;


for feature = 1:3
    s1 = 1;
    s2 = s1 + 1;
for i=1:10
    if s2 ==6
        s1 = s1 +1;
        s2 = s1 + 1;
    end
    variance(i,feature) = var(dataDiff{s1,s2}(:,feature));
    s2 = s2 + 1;
end
end

k = 3;
tileIndex = 1;
for svar1 = 1:4
    for svar2 = svar1+1:5

        tileIndex = tileIndex +1;
        if tileIndex == 4
           tileIndex = tileIndex + 1;
        end

        nexttile(tileIndex);
        scatter3(dataDiff{svar1,svar2}(:,1), dataDiff{svar1,svar2}(:,2), dataDiff{svar1,svar2}(:,3), S, colors(svar1,:), 'filled', ...
     'MarkerFaceAlpha', viridis_transparencies(svar1)/2, 'MarkerEdgeColor', 'none');
        hold on;
     %    scatter3(dataDiff{svar2}(:,1), dataDiff{svar2}(:,2), dataDiff{svar2}(:,3), S, colors(svar2,:), markerType(svar2), 'filled', ...
     % 'MarkerFaceAlpha', viridis_transparencies(svar2)/2, 'MarkerEdgeColor', 'none');
     %    hold on;


        xlim([(min(data(:,1)) - 3), (3+max(data(:,1)))]); 
        ylim([(min(data(:,2)) -3) , (3+max(data(:,2)))]); 
        zlim([(min(data(:,3)) - 3), (3+ max(data(:,3)))]); 
        title(['',ethnicity_dict(svar1),' vs ', ethnicity_dict(svar2)]);
    end
end



feature_dict = containers.Map({1,2,3}, {'Diener', 'PHQ-9', 'GAD-7'});
x = categorical({'BvO', 'BvA', 'BvH', 'BvW', 'OvA', 'OvH', 'OvW', 'AvH', 'AvW', 'HvW'});
x = reordercats(x,{'BvO', 'BvA', 'BvH', 'BvW', 'OvA', 'OvH', 'OvW', 'AvH', 'AvW', 'HvW'}); 
% x = x(:);
% dummyVars = dummyvar(x);
% 
% ylims_upper = [65, 40, 40];
% ylims_lower = [45, 20, 20];
for plotIndex = 1:3
    subplot(2,2,plotIndex)
    plot(x, variance(:,plotIndex), '-', 'LineWidth', 2, 'Color',[0.3,0.5,0.5]); % 'o-' means circles connected by lines
    %ylim([ylims_lower(plotIndex), ylims_upper(plotIndex)]); % Set y-axis limits from 0 to 1
    title(['Variance by race in ', feature_dict(plotIndex)])
end

