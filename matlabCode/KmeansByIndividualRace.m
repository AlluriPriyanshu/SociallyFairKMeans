clear;
close all;

randomSeed=12345;
rng(randomSeed);

% Input of loadData is either 'credit', 'adult', or 'LFW'
% 'svar' is the sensitive variable
datasetName = 'HMS';

% Create a dictionary mapping input values to corresponding labels
ethnicity_dict = containers.Map({1, 2, 3, 4, 5}, {'Black', 'Other', 'Asian', 'Hispanic', 'White'});

fairCenters = cell(5,1);
unfairCenters = cell(5,1);

%%Loads in the raw data; generates another array that tracks if each data
%%point is male or female (svarALL); sets group names for the svars
for svar1 = 1:5
    [dataAll, svarAll, groupNames] = LoadData1MeanProcedure(datasetName, svar1);
    
    bestOutOf = 10;
    numIters = 10;
    numCenters = 3;
    
    %%creates a variable with the number of datapoints in the dataset
    numAllDataPts = size(dataAll, 1);
    %%generates a random permutation of the numbers from 1 to numAllDataPoints
    randPts = randperm(numAllDataPts);
    
    data = dataAll;
    svar = svarAll;
    
    % This function normalizes the data (mean 0 & variance 1) + does (fair) PCA
    % The second argument determines whether the PCA is fair or not
    datawoPCA = normalizeData(data);
    
    if strcmp(datasetName, 'LFW')
        dataN = projectData(datawoPCA, svar, 80, 0);
    else
        dataN = datawoPCA; %sets DATAN to the normalized data
    end
    
    %initializes 15 x 1 arrays
    dataP = cell(numCenters(end),1);
    dataPF = cell(numCenters(end),1);
    randCenters = cell(numCenters(end),1);
    randCentersPF = cell(numCenters(end),1);
    randCentersN = cell(numCenters(end),1);
    %initializes 15 x 1 arrays
    centers = cell(numCenters(end),1);
    clustering = cell(numCenters(end),1);
    runtime = cell(numCenters(end),1);
    centersF = cell(numCenters(end),1);
    clusteringF = cell(numCenters(end),1);
    runtimeF = cell(numCenters(end),1);
    centersFF = cell(numCenters(end),1);
    clusteringFF = cell(numCenters(end),1);
    runtimeFF = cell(numCenters(end),1);
    centersN = cell(numCenters(end),1);
    clusteringN = cell(numCenters(end),1);
    runtimeN = cell(numCenters(end),1);
    centersNF = cell(numCenters(end),1);
    clusteringNF = cell(numCenters(end),1);
    runtimeNF = cell(numCenters(end),1);
    centersPFL = cell(numCenters(end),1);
    clusteringPFL = cell(numCenters(end),1);
    runtimePFL = cell(numCenters(end),1);
    %initializes 15 x 1 arrays
    Cost = cell(numCenters(end),1);
    CostP = cell(numCenters(end),1);
    CostF = cell(numCenters(end),1);
    CostPF = cell(numCenters(end),1);
    CostFF = cell(numCenters(end),1);
    CostPFF = cell(numCenters(end),1);
    CostN = cell(numCenters(end),1);
    CostNF = cell(numCenters(end),1);
    CostPFL = cell(numCenters(end),1);
    CostPPFL = cell(numCenters(end),1);
    
    %ADDED BY PRIYANSHU ALLURI
    uniqueValues = unique(svar); % Get unique values present in svar
    numGroups = numel(uniqueValues); % Get the number of groups
    
    dataSubsets = cell(1, numGroups); % Initialize cell array to store subsets of data
    for i = 1:numGroups
        % Create subset of data corresponding to each unique value in svar
        dataSubsets{i} = datawoPCA(svar == uniqueValues(i), :);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %loops through the number of centers, starting at 4 and ending at 15
    for k=numCenters
        disp(k);
        numFeatures = k; %takes K features
    
        %Sets the kth element of the dataP and dataPF arrays with the outputs
        %of projectData; PF indicates fair and P indicates not fair
        %Scales the data by the PCA factor and stores in DataP or DataPF
        dataP{k} = projectData(datawoPCA, svar, numFeatures, 0);
        dataPF{k} = projectData(datawoPCA, svar, numFeatures, 1);
    
        [randCenters{k}, randCentersPF{k}, randCentersN{k}] = giveRandCenters(dataP{k}, dataPF{k}, dataN, k, bestOutOf);
        
    
        %clustering is the indices of which cluster each data point belongs to,
        %and centers are the cluster centers
        %This is calculated 6 times: data with PCA modification; data with Fair
        %PCA modification; and data with no modification. Run for both fair and
        %unfair clustering methods for a total of 6
    
        %data with normal pca
        [centers{k}, clustering{k}, runtime{k}] =...
            lloyd(dataP{k}, svar, k, numIters, bestOutOf, randCenters{k}, 0);
        
        [centersF{k}, clusteringF{k}, runtimeF{k}] =...
            lloyd(dataP{k}, svar, k, numIters, bestOutOf, randCenters{k}, 1);
        
        %data with fair pca
        [centersFF{k}, clusteringFF{k}, runtimeFF{k}] =...
            lloyd(dataPF{k}, svar, k, numIters, bestOutOf, randCentersPF{k}, 1);
        
        [centersPFL{k}, clusteringPFL{k}, runtimePFL{k}] =...
            lloyd(dataPF{k}, svar, k, numIters, bestOutOf, randCentersPF{k}, 0);
        
        %data with no PCA
        [centersN{k}, clusteringN{k}, runtimeN{k}] =...
            lloyd(dataN, svar, k, numIters, bestOutOf, randCentersN{k}, 0);
        
        [centersNF{k}, clusteringNF{k}, runtimeNF{k}] =...
            lloyd(dataN, svar, k, numIters, bestOutOf, randCentersN{k}, 1);
    
    
        %This cost is calculated 6 times
    
        %caclualtes cost for clustering done with normal PCA with no fairness
        %metric
        Cost{k} = compCost(datawoPCA, svar, k, clustering{k}, 0);
    
        %clusteringF{K} is the clustering gotten using dataset that underwent
        %PCA and then clustered with fairness
        %computes cost from clusteringF{K}
        CostF{k} = compCost({datawoPCA(svar==1,:), datawoPCA(svar==2,:)}, ...
            svar, k, clusteringF{k}, 1);
    
        %clusteringFF{K} is the clustering gotten using a dataset that
        %underwent FAIR PCA and then clustered with fairness
        %computes cost of ClusteringFF{K}
        CostFF{k} = compCost({datawoPCA(svar==1,:), datawoPCA(svar==2,:)}, ...
            svar, k, clusteringFF{k}, 1);
        
        %clusteringN{K} is the clustering gotten using a dataset that
        %underwent NO PCA and then clustered with NO fairness
        CostN{k} = compCost(datawoPCA, svar, k, clusteringN{k}, 0);
    
        %clusteringNF{K} is the clustering gotten using a dataset that
        %underwent NO PCA and then clustered WITH fairness
        CostNF{k} = compCost({datawoPCA(svar==1,:), datawoPCA(svar==2,:)}, ...
            svar, k, clusteringNF{k}, 1);
    
        %clusteringPFL{k} is the result of clustering a datset that underwent
        %FAIR PCA and was then clustered WITHOUT fairness
        %computes cost of clusteringPFL{k}
        CostPFL{k} = compCost(datawoPCA, svar, k, clusteringPFL{k}, 0);
        
    end
    % svar1_name = ethnicity_dict(svar1);
    % svar2_name = ethnicity_dict(svar2);
    % output_title = [datasetName, '_', svar1_name, 'vs', svar2_name];
    % save([output_title, '_4_26_2020']);
    fairCenters{svar1} = unnormalizeData(centersNF{3,1}, dataAll);
    unfairCenters{svar1} = unnormalizeData(centersN{3,1}, dataAll);
