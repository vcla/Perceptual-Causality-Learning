function [ allinfo ] = calc_KL( allF, allH )
%function [ allinfo ] = calc_KL( allF, allH )
%CALC_KL calculate the KL divergence between allF and allH


if sum(allF) > 1.001 || sum(allF) < 0.999
    error('allF is out of bounds');
elseif sum(allH) > 1.001 || sum(allH) < 0.999
    error('allH is out of bounds');
end

allinfo = 0;

for term = 1:numel(allF)
    if allF(term) ~= 0
        if allH(term) == 0
            error('H has some zeros where it should not!');
        end
        allinfo = allinfo + allF(term) * log( allF(term) / allH(term) );
    end
end

if allinfo < -.00001
    allH
    allF
    sum(allF)
    sum(allH)
    nExamples        
    [allH allinfo]
    error('we calculated a negative KL divergence');
end

end

