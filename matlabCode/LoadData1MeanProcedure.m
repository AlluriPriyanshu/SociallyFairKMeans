function [dataAll, svarAll, groupNames] = LoadData1MeanProcedure(datasetName, svar1)

    if strcmp(datasetName, 'credit')
        dataAll = csvread('../Data/credit/credit_degree.csv', 2, 1);
        svarTemp = csvread('../Data/credit/educationAttribute.csv');
        svarAll = preProcessEductaionVector(svarTemp)';
        groupNames = {'Higher Education'; 'Lower Education'};
    elseif strcmp(datasetName, 'adult')
        %Commented out for testing 
        %dataAll = csvread('../Data/adult/adult_data_set.csv'); 
        %dataAll = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/adult/NormalizedAdult.csv")
        dataAll = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/adult/NormalizedAdult.csv")
        %svarAll = csvread('../Data/adult/adult_data_set_prot_attributes.csv');
        svarAll = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/adult/adultDatasetTestingSVAR.csv");
        %svarAll = svarAll + 1;
        groupNames = {'Female'; 'Male'};
    elseif strcmp(datasetName, 'LFW')
        load('../Data/LFW/LFW.mat', 'data', 'sensitive');
        dataAll = data;
        svarAll = sensitive;
        clear data sensitive;
        groupNames = {'Female'; 'Male'};
    elseif strcmp(datasetName, 'compasWB')
        load('../Data/compas/compas-data.mat', 'dataCompas', 'svarRace', 'raceNames');
        dataAll = dataCompas(svarRace==1 | svarRace==3, :);
        svarAll = (svarRace(svarRace==1 | svarRace==3) - 1) / 2 + 1;
        groupNames = raceNames([1,3]);
        clear dataCompas svarRace raceNames;
    elseif strcmp(datasetName, 'HMS')
        %load('../Data/LFW/LFW.mat', 'data', 'sensitive');

        dataAll = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedData.csv");
        

        logical_index = (dataAll(:, 4) == svar1);

        % Use the logical index to select the subset of rows from dataAll
        dataAll = dataAll(logical_index, :);

        dataAll_duped = dataAll;
        dataAll_duped(:, 4) = svar1 + 1;
        dataAll = vertcat(dataAll, dataAll_duped);




        svarAll = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedDataSVAR.csv");
        
        logical_index = (svarAll(:,1) == svar1);
        % Use the logical index to select the subset of rows from dataAll
        svarAll = svarAll(logical_index, :);
        svarAll_duped = svarAll;
        
        
        changeToOne = (svarAll(:,1) == svar1);
        changeToTwo = (svarAll_duped(:,1) == svar1);

        svarAll(changeToOne, 1) = 1;
        svarAll_duped(changeToTwo,1) = 2;

        svarAll = vertcat(svarAll, svarAll_duped);

        ethnicity_dict = containers.Map({1, 2, 3, 4, 5}, {'black', 'other', 'asian', 'hispanic', 'white'});

        %clear data sensitive; #1 corresponds to black, 2 to ainaan, 3 to asian, 4 to his, 5 to pi, 6 to mides, 7 to white, 8 to other.
        groupNames = {ethnicity_dict(svar1), ethnicity_dict(svar1)}; %Make dictionary in the future
    elseif strcmp(datasetName, 'NonFairKmeans') 
                %load('../Data/LFW/LFW.mat', 'data', 'sensitive');

        dataAll = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedData.csv");
        

        logical_index = (dataAll(:, 4));

        % Use the logical index to select the subset of rows from dataAll
        dataAll = dataAll(logical_index, :);

        dataAll_duped = dataAll;
        dataAll_duped(:, 4) = svar1 + 1;
        dataAll = vertcat(dataAll, dataAll_duped);




        svarAll = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedDataSVAR.csv");
        
        logical_index = (svarAll(:,1) == svar1);
        % Use the logical index to select the subset of rows from dataAll
        svarAll = svarAll(logical_index, :);
        svarAll_duped = svarAll;
        
        
        changeToOne = (svarAll(:,1) == svar1);
        changeToTwo = (svarAll_duped(:,1) == svar1);

        svarAll(changeToOne, 1) = 1;
        svarAll_duped(changeToTwo,1) = 2;

        svarAll = vertcat(svarAll, svarAll_duped);

        ethnicity_dict = containers.Map({1, 2, 3, 4, 5}, {'black', 'other', 'asian', 'hispanic', 'white'});

        %clear data sensitive; #1 corresponds to black, 2 to ainaan, 3 to asian, 4 to his, 5 to pi, 6 to mides, 7 to white, 8 to other.
        groupNames = {ethnicity_dict(svar1), ethnicity_dict(svar1)}; %Make dictionary in the future
    end

end

