% Load data
data = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedData.csv");
svar = csvread("C:/Users/allur/OneDrive - Dartmouth College/Desktop/Marreo Lab Work/Socially Fair K means/HMS/selectedDataSVAR.csv");

% Calculate quartiles
Q = quantile(data(:, 1), [0.25, 0.5, 0.75]);

% Separate data based on 'svar'
numGroups = 5;
datasep = cell(1, numGroups);
for i = 1:numGroups
    datasep{i} = data(svar == i, :);
end

% Define ethnicity dictionary
ethnicity_dict = containers.Map({1, 2, 3, 4, 5}, {'black', 'other', 'asian', 'hispanic', 'white'});

% Define color scheme
viridis_color_scheme = [[253 231 37]; [68 1 84]; [33 145 140]; [59 82 139]; [94 201 98]; [255 0 0]; [0 0 255]] / 255;
S = 25;

colors = [
    0 0.4470 0.7410;
    0.8500 0.3250 0.0980;...
    0.9290 0.6940 0.1250;...
    0.4940 0.1840 0.5560;...
    0.4660 0.6740 0.1880;...
    0.3010 0.7450 0.9330;...
    0.6350 0.0780 0.1840...
];

% Create a tiled layout for the scatter plots
t = tiledlayout(2, 2);

% Define quartile ranges
quartile_ranges = [-Inf, Q(1); Q(1), Q(2); Q(2), Q(3); Q(3), Inf];

% Plot data for each quartile
for quartile = 1:4
    nexttile;
    hold on;
    for svar = 1:5
        % Find the indices of the data within the current quartile range and svar group
        logical_index = datasep{svar}(:,1) > quartile_ranges(quartile, 1) & datasep{svar}(:,1) <= quartile_ranges(quartile, 2);
        % Plot the data points
        scatter(datasep{svar}(logical_index,2), datasep{svar}(logical_index, 3), S, colors(svar, :), 'filled');
    end
    title(['Diener Quartile ', num2str(quartile)]);
    xlabel('PHQ 9 score');
    ylabel('GAD 7 score');
    xlim([5,40]); 
    ylim([5,30]); 
    hold off;
end

% Add a legend to the figure
legend_labels = values(ethnicity_dict);
legend(legend_labels, 'Location', 'bestoutside');

