clear;
close all;

load("fairCenters.mat")
load("unfairCenters.mat")
load("storedVarsFair.mat")

toSave = storedVarsFair;
minMaxStoredVarsFair = cell(4,5);
D1D9StoredVarsFair = cell(4,5);
binaryProportions = cell(4,5);
binaryProportionsConcat = cell(4,5);


numFeatures = size(storedVarsFair{1,2},2);
numClusters = 3;
k = 3;
startingFeature = 5;
numCenters = 3;

atRiskNum = 3;
flourishingNum = 1;
gettingByNum = 2;
storedVarsTempFair = storedVarsFair;


myDict = containers.Map('KeyType', 'double', 'ValueType', 'any');

% Add key-value pairs
myDict(5) = [1,2,3];
myDict(6) = [1,2,3];
myDict(11) = [1,2];
myDict(13) = [1];
myDict(14) = [1,2,3];
myDict(15) = [1];
myDict(16) = [1];
myDict(17) = [1,2,3];

for svar1 =1:4
    for svar2=svar1+1:5

        %stores the centerIndices in order to give: Flourishing, Getting By, and Struggling (in that order)
        centerLabelsFair = [];

        

        placeholderFair = sort(fairCenters{svar1,svar2}(:,1),'descend');

        for plcIdx = 1:k
            for center = 1:k
                if placeholderFair(plcIdx) == fairCenters{svar1,svar2}(center,1)
                    centerLabelsFair(plcIdx) = center;
                end
            end
        end
        
        storedVarsTempFair{svar1,svar2} = storedVarsFair{svar1,svar2}(centerLabelsFair,:);

        storedVarsFair = storedVarsTempFair;
        
        minMaxStoredVarsFair{svar1,svar2} = cell(numClusters, numFeatures);
        D1D9StoredVarsFair{svar1,svar2} = cell(numClusters, numFeatures);
        binaryProportions{svar1,svar2} = cell(numClusters, numFeatures);
        binaryProportionsConcat{svar1,svar2} = cell(numClusters, numFeatures);

        for featureNum=startingFeature:numFeatures
                
            valueArray_AR = storedVarsFair{svar1,svar2}{atRiskNum,featureNum};
            [countsAR, valuesAR] = groupcounts(valueArray_AR');

            valueArray_FL = storedVarsFair{svar1,svar2}{flourishingNum,featureNum};
            [countsFL, valuesFL] = groupcounts(valueArray_FL');

            if length(valuesAR) > 2
                trueVals = myDict(featureNum);
                
                totalTrue = countsAR(trueVals) + countsFL(trueVals);
                propTrueAR = countsAR(trueVals)/totalTrue;
                propTrueFL = countsFL(trueVals)/totalTrue;
                binaryProportions{svar1,svar2}{atRiskNum, featureNum} = propTrueAR;
                binaryProportions{svar1,svar2}{flourishingNum, featureNum} = propTrueFL;
                continue;
            end



            
            totalTrue = countsAR(2) + countsFL(2);
            propTrueAR = countsAR(2)/totalTrue;
            propTrueFL = countsFL(2)/totalTrue;
            binaryProportions{svar1,svar2}{atRiskNum, featureNum} = propTrueAR;
            binaryProportions{svar1,svar2}{flourishingNum, featureNum} = propTrueFL;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %this is for the concatenated getting By and flourishing

            valueArray_GB = storedVarsFair{svar1,svar2}{gettingByNum,featureNum};
            [countsGB, valuesGB] = groupcounts(valueArray_GB');

            totalTrueConcat = countsAR(2) + countsFL(2) + countsGB(2);
            propTrueFL = (countsFL(2) + countsGB(2))/totalTrueConcat;
            propTrueAR = countsAR(2)/totalTrueConcat;

            binaryProportionsConcat{svar1,svar2}{atRiskNum, featureNum} = propTrueAR;
            binaryProportionsConcat{svar1,svar2}{gettingByNum, featureNum} = propTrueFL;
       end
    end
end


save(['analyzeVarPropForProportions', '_7_5_2024']);
