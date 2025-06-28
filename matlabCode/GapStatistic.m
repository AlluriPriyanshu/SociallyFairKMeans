clear;
close all;

randomSeed = 12345;
rng(randomSeed);

% Input of loadData is either 'credit', 'adult', or 'LFW'
% 'svar' is the sensitive variable
datasetName = 'HMS';

% Create a dictionary mapping input values to corresponding labels
ethnicity_dict = containers.Map({1, 2, 3, 4, 5}, {'Black', 'Other', 'Asian', 'Hispanic', 'White'});

fairCenters = cell(4, 5);
unfairCenters = cell(4, 5);

maxK = 10;
sum_of_squares = zeros(maxK, 1);
silhouetteScores = zeros(maxK, 1); % Array to store silhouette scores

allFairCosts = cell(5, 4);

B = 100; % Number of reference datasets
logWk = zeros(maxK, 1);
logWkb = zeros(maxK, B);

%% Loads in the raw data; generates another array that tracks if each data
%% point is male or female (svarALL); sets group names for the svars
for numCenters = 2:maxK
    for svar1 = 1:4
        for svar2 = svar1 + 1:5
            [dataAll, svarAll, groupNames] = loadData(datasetName, svar1, svar2);
            
            bestOutOf = 10;
            numIters = 10;
            
            %% Creates a variable with the number of datapoints in the dataset
            numAllDataPts = size(dataAll, 1);
            %% Generates a random permutation of the numbers from 1 to numAllDataPoints
            randPts = randperm(numAllDataPts);
            
            data = dataAll;
            svar = svarAll;
            
            % This function normalizes the data (mean 0 & variance 1) + does (fair) PCA
            % The second argument determines whether the PCA is fair or not
            datawoPCA = normalizeData(data);
            
            if strcmp(datasetName, 'LFW')
                dataN = projectData(datawoPCA, svar, 80, 0);
            else
                dataN = datawoPCA; % Sets DATAN to the normalized data
            end
            
            % Initializes 15 x 1 arrays
            dataP = cell(numCenters, 1);
            dataPF = cell(numCenters, 1);
            randCenters = cell(numCenters, 1);
            randCentersPF = cell(numCenters, 1);
            randCentersN = cell(numCenters, 1);
            % Initializes 15 x 1 arrays
            centers = cell(numCenters, 1);
            clustering = cell(numCenters, 1);
            runtime = cell(numCenters, 1);
            centersF = cell(numCenters, 1);
            clusteringF = cell(numCenters, 1);
            runtimeF = cell(numCenters, 1);
            centersFF = cell(numCenters, 1);
            clusteringFF = cell(numCenters, 1);
            runtimeFF = cell(numCenters, 1);
            centersN = cell(numCenters, 1);
            clusteringN = cell(numCenters, 1);
            runtimeN = cell(numCenters, 1);
            centersNF = cell(numCenters, 1);
            clusteringNF = cell(numCenters, 1);
            runtimeNF = cell(numCenters, 1);
            centersPFL = cell(numCenters, 1);
            clusteringPFL = cell(numCenters, 1);
            runtimePFL = cell(numCenters, 1);
            % Initializes 15 x 1 arrays
            Cost = cell(numCenters, 1);
            CostP = cell(numCenters, 1);
            CostF = cell(numCenters, 1);
            CostPF = cell(numCenters, 1);
            CostFF = cell(numCenters, 1);
            CostPFF = cell(numCenters, 1);
            CostN = cell(numCenters, 1);
            CostNF = cell(numCenters, 1);
            CostPFL = cell(numCenters, 1);
            CostPPFL = cell(numCenters, 1);
            
            % ADDED BY PRIYANSHU ALLURI
            uniqueValues = unique(svar); % Get unique values present in svar
            numGroups = numel(uniqueValues); % Get the number of groups
            
            dataSubsets = cell(1, numGroups); % Initialize cell array to store subsets of data
            for i = 1:numGroups
                % Create subset of data corresponding to each unique value in svar
                dataSubsets{i} = datawoPCA(svar == uniqueValues(i), :);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Loops through the number of centers, starting at 2 and ending at 10
            for k = 2:maxK
                disp(k);
                numFeatures = 3; % Takes K features

                % Sets the kth element of the dataP and dataPF arrays with the outputs
                % of projectData; PF indicates fair and P indicates not fair
                % Scales the data by the PCA factor and stores in DataP or DataPF
                dataP{k} = projectData(datawoPCA, svar, numFeatures, 0);
                dataPF{k} = projectData(datawoPCA, svar, numFeatures, 1);

                [randCenters{k}, randCentersPF{k}, randCentersN{k}] = giveRandCenters(dataP{k}, dataPF{k}, dataN, k, bestOutOf);

                % Perform clustering for the different scenarios
                [centers{k}, clustering{k}, runtime{k}] = lloyd(dataP{k}, svar, k, numIters, bestOutOf, randCenters{k}, 0);
                [centersF{k}, clusteringF{k}, runtimeF{k}] = lloyd(dataP{k}, svar, k, numIters, bestOutOf, randCenters{k}, 1);
                [centersFF{k}, clusteringFF{k}, runtimeFF{k}] = lloyd(dataPF{k}, svar, k, numIters, bestOutOf, randCentersPF{k}, 1);
                [centersPFL{k}, clusteringPFL{k}, runtimePFL{k}] = lloyd(dataPF{k}, svar, k, numIters, bestOutOf, randCentersPF{k}, 0);
                [centersN{k}, clusteringN{k}, runtimeN{k}] = lloyd(dataN, svar, k, numIters, bestOutOf, randCentersN{k}, 0);
                [centersNF{k}, clusteringNF{k}, runtimeNF{k}] = lloyd(dataN, svar, k, numIters, bestOutOf, randCentersN{k}, 1);

                % Calculate costs for the different clustering results
                Cost{k} = sum(compCost(datawoPCA, svar, k, clustering{k}, 0)); % Ensure Cost{k} is scalar
                CostF{k} = sum(compCost({datawoPCA(svar==1,:), datawoPCA(svar==2,:)}, svar, k, clusteringF{k}, 1));
                CostFF{k} = sum(compCost({datawoPCA(svar==1,:), datawoPCA(svar==2,:)}, svar, k, clusteringFF{k}, 1));
                CostN{k} = sum(compCost(datawoPCA, svar, k, clusteringN{k}, 0));
                CostNF{k} = sum(compCost({datawoPCA(svar==1,:), datawoPCA(svar==2,:)}, svar, k, clusteringNF{k}, 1));
                CostPFL{k} = sum(compCost(datawoPCA, svar, k, clusteringPFL{k}, 0));

                % Calculate silhouette scores
                silhouetteValues = silhouette(datawoPCA, clustering{k});
                silhouetteScores(k) = mean(silhouetteValues);
                
                % Calculate within-cluster sum of squares
                logWk(k) = log(Cost{k});

                % Generate reference datasets and calculate within-cluster sum of squares
                for b = 1:B
                    referenceData = generateReferenceData(datawoPCA);
                    [~, refClustering] = lloyd(referenceData, svar, k, numIters, bestOutOf, randCenters{k}, 0);
                    logWkb(k, b) = log(sum(compCost(referenceData, svar, k, refClustering, 0)));
                end

            end

            allFairCosts{svar1,svar2}{k,1} = CostNF{k};
        end
    end
end

% Calculate Gap Statistic
gapStatistic = mean(logWkb, 2) - logWk;
sk = sqrt((1 + 1/B) * var(logWkb, 0, 2));
gapStatisticWithSk = gapStatistic - sk;

% Plot the Gap Statistic
figure;
errorbar(2:maxK, gapStatistic(2:maxK), sk(2:maxK), '-o');
xlabel('Number of Clusters (k)');
ylabel('Gap Statistic');
title('Gap Statistic for Different k Values');
grid on;

% Find the optimal k using the Gap Statistic
[~, optimalKIndex] = max(gapStatisticWithSk(2:maxK));
optimalK = optimalKIndex + 1; % since the index starts at 2

disp(['The optimal number of clusters is: ', num2str(optimalK)]);

output_title = [datasetName, '_ElbowCheck'];
save([output_title, '_6_5_2020']);

% Function to generate reference data
function referenceData = generateReferenceData(data)
    minVals = min(data);
    maxVals = max(data);
    referenceData = bsxfun(@plus, bsxfun(@times, rand(size(data)), (maxVals - minVals)), minVals);
end
