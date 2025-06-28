%Generates a 3d plot of each fair pair individually (not as a panel plot)

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
for i = 1:5
    for feature = 1:3
        centroids{i,feature} = mean(datasep{i}(:,feature));
    end
end

ethnicity_dict = containers.Map({1, 2, 3, 4, 5}, {'Black', 'Other', 'Asian', 'Hispanic', 'White'});

viridis_color_scheme =[[253 231 37]; [94 201, 98]; [33, 145, 140]; [59, 82, 139]; [68, 1, 84]];

viridis_color_scheme(:,:) = viridis_color_scheme/255;
a = datasep{1}(:,1);
b =datasep{1}(:,2);
c = datasep{1}(:,3);
S = 10;


for svar1 = 1:4
    for svar2 = svar1+1:5

        
        %scatter3(datasep{svar1}(:,1), datasep{svar1}(:,2), datasep{svar1}(:,3),S,viridis_color_scheme(svar1,:), 'filled');
        scatter3(centroids{svar1,1}, centroids{svar1,2}, centroids{svar1, 3},S,viridis_color_scheme(svar1,:), 'filled')
        hold on;
        %scatter3(datasep{svar2}(:,1), datasep{svar2}(:,2), datasep{svar2}(:,3),S,viridis_color_scheme(svar2,:), 'filled');
        scatter3(centroids{svar2,1}, centroids{svar2,2}, centroids{svar2, 3},S,viridis_color_scheme(svar2,:), 'filled')
        hold off;

        xlabel('Diener score');
        ylabel('PHQ 9 score');
        zlabel('GAD 7 score');


        xlim([(min(data(:,1)) - 3), (3+max(data(:,1)))]); 
        ylim([(min(data(:,2)) -3) , (3+max(data(:,2)))]); 
        zlim([(min(data(:,3)) - 3), (3+ max(data(:,3)))]); 
        title(['Mean ',ethnicity_dict(svar1),' vs Mean ', ethnicity_dict(svar2)]);
        pause(1)
    end
end

L1 = scatter3(nan, nan,nan,  S,viridis_color_scheme(1,:), 'filled');
L2 = scatter3(nan, nan,nan,  S,viridis_color_scheme(2,:), 'filled');
L3 = scatter3(nan, nan,nan,  S,viridis_color_scheme(3,:), 'filled');
L4 = scatter3(nan, nan,nan,  S,viridis_color_scheme(4,:), 'filled');
L5 = scatter3(nan, nan,nan,  S,viridis_color_scheme(5,:), 'filled');
lg  = legend([L1,L2,L3,L4,L5],{'Black', 'Other', 'Asian', 'Hispanic', 'White'});





