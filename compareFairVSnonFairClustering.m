clear;
close all;

randomSeed=12345;
rng(randomSeed);

% Input of loadData is either 'credit', 'adult', or 'LFW'
% 'svar' is the sensitive variable
datasetName = 'HMS';

% Create a dictionary mapping input values to corresponding labels
ethnicity_dict = containers.Map({1, 2, 3, 4, 5}, {'Black', 'Other', 'Asian', 'Hispanic', 'White'});


fairCenters = cell(4,5);
unfairCenters = cell(4,5);
numCenters = 3;

allFairCosts = cell(5,4);
dataDiff = cell(5,4);
%%Loads in the raw data; generates another array that tracks if each data
%%point is male or female (svarALL); sets group names for the svars
k =3;
for svar1 = 1:4
    for svar2 = svar1+1:5
        [dataAll, svarAll, groupNames] = loadData(datasetName, svar1, svar2);
        
        bestOutOf = 10;
        numIters = 10;
        
        %%creates a variable with the number of datapoints in the dataset
        numAllDataPts = size(dataAll, 1);
        %%generates a random permutation of the numbers from 1 to numAllDataPoints
        randPts = randperm(numAllDataPts);
        
        data = dataAll;
        svar = svarAll;
        
        % This function normalizes the data (mean 0 & variance 1) + does (fair) PCA
        % The second argument determines whether the PCA is fair or not
        datawoPCA = normalizeData(data);
        

        dataN = datawoPCA; %sets DATAN to the normalized data

        
        %initializes 15 x 1 arrays
        
        dataPF = cell(numCenters(end),1);
        randCenters = cell(numCenters(end),1);

        randCentersN = cell(numCenters(end),1);
        %initializes 15 x 1 arrays
        centers = cell(numCenters(end),1);
        clustering = cell(numCenters(end),1);
        centersN = cell(numCenters(end),1);
        clusteringN = cell(numCenters(end),1);
        centersNF = cell(numCenters(end),1);
        clusteringNF = cell(numCenters(end),1);
        %initializes 15 x 1 arrays
        Cost = cell(numCenters(end),1);
        CostN = cell(numCenters(end),1);
        CostNF = cell(numCenters(end),1);
        
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
        for k = numCenters
            disp(k);
            numFeatures = 3; %takes K features

            %Sets the kth element of the dataP and dataPF arrays with the outputs
            %of projectData; PF indicates fair and P indicates not fair
            %Scales the data by the PCA factor and stores in DataP or DataPF
            dataP{k} = projectData(datawoPCA, svar, numFeatures, 0);
            dataPF{k} = projectData(datawoPCA, svar, numFeatures, 1);

            [randCenters{k}, randCentersPF{k}, randCentersN{k}] = giveRandCenters(dataP{k}, dataPF{k}, dataN, k, bestOutOf);

            % Perform clustering for the different scenarios
            [centersN{k}, clusteringN{k}, runtimeN{k}] = lloyd(dataN, svar, k, numIters, bestOutOf, randCentersN{k}, 0);
            [centersNF{k}, clusteringNF{k}, runtimeNF{k}] = lloyd(dataN, svar, k, numIters, bestOutOf, randCentersN{k}, 1);

            % Calculate costs for the different clustering results
            CostN{k} = compCost(datawoPCA, svar, k, clusteringN{k}, 0);
            CostNF{k} = compCost({datawoPCA(svar==1,:), datawoPCA(svar==2,:)}, svar, k, clusteringNF{k}, 1);

            
            % Concatenate the separated data matrices
            C = clusteringNF{k,1};
            data_combined = [C{1}'; C{2}'];
            
            % Create an index vector to sort the combined data back to its original order
            index = [find(svar == 1); find(svar == 2)];
            
            % Sort the combined data based on the index
            [~, order] = sort(index);
            updatedClustering = data_combined(order, :);
            updatedClustering = updatedClustering';

            if isequal(size(updatedClustering), size(clusteringN{k}))
                % Find the indices where they differ
                diffIndices = find(updatedClustering ~= clusteringN{k});
                
                % Display or store these indices
                disp('Indices where updatedClustering and clusteringN differ:');
                disp(diffIndices);
            else
                error('updatedClustering and clusteringN{k} must be of the same size.');
            end
            
            dataDiff{svar1,svar2} = data(diffIndices,:);
        end
    end
end

save('dataDiff','dataDiff') %will be analyzed in AnalyzeDataDiff.m




