function [ stored_h ] = pushDepH(depSet, storedDepH)
%
%   Input:
%       depSet: row vector of actions that form a probablistically
%                   dependent set
%       storedDepH: the stored H for the entire dependent set
%   Output:
%       stored_h: the stored_h for each action in depSet


% clear the zero entries from depSet
depSet = depSet(1:nnz(depSet)); % nnz() = number of nonzero
if any(depSet == 0)
    error('depSet not in correct order');
end

nEntries = numel(storedDepH);

stored_h = zeros(8,numel(depSet));
actionCounter = 1;

for actionIndex = depSet
    % find action position in the dependent set from right (start at 1)
    actionPosition = find(fliplr(depSet) == actionIndex);

    [grouped, groupSize] = createDepHGroups(nEntries, actionPosition);
    nGroups = nEntries / groupSize;
    
    if nGroups ~= 8
        disp(nGroups)
        error('there should be 8 groups');
    end
    
    tmph = zeros(8,1);
    
    for singleGroup = 1:nGroups
        % these groups are in the same order as the elements of stored_h
        % reallocate the stored_h amount proportionately across all elements of
        % the group.

        groupIndices = grouped(((singleGroup-1)*groupSize+1):(singleGroup*groupSize));

        % calculate tmph
        tmph(singleGroup) = sum(storedDepH(groupIndices));

    end
%disp(stored_h)
    stored_h(:,actionCounter) = tmph / sum(tmph);    
%disp(stored_h)   
    actionCounter = actionCounter + 1;
    
end