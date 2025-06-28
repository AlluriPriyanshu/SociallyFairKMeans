clear;
close all;

datasetName = 'HMS';
dateString = '_5_12_2024';

datasetName = [datasetName, '_1MeanProcedure'];
filename = [datasetName, dateString];
load(filename);


for i = 1:5
    scatter3(OneMeanCenters{i}(:,1), OneMeanCenters{i}(:,2), OneMeanCenters{i}(:,3), 'filled');
    hold on;
end

legend('Black', 'Other', 'Asian', 'Hispanic', 'White');

xlim([5, 60]); % Set x-axis limits from 0 to 1
ylim([5, 40]); % Set y-axis limits from 0 to 1
zlim([5, 30]); % Set z-axis limits from 0 to 1

title('One-Mean Procedure Centroids');
xlabel('Diener score');
ylabel('PHQ 9 score');
zlabel('GAD 7 score');