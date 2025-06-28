clear;
close all;

randomSeed=12345;
rng(randomSeed);

% Input of loadData is either 'credit', 'adult', or 'LFW'
% 'svar' is the sensitive variable
datasetName = 'HMS';

% Create a dictionary mapping input values to corresponding labels
ethnicity_dict = containers.Map({1, 2, 3, 4, 5}, {'Black', 'Other', 'Asian', 'Hispanic', 'White'});


OneMeanCenters = cell(5,1);
OneMeanCosts = cell(5,1);
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
        [idx, C] = kmeans(dataAll,1);
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
        OneMeanCenters{svar1} = C;
        %OneMeanCosts{svar1} = CostNF{3}(1);
        svar1_name = ethnicity_dict(svar1);

end
output_title = [datasetName, '_1MeanProcedure'];
save([output_title, '_5_12_2024']);
