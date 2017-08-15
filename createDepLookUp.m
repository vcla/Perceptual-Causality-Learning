function [ deplookup ] = createDepLookUp( dat, deps )
%STOREDEPLOOKUP creates the dependency set lookup table
%
%   Input:
%       dat = where examples are stored
%       deps = #deps rows x maxdepsize cols ~ sets of dependencies
%              Ex: [2 3 4; <- one dependency group
%                   9 7 0; <- another one
%                   5 6 0] <- a third
%
%   Output:
%       deplookup = a matrix
%                   First Col: the dep group number for each action in dep
%                   Second Col: the position of action in dep set


%store which dependency group each action is in
deplookup = zeros((size(dat,2)),2);
for row = 1:size(deps,1) % number of dependency groups
    for col = 1:size(deps,2) % maxlength of a dep group
        action = deps(row,col); % cycling through each element of deps
        if (action > 0) % then this is an element of a dep group
            %error check -- no repeats in deps!
            if (action == 1) || (action == size(dat,2)) % then F or F(-1) is in deps
                error('the fluent value is in the deps set');
            end
            if action > size(dat,2)
                error('dependencies go outside number of actions');
            end
            if (deplookup(action) > 0)
                disp(deplookup)
                disp([row col action])
                error('overlapping dependency groups');
            end
            deplookup( action,1 ) = row;
            deplookup( action,2) = col;
        end
    end
end