end


% Code adapted from "GeneratePanelPlotOfAllDatabyRace.m":
%Begin Visualization Process Below; 


data = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedData.csv");

svar = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedDataSVAR.csv");

datasep{1} = data(svar == 1, :);
datasep{2} = data(svar == 2, :);
datasep{3} = data(svar == 3, :);
datasep{4} = data(svar == 4, :);
datasep{5} = data(svar == 5, :);



ethnicity_dict = containers.Map({1, 2, 3, 4, 5}, {'Black', 'Other', 'Asian', 'Hispanic', 'White'});

viridis_color_scheme =[[253 231 37]; [68, 1, 84] ; [33, 145, 140]; [59, 82, 139]; [94 201, 98]; [255, 0, 0]; [0 0 255]];
viridis_transparencies = [1.5, 1.5, 1.5, 1.5, 0.8];
viridis_color_scheme(:,:) = viridis_color_scheme/255;
markerType = ['s', 'd', 'p', 'h', '^'];

colors = [
    0 0.4470 0.7410;
    0.8500 0.3250 0.0980;...
    0.9290 0.6940 0.1250;...
    0.4940 0.1840 0.5560;...
    0.4660 0.6740 0.1880;...
    0.3010 0.7450 0.9330;...
    0.6350 0.0780 0.1840...
];

