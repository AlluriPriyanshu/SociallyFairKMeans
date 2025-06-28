clear;
close all;

data = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedData.csv");
dataNormalized = normalizeData(data);

dataUnNormalized = round(unnormalizeData(dataNormalized, data));

tf = isequal(data, dataUnNormalized);

testArray(1,1) = dataNormalized(1,1); 
testArray(1,2) = dataNormalized(2,2);
testArray(1,3) = dataNormalized(3,3);
testArray(1,4) = dataNormalized(4,4);

tested = round(unnormalizeData(testArray, data));