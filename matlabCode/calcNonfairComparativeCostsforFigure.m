clear;
close all;

dateString = '_5_14_2024';
ethnicity_dict = containers.Map({1, 2, 3, 4, 5}, {'Black', 'Other', 'Asian', 'Hispanic', 'White'});

calcCost_data = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedData.csv");

comparativeCosts = cell(4,4);
unnormalizedCompCosts = cell(4,4);
svar = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedDataSVAR.csv");
originalData = calcCost_data;

calcCost_data = normalizeData(calcCost_data());

numBootstrapIters = 10000;

datasep{1} = calcCost_data(svar == 1, :);
datasep{2} = calcCost_data(svar == 2, :);
datasep{3} = calcCost_data(svar == 3, :);
datasep{4} = calcCost_data(svar == 4, :);
datasep{5} = calcCost_data(svar == 5, :);

% Store the data associated with each sample
calcCost_data = datasep;
dataTemp = [calcCost_data{1}; calcCost_data{2}; calcCost_data{3}; calcCost_data{4}; calcCost_data{5}];
ns = [size(calcCost_data{1}, 1), size(calcCost_data{2}, 1), size(calcCost_data{3}, 1), size(calcCost_data{4}, 1), size(calcCost_data{5}, 1)];

% Concatenate the data
CCdatawoPCA = dataTemp;

% Specify the combinations to plot
svar1 = 1;
svar2_combinations = [2, 5];

plotIndex = 1;
figure;
for svar2 = svar2_combinations

    datasetName = 'HMS';
    svar1_name = ethnicity_dict(svar1);
    svar2_name = ethnicity_dict(svar2);
    datasetName = [datasetName, '_', svar1_name, 'vs', svar2_name];
    filename = [datasetName, dateString];
    load(filename);

    numCenters = 3;

    CostNF{k} = compCost({datawoPCA(svar==1,:), datawoPCA(svar==2,:)}, ...
            svar, k, clusteringNF{k}, 1);

    k = 3;

    costs = zeros(numBootstrapIters,5);
    for i = 1:numBootstrapIters
        bootstat{1,5} = [];
        for svarIndex = 1:5
            bootstat{svarIndex} = datasample(calcCost_data{svarIndex},192); 
        end
        [costs(i,:),~] = bootstrappedCostCalculator(bootstat, centersN);
    end
    comparativeCosts{svar1,svar2} = costs;
    unnormalizedCompCosts{svar1,svar2} = unnormalizeData(costs,originalData);

    % Plotting
    % x = categorical({'Black', 'Other', 'Asian', 'Hispanic', 'White'});
    % x = reordercats(x, {'Black', 'Other', 'Asian', 'Hispanic', 'White'}); 
    % x = x(:);
    % y = comparativeCosts{svar1,svar2};
    % meanY = mean(comparativeCosts{svar1,svar2});


    x = categorical({'Other','Black', 'Hispanic', 'Asian', 'White'});
    x = reordercats(x, { 'Other','Black', 'Hispanic', 'Asian', 'White'}); 

    x = x(:);
    y_order = [2, 1, 4, 3, 5];
    y = comparativeCosts{svar1,svar2}(:, y_order);
    meanY = mean(comparativeCosts{svar1,svar2}(:, y_order));
    subplot(1,2,plotIndex)
    plotIndex = plotIndex + 1;

    plot(x, y, '-', 'LineWidth', 2, 'Color',[0.3,0.5,0.5,0.2]); 
    xlabel('Race');
    ylabel('Costs');
    ylim([1 7])
    hold on;

    plot(x,meanY,'o-', 'LineWidth', 1, 'Color',[1,0,0], 'MarkerSize',2)
    
    title(['Nonfair ', ethnicity_dict(svar1),' and ', ethnicity_dict(svar2)]);
    xticklabels(x);

end

    % exportgraphics(gcf,['NonfairClusteringCosts.tif',],'Resolution',300)
