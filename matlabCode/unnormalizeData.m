function [data_unnormalized] = unnormalizeData(data_normalized, data_original)
    [~, d] = size(data_original);
    data_unnormalized = zeros(size(data_normalized));
    flags = zeros(1, d);
    for i = 1:d
        if std(data_original(:, i)) ~= 0
            data_unnormalized(:, i) = data_normalized(:, i) * std(data_original(:, i)) + mean(data_original(:, i));
            flags(i) = 1;
        else
            data_unnormalized(:, i) = data_normalized(:, i);
        end
    end
end