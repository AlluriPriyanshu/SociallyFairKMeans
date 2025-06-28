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
viridis_transparencies = [1, 1.0, 1.0, 1.0, 1.0];

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
a = datasep{1}(:,1);
b =datasep{1}(:,2);
c = datasep{1}(:,3);
S = 40;
S_ctr = 25;

color = [0.992156862745098 0.905882352941177 0.145098039215686];
color = viridis_color_scheme(1,:);
scatter3(a,b,c,S,color);

datasetName = 'HMS';
datasetName = [datasetName, '_SociallyFairImplementation'];
filename = [datasetName, '_5_14_2020'];
load(filename);

% for svar1 = 1:4
%     for svar2 = svar1+1:5
%         scatter3(fairCenters{svar1,svar2}(:,1), fairCenters{svar1,svar2}(:,2), fairCenters{svar1,svar2}(:,3), 'filled')
%         hold on;
%     end
% end


for svar1 = 1:4
    for svar2 = svar1+1:5



         for val  =1:5
            scatter3(centroids{val,1}, centroids{val,2}, centroids{val, 3},S,colors(val,:), 'filled','MarkerEdgeColor', 'k', 'MarkerFaceAlpha', 1.0)
            %scatter3(datasep{val}(:,1), datasep{val}(:,2), datasep{val}(:,3),S,viridis_color_scheme(val,:),'filled' ,'MarkerFaceAlpha', viridis_transparencies(val)/2, 'MarkerEdgeColor','none');
            hold on;
         end
       

        xlabel('Diener score');
        ylabel('PHQ 9 score');
        zlabel('GAD 7 score');

        %xlim([35,50]); 
        xlim([44,48]); 
        %ylim([10,25]); 
        ylim([14,17]); 
        %zlim([8,22]); 
        zlim([11,14]); 
        
        title(['Averages across Diener, PHQ-9, and GAD-7 by Race']);
    end
end


L1 = scatter3(nan, nan,nan,  S,colors(1,:), 'filled');
L2 = scatter3(nan, nan,nan,  S,colors(2,:), 'filled');
L3 = scatter3(nan, nan,nan,  S,colors(3,:), 'filled');
L4 = scatter3(nan, nan,nan,  S,colors(4,:), 'filled');
L5 = scatter3(nan, nan,nan,  S,colors(5,:), 'filled');
lg  = legend([L1,L2,L3,L4,L5],{'Black', 'Other', 'Asian', 'Hispanic', 'White'});
lg.Layout.Tile = 4;