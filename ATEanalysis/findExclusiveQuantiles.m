clear
close all;

load(['analyzeVarProp', '_7_5_2024']);

load('variableNames.mat')

allAppendedVars_fair = strings(0, 1);
allAppendedVars_Nonfair = strings(0,1);
% allAppendedVars_fair_STD = strings(0, 1);

FairNoOverlap = cell(4,5);
NonfairNoOverlap = cell(4,5);
%assumes the deciles are sorted with both flourishing clusters 
%in the first two rows (for Fair Kmeans)

for svar1 =1:4
    for svar2=svar1 + 1
        TempFairvarsNoOverlap = strings(0, 1);
        TempNonfairvarsNoOverlap = strings(0, 1);
        TempFairvarsNoOverlap_STD = strings(0, 1);
        for feature= startingFeature:numFeatures

                  
            flourishingMin_fair = min(D1D9StoredVarsFair{svar1,svar2}{1,feature});
            flourishingMax_fair = max(D1D9StoredVarsFair{svar1,svar2}{1,feature});
            
            tempMin_fair = min(D1D9StoredVarsFair{svar1,svar2}{2,feature});
            tempMax_fair = max(D1D9StoredVarsFair{svar1,svar2}{2,feature});


            
            FL = [flourishingMin_fair,flourishingMax_fair];
            AR = cell2mat(D1D9StoredVarsFair{svar1,svar2}(3,feature));
            isDistinctDecile_fair = checkListOverlap(FL,AR);
            
            
            if isDistinctDecile_fair
                TempFairvarsNoOverlap(end + 1) = variableNames(feature);
                allAppendedVars_fair(end + 1) = variableNames(feature);
            end

            %repeat for NonFair
            flourishingMin_Nonfair = min(D1D9StoredVarsNonfair{svar1,svar2}{1,feature});
            flourishingMax_Nonfair = max(D1D9StoredVarsNonfair{svar1,svar2}{1,feature});
            
            tempMin_Nonfair = min(D1D9StoredVarsNonfair{svar1,svar2}{2,feature});
            tempMax_Nonfair = max(D1D9StoredVarsNonfair{svar1,svar2}{2,feature});

            if flourishingMin_Nonfair > tempMin_Nonfair
                flourishingMin_Nonfair = tempMin_Nonfair;
            end
            if flourishingMax_Nonfair < tempMax_Nonfair
                flourishingMax_Nonfair = tempMax_Nonfair;
            end
            
            FL = [flourishingMin_Nonfair,flourishingMax_Nonfair];
            AR = cell2mat(D1D9StoredVarsNonfair{svar1,svar2}(3,feature));
            isDistinctDecile_Nonfair = checkListOverlap(FL,AR);
            
            
            if isDistinctDecile_Nonfair

                TempNonfairvarsNoOverlap(end + 1) = variableNames(feature);
                allAppendedVars_Nonfair(end + 1) = variableNames(feature);
            end

            % %repeat for STD:
            % minusSTD_fair = min(STDStoredVarsFair{svar1,svar2}{1,feature});
            % plusSTD_fair = max(STDStoredVarsFair{svar1,svar2}{1,feature});

            % tempMinSTD_fair = min(STDStoredVarsFair{svar1,svar2}{2,feature});
            % tempMaxSTD_fair = max(STDStoredVarsFair{svar1,svar2}{2,feature});
            % 
            % if minusSTD_fair > tempMinSTD_fair
            %     minusSTD_fair = tempMinSTD_fair;
            % end
            % if plusSTD_fair < tempMaxSTD_fair
            %     plusSTD_fair = tempMaxSTD_fair;
            % end
            
            % FL = [minusSTD_fair,plusSTD_fair];
            % AR = cell2mat(STDStoredVarsFair{svar1,svar2}(3,feature));
            % isDistinctSTD_fair = checkListOverlap(FL,AR);
            % 
            % 
            % if isDistinctSTD_fair
            %     TempFairvarsNoOverlap_STD(end + 1) = variableNames(feature);
            %     allAppendedVars_fair_STD(end + 1) = variableNames(feature);
            % end

        end
        FairNoOverlap{svar1,svar2} = TempFairvarsNoOverlap;
        NonfairNoOverlap{svar1,svar2} = TempNonfairvarsNoOverlap;
    end
end

uniqueVars_Fair = unique(allAppendedVars_fair);
uniqueVars_Nonfair = unique(allAppendedVars_Nonfair);
% uniqueVars_FairSTD = unique(allAppendedVars_fair_STD);




% Open the file for writing
fileID = fopen('uniqueVars_fair.txt', 'w');

% Write each element of the array to the file, each on a new line
for i = 1:length(uniqueVars_Fair)
    fprintf(fileID, '%s\n', uniqueVars_Fair(i));
end

% Close the file
fclose(fileID);

fileID = fopen('uniqueVars_Nonfair.txt', 'w');

% Write each element of the array to the file, each on a new line
for i = 1:length(uniqueVars_Nonfair)
    fprintf(fileID, '%s\n', uniqueVars_Nonfair(i));
end

% Close the file
fclose(fileID);

% fileID = fopen('uniqueVars_fairSTD.txt', 'w');
% 
% % Write each element of the array to the file, each on a new line
% for i = 1:length(uniqueVars_FairSTD)
%     fprintf(fileID, '%s\n', uniqueVars_FairSTD(i));
% end
% 
% % Close the file
% fclose(fileID);

function isDistinctDecile = checkListOverlap(FL, AR)
    isDistinctDecile = false;
    if FL(1) > AR(1)
        if FL(1) >= AR(2)
            isDistinctDecile = true;
        end
    
    
    elseif FL(1) < AR(1)
        if FL(2) <= AR(1)
            isDistinctDecile = true;
        end
    end  
end
