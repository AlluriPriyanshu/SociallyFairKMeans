function [costs, clustering] = bootstrappedCostCalculatorCopy(sepData, centers)
    
    %calcualtes the costs for each different race from the fair centers
    %generated for two groups -- Created by Priyanshu Alluri
    
    concatData = [sepData{1};sepData{2};sepData{3}; sepData{4};sepData{5}];

    ns = [size(sepData{1}, 1), size(sepData{2}, 1), size(sepData{3}, 1),...
    size(sepData{4}, 1), size(sepData{5}, 1)];

    k = 3; %k is equal to numCenters
    n = size(concatData, 1);
    dists = zeros(k, n); %generates a list of 0s with dim: numCenters by numSamples
    
    %find clustering      
    for i = 1:k %for each center, calculates the distances for each feature
        dists(i, :) = (sum((concatData - centers{3}(i, :)).^2, 2))';
    end
    
    [~, clusterTemp] = min(dists); %picks which cluster distance (calculated 2 lines above is the smallest and adds to ClusterTemp)
    clusterIdx = cell(1,5); %splits and stores clusterTemp by svar
    clusterIdx{1} = clusterTemp(1:ns(1));
    
    nIndex = ns(1);
    clusterIdx{2} = clusterTemp((nIndex+1):nIndex+ ns(2)); 
    
    nIndex = nIndex + ns(2);
    clusterIdx{3} = clusterTemp((nIndex+ 1):nIndex+ ns(3));
    
    nIndex = nIndex + ns(3);
    clusterIdx{4} = clusterTemp((nIndex + 1):nIndex + ns(4));
    
    nIndex = nIndex + ns(4);
    clusterIdx{5} = clusterTemp((nIndex + 1):nIndex + ns(5));
    
    clustering = clusterIdx;
    
    costs(1) = kmeansCost_S_C(sepData{1}, clustering{1}, centers{3}, 1) / size(sepData{1}, 1);
    costs(2) = kmeansCost_S_C(sepData{2}, clustering{2}, centers{3}, 1) / size(sepData{2}, 1);        
    costs(3) = kmeansCost_S_C(sepData{3}, clustering{3}, centers{3}, 1) / size(sepData{3}, 1);
    costs(4) = kmeansCost_S_C(sepData{4}, clustering{4}, centers{3}, 1) / size(sepData{4}, 1);
    costs(5) = kmeansCost_S_C(sepData{5}, clustering{5}, centers{3}, 1) / size(sepData{5}, 1);
end