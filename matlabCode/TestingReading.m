clear;
close all;

% Open the file for reading
%fileID = fopen('uniqueHImpact.txt', 'r');
fileID = fopen('C:/Users/allur/PycharmProjects/ThreeClusterHMS/uniqueHImpact.txt','r');

% Check if the file is opened successfully
if fileID == -1
    error('Cannot open file for reading.');
end

% Initialize an empty string array to store the lines
lines = [];

% Read each line of the file and store it in the string array
while ~feof(fileID)
    line = strtrim(fgets(fileID)); % Read and trim the line
    if ischar(line)
        lines = [lines; string(line)]; % Append the line to the string array
    end
end

% Close the file
fclose(fileID);

variableNames = lines';
% Display the lines stored in the string array

save('variableNames','variableNames')
