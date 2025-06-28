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

viridis_color_scheme =[[253 231 37]; [94 201, 98]; [33, 145, 140]; [59, 82, 139]; [68, 1, 84]];
viridis_transparencies = [1.5, 1.5, 1.5, 1.5, 0.8];
viridis_color_scheme(:,:) = viridis_color_scheme/255;
a = datasep{1}(:,1);
b =datasep{1}(:,2);
c = datasep{1}(:,3);
S = 10;

colors = [
    0 0.4470 0.7410;
    0.8500 0.3250 0.0980;...
    0.9290 0.6940 0.1250;...
    0.4940 0.1840 0.5560;...
    0.4660 0.6740 0.1880;...
    0.3010 0.7450 0.9330;...
    0.6350 0.0780 0.1840...
];
t = tiledlayout(3,4);

tileIndex = 1;
for svar1 = 1:4
    for svar2 = svar1+1:5

        tileIndex = tileIndex +1;
        if tileIndex == 4
           tileIndex = tileIndex + 1;
        end

        nexttile(tileIndex);
        
        scatter3(datasep{svar1}(:,1), datasep{svar1}(:,2), datasep{svar1}(:,3),S,colors(svar1,:), 'filled');
        %scatter3(centroids{svar1,1}, centroids{svar1,2}, centroids{svar1, 3},S,viridis_color_scheme(svar1,:), 'filled')
        %scatter3(medioids{svar1,1}, medioids{svar1,2}, medioids{svar1, 3},S,viridis_color_scheme(svar1,:), 'filled')
        hold on;
        scatter3(datasep{svar2}(:,1), datasep{svar2}(:,2), datasep{svar2}(:,3),S,colors(svar2,:), 'filled');
        %scatter3(centroids{svar2,1}, centroids{svar2,2}, centroids{svar2, 3},S,viridis_color_scheme(svar2,:), 'filled')
        %scatter3(medioids{svar2,1}, medioids{svar2,2}, medioids{svar2, 3},S,viridis_color_scheme(svar2,:), 'filled')
        hold on;

        if tileIndex == 2 | tileIndex == 5 | tileIndex == 9
            xlabel('Diener score');
            ylabel('PHQ 9 score');
            zlabel('GAD 7 score');
        end

        xlim([(min(data(:,1)) - 3), (3+max(data(:,1)))]); 
        ylim([(min(data(:,2)) -3) , (3+max(data(:,2)))]); 
        zlim([(min(data(:,3)) - 3), (3+ max(data(:,3)))]); 
        title(['Median ',ethnicity_dict(svar1),' vs Median ', ethnicity_dict(svar2)]);
    end
end

L1 = scatter3(nan, nan,nan,  S,colors(1,:), 'filled');
L2 = scatter3(nan, nan,nan,  S,colors(2,:), 'filled');
L3 = scatter3(nan, nan,nan,  S,colors(3,:), 'filled');
L4 = scatter3(nan, nan,nan,  S,colors(4,:), 'filled');
L5 = scatter3(nan, nan,nan,  S,colors(5,:), 'filled');
lg  = legend([L1,L2,L3,L4,L5],{'Black', 'Other', 'Asian', 'Hispanic', 'White'});
lg.Layout.Tile = 4;




