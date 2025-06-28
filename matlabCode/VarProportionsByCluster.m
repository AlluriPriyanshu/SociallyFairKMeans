clear;
close all;

randomSeed=12345;
rng(randomSeed);

% Input of loadData is either 'credit', 'adult', or 'LFW'
% 'svar' is the sensitive variable


% Create a dictionary mapping input values to corresponding labels
ethnicity_dict = containers.Map({1, 2, 3, 4, 5}, {'Black', 'Other', 'Asian', 'Hispanic', 'White'});

fairCenters = cell(4,5);
unfairCenters = cell(4,5);
fairCosts = cell(4,5);
unfairCosts = cell(4,5);

varProportions = cell(5,5);
storedVarsFair = cell(4,5);
storedVarsNonfair = cell(4,5);


%%Loads in the raw data; generates another array that tracks if each data
%%point is male or female (svarALL); sets group names for the svars
for svar1 = 1:4
    for svar2 = svar1+1:5
        datasetName = 'HMS';
        [dataAll, svarAll, groupNames, varOfInt] = LoadDataVariableProportions(datasetName, svar1, svar2);
        
        bestOutOf = 10;
        numIters = 10;
        numCenters = 3;
        
        %%creates a variable with the number of datapoints in the dataset
        numAllDataPts = size(dataAll, 1);
        %%generates a random permutation of the numbers from 1 to numAllDataPoints
        randPts = randperm(numAllDataPts);
        
        data = dataAll;
        svar = svarAll;
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
        %centers = cell(numCenters(end),1);
        % clustering = cell(numCenters(end),1);
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
            
            
            %data with no PCA
            [centersN{k}, clusteringN{k}, runtimeN{k}] =...
                lloyd(dataN, svar, k, numIters, bestOutOf, randCentersN{k}, 0);
            
            [centersNF{k}, clusteringNF{k}, runtimeNF{k}] =...
                lloyd(dataN, svar, k, numIters, bestOutOf, randCentersN{k}, 1);
        
            
        end
        C = clusteringNF{k,1};
        data_combined = [C{1}'; C{2}'];
        
        index = [find(svar == 1); find(svar == 2)];
        
        [~, order] = sort(index);
        updatedClustering = data_combined(order, :);
        updatedClustering = updatedClustering';
        
        numVars = size(varOfInt,2);
        varProportions{svar1,svar2} = [data, clusteringN{k}', updatedClustering'];
        storedVarsFair{svar1,svar2} = cell(numCenters,numVars);
        storedVarsNonfair{svar1,svar2} = cell(numCenters,numVars);

        for varCol =5:numVars
            for row = 1:size(data,1)
                
                %for each datapoint:
                %finds what the fairClustering for that data point was
                clusNum_fair = varProportions{svar1,svar2}(row,6);
                clusNum_Nonfair = varProportions{svar1,svar2}(row,5);
                %determines the value associated with the variable of interest for that data point 
                varValue = varOfInt(row, varCol);
                %stores that value in an array corresponding to the cluster.
                if varValue ~= 29845
                    storedVarsFair{svar1,svar2}{clusNum_fair, varCol}(end+1) = varValue;
                    storedVarsNonfair{svar1,svar2}{clusNum_Nonfair, varCol}(end+1) = varValue;
                end
            end

        end
        
        datasetName = 'HMS';
        svar1_name = ethnicity_dict(svar1);
        svar2_name = ethnicity_dict(svar2);
        datasetName = [datasetName, '_', svar1_name, 'vs', svar2_name];
        dateString = '_5_14_2024';
        filename = [datasetName, dateString];
        save(filename);
        
        unfairCosts{svar1,svar2} = CostN{numCenters,1};
        fairCosts{svar1,svar2} = CostNF{numCenters,1};
        fairCenters{svar1,svar2} = unnormalizeData(centersNF{numCenters,1}, dataAll);
        unfairCenters{svar1,svar2} = unnormalizeData(centersN{numCenters,1}, dataAll);
    end
end
save('fairCenters', 'fairCenters')
save('unfairCenters', 'unfairCenters')
save('storedVarsFair','storedVarsFair')
save('storedVarsNonfair','storedVarsNonfair')
datasetName = 'HMS';
output_title = [datasetName, '_SociallyFairImplementation'];
save([output_title, '_5_14_2024']);