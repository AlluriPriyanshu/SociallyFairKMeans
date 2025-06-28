% Load data
data = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedData.csv");
svar = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedDataSVAR.csv");
unadulteredData = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/unadulteratedData.csv");

datasep{1} = unadulteredData (svar == 1, :);
datasep{2} = unadulteredData (svar == 2, :);
datasep{3} = unadulteredData (svar == 3, :);
datasep{4} = unadulteredData (svar == 4, :);
datasep{5} = unadulteredData (svar == 5, :);
