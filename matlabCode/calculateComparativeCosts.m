%Priyanshu Alluri
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

%cell that stores the data associated with each sample
calcCost_data = datasep;
dataTemp = [calcCost_data{1};calcCost_data{2};calcCost_data{3}; calcCost_data{4};calcCost_data{5}];
ns = [size(calcCost_data{1}, 1), size(calcCost_data{2}, 1), size(calcCost_data{3}, 1),...
    size(calcCost_data{4}, 1), size(calcCost_data{5}, 1)];

%CCdatawoPCA is a concatenated version of calcCost_Data --> data is stored
%in one matrix


CCdatawoPCA = dataTemp;
for svar1 = 1:4
    for svar2 = svar1+1:5

        datasetName = 'HMS';
        svar1_name = ethnicity_dict(svar1);
        svar2_name = ethnicity_dict(svar2);
        datasetName = [datasetName, '_', svar1_name, 'vs', svar2_name];
        filename = [datasetName, dateString];
        load(filename);

        numCenters = 3;

        %this line doesn't seem to do anything. Consider removing -- PA
        CostNF{k} = compCost({datawoPCA(svar==1,:), datawoPCA(svar==2,:)}, ...
                svar, k, clusteringNF{k}, 1);

        k = 3; %k is equal to numCenters

        costs = zeros(numBootstrapIters,5);
        for i = 1:numBootstrapIters
            bootstat{1,5} = [];
            for svarIndex = 1:5
                bootstat{svarIndex} = datasample(calcCost_data{svarIndex},192); 
            end
            %TODO errors in the code running may be caused by the function
            %below -- remove the second output (clusterings)
             [costs(i,:),~] = bootstrappedCostCalculator(bootstat, centersNF);
        end
        comparativeCosts{svar1,svar2} = costs;
        unnormalizedCompCosts{svar1,svar2} = unnormalizeData(costs,originalData);
    end
end
disp("Pre Graph")

x = categorical({'Black', 'Other', 'Asian', 'Hispanic', 'White'});
x = reordercats(x,{'Black', 'Other', 'Asian', 'Hispanic', 'White'}); 
x = x(:);
dummyVars = dummyvar(x);

plotIndex = 1;
figure;
for svar1 = 1:4
    for svar2 = svar1+1:5
        %figure;


        %Normalized Run
        y= comparativeCosts{svar1,svar2};
        meanY = mean(comparativeCosts{svar1,svar2});

        %unnormalized run
        % y = unnormalizedCompCosts{svar1,svar2};
        % meanY= mean(unnormalizedCompCosts{svar1,svar2});
        
        x = categorical({'Other','Black', 'Hispanic', 'Asian', 'White'});
        x = reordercats(x, { 'Other','Black', 'Hispanic', 'Asian', 'White'}); 
    
        x = x(:);
        y_order = [2, 1, 4, 3, 5];
        y = comparativeCosts{svar1,svar2}(:, y_order);
        meanY = mean(comparativeCosts{svar1,svar2}(:, y_order));
        subplot(3,4,plotIndex+1)
        plotIndex = plotIndex + 1;
        if plotIndex == 3
           plotIndex = plotIndex + 1;
        end

        plot(x, y, '-', 'LineWidth', 2, 'Color',[0.3,0.5,0.5,0.2]); % 'o-' means circles connected by lines
        xlabel('Race');
        ylabel('Costs');
        ylim([1 7])
        hold on;

        %plots the average
        plot(x,meanY,'o-', 'LineWidth', 1, 'Color',[1,0,0], 'MarkerSize',2)
        % hold on;
        
        
        title(['', ethnicity_dict(svar1),' and ', ethnicity_dict(svar2)]);
        xticklabels(x);
        exportgraphics(gcf,['ClusteringCostPair', ethnicity_dict(svar1),'and', ethnicity_dict(svar2),'.png',],'Resolution',300)
        %grid on;

    end
end

%hold off;

% 
% %legend('Black v Other', 'Black v Asian', 'Black v Hispanic', 'Black v White', ...
%     'Other v Asian', 'Other v Hispanic', 'Other v White', 'Asian v Hispanic',...
%     'Asian v White', 'Hispanic v White');


