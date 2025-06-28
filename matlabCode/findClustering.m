function [clusterIdx] = findClustering(data, ns, centers, isLast, isFair)

    k = size(centers, 1); %k is equal to numCenters
    n = size(data, 1);

    if k ==1
        if isFair == 0
            clusterIdx = ones(1,size(data,1));
            return;
        else
            clusterIdx = cell(1,2);
            clusterIdx{1} = ones(ns(1),1);
            clusterIdx{2} = ones(ns(2),1);
            return
        end
    end



    if isFair == 0
        dists = zeros(k, n);
        for i = 1:k
            dists(i, :) = (sum((data - centers(i, :)).^2, 2))';
        end
        [~, clusterIdx] = min(dists);

        if isLast == 0
            clusNum = zeros(1, k);
            for i=1:k
                clusNum(i) = sum(clusterIdx == i);
            end
            for i = 1:k
                if clusNum(i) == 0
                    [~,sArr] = sort(sum((data - centers(i, :)).^2, 2));
                    for j = 1:n
                        if size(clusNum,2) == 1
                            temp =1; %added by PA for one cluster solution
                            disp("JUST RAN THIS")
                        else
                            disp(clusterIdx(sArr(j)))
                            temp = clusterIdx(sArr(j));
                            disp("DID NOT RUN TEMP = 1")
                        end
                        if clusNum(temp) > 1
                            clusNum(i) = clusNum(i) + 1;
                            clusNum(temp) = clusNum(temp) - 1;
                            clusterIdx(sArr(j)) = i;
                            break;
                        end
                    end
                end
            end
        end
    else
        dists = zeros(k, n); %generates a list of 0s with dim: numCenters by numSamples
        for i = 1:k %for each center, calculates the distances
            dists(i, :) = (sum((data - centers(i, :)).^2, 2))';
        end
        [~, clusterTemp] = min(dists); %picks which cluster distance (calculated 2 lines above is the smallest and adds to ClusterTemp)
        if k ==1
            clusterIdx = cell(1,2);
            clusterIdx{1} = ones(ns(1),1)
            clusterIdx{2} = ones(ns(2),1)
        else
        clusterIdx = cell(1,2); %splits and stores clusterTemp by svar
        clusterIdx{1} = clusterTemp(1:ns(1));
        clusterIdx{2} = clusterTemp((ns(1)+1):end); 
        end

        if isLast == 0
            clusNum = zeros(1, k);
            for i=1:k
                clusNum(i) = sum(clusterTemp == i); %clusNum stores the number of times a cluster is in clusterTemp
            end
            for i = 1:k
                if clusNum(i) == 0 %if a cluster is NEVER the best cluster for ANY data point
                    [~,sArr] = sort(sum((data - centers(i, :)).^2, 2)); % for each variable for each sample, calculates the distance from that variable to the center.
                    %Then, this sums the distance for each variable for
                    %each sample. This yields one number per sample that
                    %corresponds to how far away each sample was from 
                    %center i. It then sorts them. However, simply sorting
                    %would lose sample information -- we wouldn't know
                    %which sample corresponds to which sum. Therefore, we
                    %place the indices in order. For example, a list with
                    %costs 45, 23, 57 would be turned to 1,0,2. This lets
                    %us know which sample has the lowest cost without
                    %losing track of the sample. 
                    for j = 1:n
                        n1 = length(clusterIdx{1}) %SET AS A GUESS - but confident. N1 is used later in the code to determine which svar a sample corresponds to
                        %the length of clusterIdx{1} gives the final index
                        %corresponding to svar 1. Since sArr is a sorted
                        %list (of indices), this'll let us determine which
                        %svar a sample corresponds to. Normally we don't
                        %need to do this, but sorting earlier means that we
                        %lost positional information that used to tell us
                        %this
                     
                        if sArr(j) <= n1 
                            disp(n1)
                            temp = clusterIdx{1}(sArr(j));
                            tempi = 1;
                        else
                            temp = clusterIdx{2}(sArr(j) - n1);
                            tempi = 2;
                        end
                        if clusNum(temp) > 1
                            clusNum(i) = clusNum(i) + 1;
                            clusNum(temp) = clusNum(temp) - 1;
                            if tempi == 1
                                clusterIdx{1}(sArr(j)) = i;
                            else
                                clusterIdx{2}(sArr(j) - n1) = i;
                            end
                            break;
                        end
                    end
                end
            end
        end
    end
end

