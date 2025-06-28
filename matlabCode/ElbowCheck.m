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

maxK = 10;
sum_of_squares = zeros(maxK, 1);

ns = cell(1,5);
allFairCosts = cell(5,4);
allNonfairCosts = cell(5,4);
%%Loads in the raw data; generates another array that tracks if each data
%%point is male or female (svarALL); sets group names for the svars
for numCenters =1:maxK
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
        
        if strcmp(datasetName, 'LFW')
            dataN = projectData(datawoPCA, svar, 80, 0);
        else
            dataN = datawoPCA; %sets DATAN to the normalized data
        end
        
        %initializes 15 x 1 arrays
        dataP = cell(numCenters(end),1);
        dataPF = cell(numCenters(end),1);
        randCenters = cell(numCenters(end),1);

        randCentersN = cell(numCenters(end),1);
        %initializes 15 x 1 arrays
        centers = cell(numCenters(end),1);
        clustering = cell(numCenters(end),1);


        centersN = cell(numCenters(end),1);
        clusteringN = cell(numCenters(end),1);
        runtimeN = cell(numCenters(end),1);
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
        ns{svar1} = size(dataSubsets{1},1);
        ns{svar2} = size(dataSubsets{2},1);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %loops through the number of centers, starting at 4 and ending at 15
        for k=numCenters
            % if numCenters > 3
            %     k = 3;
            % end
            disp(k);
            numFeatures = 3; %takes K features

        
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
        
            [cluster_indices, cluster_centers, sumd] = kmeans(dataN, k);

            %data with no PCA
            [centersN{k}, clusteringN{k}, runtimeN{k}] =...
                lloyd(dataN, svar, k, numIters, bestOutOf, randCentersN{k}, 0);
            
            [centersNF{k}, clusteringNF{k}, runtimeNF{k}] =...
                lloyd(dataN, svar, k, numIters, bestOutOf, randCentersN{k}, 1);
        
        
            %This cost is calculated 6 times

            
            %clusteringN{K} is the clustering gotten using a dataset that
            %underwent NO PCA and then clustered with NO fairness
            CostN{k} = compCost(datawoPCA, svar, k, clusteringN{k}, 0);
        
            %clusteringNF{K} is the clustering gotten using a dataset that
            %underwent NO PCA and then clustered WITH fairness
            CostNF{k} = compCost({datawoPCA(svar==1,:), datawoPCA(svar==2,:)}, ...
                svar, k, clusteringNF{k}, 1);

            % silhouetteValues = silhouette(datawoPCA, clusteringN{k});
            % fairSilhouetteValues = silhouette(datawoPCA, updatedClustering);
            % 
            % silhouetteScores(numCenters) = mean(silhouetteValues);
            % fairSilhouetteScores(numCenters) = mean(fairSilhouetteValues);
        end

        totalNonFair_cost = 0;
        for i = 1:length(clusteringN{k})
            cluster_idx = clusteringN{k}(i);
            diff = dataN(i, :) - centersN{k}(cluster_idx, :);
            totalNonFair_cost = totalNonFair_cost + sum(diff.^2);
        end
        allNonfairCosts{svar1,svar2}{k,1} = totalNonFair_cost;
        % allNonfairCosts{svar1,svar2}{k,1} = CostN{k};


        
        % Concatenate the separated data matrices
        if k == 1
            updatedClustering = clusteringN{k};
        else
        C = clusteringNF{k,1};
        data_combined = [C{1}'; C{2}'];
        
        % Create an index vector to sort the combined data back to its original order
        index = [find(svar == 1); find(svar == 2)];
        
        % Sort the combined data based on the index
        [~, order] = sort(index);
        updatedClustering = data_combined(order, :);
        end

        totalFair_cost = 0;
        for i = 1:length(updatedClustering)
            cluster_idx = updatedClustering(i);
            diff = dataN(i, :) - centersNF{k}(cluster_idx, :);
            totalFair_cost = totalFair_cost + sum(diff.^2);
        end
        allFairCosts{svar1,svar2}{k,1} = totalFair_cost;
        %allFairCosts{svar1,svar2}{k,1} = CostNF{k};

       
    end
end
end

output_title = [datasetName, '_ElbowCheck'];
save([output_title, '_6_5_2020']);
