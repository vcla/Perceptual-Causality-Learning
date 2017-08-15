function [ storedDepH ] = updateDepH( stored_h, actionIndex, depSet, ...
                                        storedDepH )
%UPDATEDEPH returns an updated storedDepH where the values of stored_h for
%actionIndex have been reallocated across actions in the dep set
%   
%   Input:
%       stored_h: the stored_h for actionIndex (the action that was just
%                   selected in pursuit)
%       actionIndex: the index of the action that was just selected in
%                   pursuit.  note: actionIndex 1 is the fluent.
%       depSet: row vector of actions that form a probablistically
%                   dependent set
%       storedDepH: the stored H for the entire dependent set
%
%   Output:
%       storedDepH: updated so that the newly assigned stored_h have been
%                   reallocated proportionately across the dependent set


% clear the zero entries from depSet
depSet = depSet(1:nnz(depSet)); % nnz() = number of nonzero
if any(depSet == 0)
    error('depSet not in correct order');
end

% find action position in the dependent set from right (start at 1)
actionPosition = find(fliplr(depSet) == actionIndex);

nEntries = numel(storedDepH);

[grouped, groupSize] = createDepHGroups(nEntries, actionPosition);
nGroups = nEntries / groupSize;

if nGroups ~= 8
    disp(nGroups)
    error('there should be 8 groups');
end


for singleGroup = 1:nGroups
    % these groups are in the same order as the elements of stored_h
    % reallocate the stored_h amount proportionately across all elements of
    % the group.
    
    groupIndices = grouped(((singleGroup-1)*groupSize+1):(singleGroup*groupSize));
    
    % the amount to reallocate
    tmph = stored_h(singleGroup);
    
    if tmph == 0
        storedDepH(groupIndices) = 0;
    else
        % calculate proportion that each group's total will go to each bin
        tmpProportions = storedDepH(groupIndices) / sum(storedDepH(groupIndices));
        % new values
        storedDepH(groupIndices) = tmpProportions .* tmph;
    end
        
end
%disp(storedDepH)
storedDepH = storedDepH / sum(storedDepH);
%disp(storedDepH)