clear;
close all;

datasetName = 'HMS';
% dateString ='_5_14_2024';
% datasetName = [datasetName,'_SociallyFairImplementation'];
% filename = [datasetName, dateString];
% load(filename)

dateString = '_6_5_2020';
datasetName = [datasetName, '_ElbowCheck'];
filename = [datasetName, dateString];
load(filename);

%Stores the average cost for each number of centers -- for elbow
NumCentersCost = zeros(1,10);
NumNonfairCentersCost = zeros(1,10);


for svar1 =1:4
    for svar2 =svar1+1:5
        for center =1:10
            tempCost = allFairCosts{svar1,svar2}(center,1);
            tempCost = cell2mat(tempCost);
            nonfairTempCost = allNonfairCosts{svar1,svar2}(center,1);
            
            nonfairTempCost = cell2mat(nonfairTempCost);
            
            NumNonfairCentersCost(center) = NumNonfairCentersCost(center) + sum(nonfairTempCost); 
            NumCentersCost(center) = NumCentersCost(center) + sum(tempCost);

        end

    end
end

NumCentersCost = NumCentersCost(1:end);
NumNonfairCentersCost = NumNonfairCentersCost(1:end);

% Plot the results
figure;

% Plot NumCentersCost
plot(1:maxK, NumCentersCost, '-o');
hold on; % Hold on to add another plot on the same figure

% Plot NumNonfairCentersCost
plot(1:maxK, NumNonfairCentersCost, '-x');

% Add labels and title
xlabel('Number of Clusters (k)');
ylabel('Sum of Squared Distances');
title('Elbow Method for Optimal k');
legend('Fair Centers Cost', 'Nonfair Centers Cost');
grid on;

% Save the figure
output_title = [datasetName, '_ElbowCheck_Overlay'];

