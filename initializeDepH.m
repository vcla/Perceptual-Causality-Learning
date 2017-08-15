function [ storedDepH ] = initializeDepH( dat, depSet )
%INITIALIZEDEPH Summary of this function goes here
%
%   Input:
%       dat = 
%       depSet = row vector of actions in the dependency set

% TODO (later): if want to specify a probability distribution over the
% nodes, this would be the place to do it

% clear the zero entries from depSet
depSet = depSet(1:nnz(depSet)); % nnz() = number of nonzero
if any(depSet == 0)
    error('depSet not in correct order');
end

% tabulate F, F(-1)
fluentProbs = tabulate(dat,[1 size(dat,2)]);
fluentProbs = fluentProbs / sum(fluentProbs);

% tabulate actions
actionProbs = tabulate(dat,depSet);
actionProbs = actionProbs / sum(actionProbs);

% initialize storedDepH
nActions = numel(depSet);
nDepH = 2^(nActions + 2);
storedDepH = zeros(1,nDepH);

indexCounter = 1;

for fluentVal = 1:4
    for actionVal = 1:(2^nActions)
        storedDepH(indexCounter) = fluentProbs(fluentVal) * actionProbs(actionVal);
        indexCounter = indexCounter + 1;
    end
end

storedDepH = storedDepH / sum(storedDepH);