S = 8;
S_ctr = 25;




% Create a new figure
figure;

% Define the positions for the subplots
pos1 = [0.25, 0.55, 0.2, 0.4]; % Top-left plot
pos2 = [0.55, 0.55, 0.2, 0.4]; % Top-right plot
pos3 = [0.1, 0.05, 0.2, 0.4];  % Bottom-left plot
pos4 = [0.4, 0.05, 0.2, 0.4];  % Bottom-center plot
pos5 = [0.7, 0.05, 0.2, 0.4];  % Bottom-right plot



svar1 = 1;
% Create the top-left plot
subplot('Position', pos1);
h1 = scatter3(datasep{svar1}(:,1), datasep{svar1}(:,2), datasep{svar1}(:,3), S, colors(svar1,:), markerType(svar1), 'filled', ...
     'MarkerFaceAlpha', viridis_transparencies(svar1)/5, 'MarkerEdgeColor', 'none', 'DisplayName','Black');
hold on;
scatter3(fairCenters{1}(:,1),fairCenters{1}(:,2),fairCenters{1}(:,3),...
    1.3*S_ctr, colors(6,:), 'filled', 'MarkerFaceAlpha', 1.0, 'MarkerEdgeColor', 'k', 'LineWidth',1)


title('Black');
xlabel('Diener score');
ylabel('PHQ 9 score');
zlabel('GAD 7 score');


% Create the top-right plot
subplot('Position', pos2);
h2 = scatter3(datasep{2}(:,1), datasep{2}(:,2), datasep{2}(:,3),S,colors(2,:), markerType(2), 'filled', ...
     'MarkerFaceAlpha', viridis_transparencies(2)/3, 'MarkerEdgeColor', 'none', 'DisplayName','Other');
hold on;
scatter3(fairCenters{2}(:,1),fairCenters{2}(:,2),fairCenters{2}(:,3),...
    1.3*S_ctr, colors(6,:), 'filled', 'MarkerFaceAlpha', 1.0, 'MarkerEdgeColor', 'k', 'LineWidth',1)
title('Other');





% Create the bottom-left plot
subplot('Position', pos3);
h3 = scatter3(datasep{3}(:,1), datasep{3}(:,2), datasep{3}(:,3),S,colors(3,:), markerType(3), 'filled', ...
     'MarkerFaceAlpha', viridis_transparencies(3)/3, 'MarkerEdgeColor', 'none', 'DisplayName','Asian');
hold on;
scatter3(fairCenters{3}(:,1),fairCenters{3}(:,2),fairCenters{3}(:,3),...
    1.3*S_ctr, colors(6,:), 'filled', 'MarkerFaceAlpha', 1.0, 'MarkerEdgeColor', 'k', 'LineWidth',1)
title('Asian');
xlabel('Diener score');
ylabel('PHQ 9 score');
zlabel('GAD 7 score');


% Create the bottom-center plot
subplot('Position', pos4);
h4 = scatter3(datasep{4}(:,1), datasep{4}(:,2), datasep{4}(:,3),S,colors(4,:), markerType(4), 'filled', ...
     'MarkerFaceAlpha', viridis_transparencies(4)/3, 'MarkerEdgeColor', 'none', 'DisplayName','Hispanic');
hold on;
scatter3(fairCenters{4}(:,1),fairCenters{4}(:,2),fairCenters{4}(:,3),...
    1.3*S_ctr, colors(6,:), 'filled', 'MarkerFaceAlpha', 1.0, 'MarkerEdgeColor', 'k', 'LineWidth',1)
title('Hispanic');

% Create the bottom-right plot
subplot('Position', pos5);
h5 = scatter3(datasep{5}(:,1), datasep{5}(:,2), datasep{5}(:,3),S,colors(5,:), markerType(5), 'filled', ...
     'MarkerFaceAlpha', viridis_transparencies(5)/3, 'MarkerEdgeColor', 'none', 'DisplayName','White');
hold on;
h6 = scatter3(fairCenters{5}(:,1),fairCenters{5}(:,2),fairCenters{5}(:,3),...
    1.3*S_ctr, colors(6,:), 'filled', 'MarkerFaceAlpha', 1.0, 'MarkerEdgeColor', 'k', 'LineWidth',1,'DisplayName','Fair Centers');
title('White');


allHandles = [h1, h2, h3, h4, h5,h6];

% Create a single legend
%legend(allHandles, 'Location', 'northeastoutside');
legend(allHandles, 'Position', [0.75, 0.75, 0.2, 0.1], 'Orientation', 'vertical');