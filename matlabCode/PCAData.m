function [dataFairPCA, dataNonfairPCA, dataWithoutPCA] = PCAData(data, svar, numFeatures)
        [coeff, score, latent] = pca(data);
        NonfairPCA = coeff(:, 1:numFeatures);
        dataNonfairPCA = data * NonfairPCA;
        % we do fair PCA here
        FairPCA = fairPCA(data, numFeatures, svar); 
        dataFairPCA = data * FairPCA;
        dataWithoutPCA = normalizeData(data); 
end

