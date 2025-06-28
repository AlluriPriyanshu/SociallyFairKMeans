clear;
close all;

load("fairCenters.mat")
load("unfairCenters.mat")
load("storedVarsFair.mat")
load("storedVarsNonfair.mat")

toSave = storedVarsFair;
minMaxStoredVarsFair = cell(4,5);
D1D9StoredVarsFair = cell(4,5);

minMaxStoredVarsNonfair = cell(4,5);
D1D9StoredVarsNonfair = cell(4,5);

numFeatures = size(storedVarsFair{1,2},2);
numClusters = 3;
k = 3;
startingFeature = 5;
numCenters = 3;

storedVarsTempFair = storedVarsFair;
storedVarsTempNonfair = storedVarsNonfair;
for svar1 =1:4
    for svar2=svar1+1:5

        %stores the centerIndices in order to give: Flourishing, Getting By, and Struggling (in that order)
        centerLabelsFair = [];
        centerLabelsNonfair = [];
        

        placeholderFair = sort(fairCenters{svar1,svar2}(:,1),'descend');
        placeholderNonfair = sort(unfairCenters{svar1,svar2}(:,1),'descend');
        for plcIdx = 1:k
            for center = 1:k
                if placeholderFair(plcIdx) == fairCenters{svar1,svar2}(center,1)
                    centerLabelsFair(plcIdx) = center;
                end
                if placeholderNonfair(plcIdx) == unfairCenters{svar1,svar2}(center,1)
                    centerLabelsNonfair(plcIdx) = center;
                end
            end
        end
        
        storedVarsTempFair{svar1,svar2} = storedVarsFair{svar1,svar2}(centerLabelsFair,:);
        storedVarsTempNonfair{svar1,svar2} = storedVarsTempNonfair{svar1,svar2}(centerLabelsFair,:);

        storedVarsFair = storedVarsTempFair;
        storedVarsNonfair = storedVarsTempNonfair;
        
        minMaxStoredVarsFair{svar1,svar2} = cell(numClusters, numFeatures);
        D1D9StoredVarsFair{svar1,svar2} = cell(numClusters, numFeatures);

        minMaxStoredVarsNonfair{svar1,svar2} = cell(numClusters, numFeatures);
        D1D9StoredVarsNonfair{svar1,svar2} = cell(numClusters, numFeatures);

        for featureNum=startingFeature:numFeatures
            for clusterNum =1:numClusters
                tempMinFair = min(storedVarsFair{svar1,svar2}{clusterNum,featureNum});
                tempMaxFair = max(storedVarsFair{svar1,svar2}{clusterNum,featureNum});
                DFair = quantile(storedVarsFair{svar1,svar2}{clusterNum,featureNum},100);
                D1Fair = DFair(20);
                D9Fair = DFair(80);

                % fairMean = mean(storedVarsFair{svar1,svar2}{clusterNum,featureNum});
                % fairSTD = std(storedVarsFair{svar1,svar2}{clusterNum,featureNum});
                % STD_plusOne_fair = fairMean + 4*fairSTD;
                % STD_minusOne_fair = fairMean - 4*fairSTD;


                minMaxStoredVarsFair{svar1,svar2}{clusterNum,featureNum} = [tempMinFair,tempMaxFair];
                D1D9StoredVarsFair{svar1,svar2}{clusterNum,featureNum} = [D1Fair,D9Fair];
                %D1D9StoredVarsFair{svar1,svar2}{clusterNum,featureNum} = [STD_minusOne_fair,STD_plusOne_fair];
                %STDStoredVarsFair{svar1,svar2}{clusterNum,featureNum} = [STD_minusOne_fair,STD_plusOne_fair];


                tempMinNonfair = min(storedVarsNonfair{svar1,svar2}{clusterNum,featureNum});
                tempMaxNonfair = max(storedVarsNonfair{svar1,svar2}{clusterNum,featureNum});
                DNonfair = quantile(storedVarsNonfair{svar1,svar2}{clusterNum,featureNum},100);
                D1Nonfair = DNonfair(5);
                D9Nonfair = DNonfair(95);

                nonfairMean = mean(storedVarsNonfair{svar1,svar2}{clusterNum,featureNum});
                % nonfairSTD = std(storedVarsNonfair{svar1,svar2}{clusterNum,featureNum});
                % STD_plusOne_nonfair = nonfairMean + 4*nonfairSTD;
                % STD_minusOne_nonfair = nonfairMean - 4*nonfairSTD;
                
                minMaxStoredVarsNonfair{svar1,svar2}{clusterNum,featureNum} = [tempMinNonfair,tempMaxNonfair];
                D1D9StoredVarsNonfair{svar1,svar2}{clusterNum,featureNum} = [D1Nonfair,D9Nonfair];
                % STDStoredVarsNonfair{svar1,svar2}{clusterNum,featureNum} = [STD_minusOne_nonfair,STD_plusOne_nonfair];

            end
        end
    end
end


save(['analyzeVarProp', '_7_5_2024']);
