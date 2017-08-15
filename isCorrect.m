function [ correct ] = isCorrect(tmpInds1, accumulate_output, data_index)

correct = 0;

tmpInds2 = find(accumulate_output(data_index,:) == max(accumulate_output(data_index,:)));
if tmpInds1 == tmpInds2
    % then we have found a time that works
    correct = 1;
elseif numel(tmpInds1) > 1
    for ind = tmpInds1
        if any(tmpInds2 == ind)
            correct = 1;
        end
    end
end