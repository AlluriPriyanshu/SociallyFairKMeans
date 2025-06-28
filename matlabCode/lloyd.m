function [centers, clustering, runtime] =...
    lloyd(data, svar, k, numIters, bestOutOf, randCenters, isFair)
    
    minCost = inf;
    runtime = 0;
    disp('here')
    datasep = cell(1,2);
    if isFair == 1
        datasep{1} = data(svar == 1, :);
        datasep{2} = data(svar == 2, :);
        data = datasep;
        dataTemp = [data{1};data{2}];
        ns = [size(data{1}, 1), size(data{2}, 1)]; %Lists the number of data points for each svar; if there are 25 female and 30 male, ns would be 25, 30
    else
        dataTemp = data;
        ns = [1, 1];
    end
    %Rand centers is a 3 dimensional array; this goes through each value of
    %i and turns rand centers into a 2d array to compare for each i
    for i = 1:bestOutOf
        disp(i);
        currentCenters = squeeze(randCenters(i, :, :));
        
        tStart = tic;
        
        for j = 1:numIters
            if j == numIters %only runs on the last iteration
                currentClustering = findClustering(dataTemp, ns, currentCenters, 1, isFair);
            else  %runs for everything except the last iteration
                currentClustering = findClustering(dataTemp, ns, currentCenters, 0, isFair);
                currentCenters =...
                    findCenters(data, svar, k, currentClustering, isFair);
            end
        end
        
        runtime = runtime + toc(tStart);
        
        currentCost = compCost(data, svar, k, currentClustering, isFair);
        
        if minCost > currentCost
            minCost = currentCost;
            disp("ASSIGNED CENTERS")
            centers = currentCenters;
            clustering = currentClustering;
        end
    end

    runtime = runtime / bestOutOf;
end

