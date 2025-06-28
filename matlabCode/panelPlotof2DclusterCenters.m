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
viridis_transparencies = [1.5, 1.5, 1.5, 1.5, 0.8];
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
S = 5;
S_ctr = 25;

datasetName = 'HMS';
datasetName = [datasetName, '_SociallyFairImplementation'];
filename = [datasetName, '_5_14_2024'];
load(filename);

% for svar1 = 1:4
%     for svar2 = svar1+1:5
%         scatter3(fairCenters{svar1,svar2}(:,1), fairCenters{svar1,svar2}(:,2), fairCenters{svar1,svar2}(:,3), 'filled')
%         hold on;
%     end
% end

t = tiledlayout(3,4);

markerType = ['s', 'd', 'p', 'h', '^'];

tileIndex = 1;
for svar1 = 1:4
    for svar2 = svar1+1:5

        tileIndex = tileIndex +1;
        if tileIndex == 4
           tileIndex = tileIndex + 1;
        end

        nexttile(tileIndex);

        
    %      for val  =1:5
    %         %scatter3(centroids{val,1}, centroids{val,2}, centroids{val, 3},S,viridis_color_scheme(val,:), 'filled')
    %         scatter3(datasep{val}(:,1), datasep{val}(:,2), datasep{val}(:,3), S, colors(val,:), markerType(val), 'filled', ...
    % 'MarkerFaceAlpha', viridis_transparencies(val)/2, 'MarkerEdgeColor', 'none');
    % 
    %         hold on;
    %      end
    % 
     % 
     %    scatter3(datasep{svar1}(:,1), datasep{svar1}(:,2), datasep{svar1}(:,3), S, colors(svar1,:), markerType(svar1), 'filled', ...
     % 'MarkerFaceAlpha', viridis_transparencies(svar1)/2, 'MarkerEdgeColor', 'none');
     %    hold on;
     %    scatter3(datasep{svar2}(:,1), datasep{svar2}(:,2), datasep{svar2}(:,3), S, colors(svar2,:), markerType(svar2), 'filled', ...
     % 'MarkerFaceAlpha', viridis_transparencies(svar2)/2, 'MarkerEdgeColor', 'none');
     %    hold on;

        % scatter(unfairCenters{svar1,svar2}(:,2), unfairCenters{svar1,svar2}(:,3),...
        %     1.3*S_ctr, colors(6,:), 'filled', 'MarkerFaceAlpha', 1.0, 'MarkerEdgeColor', 'k', 'LineWidth',1);
        % %scatter3(unfairCenters{svar1,svar2}(:,1), unfairCenters{svar1,svar2}(:,2), unfairCenters{svar1,svar2}(:,3),1.3*S_ctr, viridis_color_scheme(6,:), 'filled', 'MarkerFaceAlpha', 1.0, 'MarkerEdgeColor', 'k')
        % hold on;
        scatter(fairCenters{svar1,svar2}(:,1), fairCenters{svar1,svar2}(:,2),1.3*S_ctr, colors(7,:), 'filled', 'MarkerFaceAlpha', 1.0, 'MarkerEdgeColor', 'k', 'LineWidth',1)
        hold on;


        if tileIndex == 2 | tileIndex == 5 | tileIndex == 9
            xlabel('Diener score');
            ylabel('PHQ 9 score');
        end

        % %xlim([35,50]); 
        % xlim([33,55]); 
        % %ylim([10,25]); 
        % ylim([10,25]); 
        % %zlim([8,22]); 
        % zlim([8,22]); 
        % 
        % xlim([(min(data(:,1)) - 3), (3+max(data(:,1)))]); 
        % ylim([(min(data(:,2)) -3) , (3+max(data(:,2)))]); 
        title(['',ethnicity_dict(svar1),' vs ', ethnicity_dict(svar2)]);
    end
end


L1 = scatter3(nan, nan,nan,  S,colors(1,:), 'filled',markerType(1));
L2 = scatter3(nan, nan,nan,  S,colors(2,:), 'filled',markerType(2));
L3 = scatter3(nan, nan,nan,  S,colors(3,:), 'filled',markerType(3));
L4 = scatter3(nan, nan,nan,  S,colors(4,:), 'filled',markerType(4));
L5 = scatter3(nan, nan,nan,  S,colors(5,:), 'filled',markerType(5));
L6 = scatter3(nan, nan,nan,  S,colors(6,:), 'filled');
L7 = scatter3(nan, nan,nan,  S,colors(7,:), 'filled');
lg  = legend([L1,L2,L3,L4,L5, L6, L7],{'Black', 'Other', 'Asian', 'Hispanic', 'White', 'Not Fair Centers', 'Fair Centers'});
lg.Layout.Tile = 4;