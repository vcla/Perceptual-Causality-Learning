function [ grouped, groupSize ] = createDepHGroups( nEntries, actionPosition )
% CREATEDEPHGROUPS is a helper function to get indices that correspond to
% groups where F, F(-1), and action have similar values
%
%   Input:
%       nEntries = number of entries in stored_h for the dependent set
%       actionPosition = action position in the dependent set from right, starting at 1
%   Output:
%       grouped = the indices grouped according to similar F, F(-1), action
%       groupSize = size of a group


tol = 0.00001;

nActions = log2(nEntries) - 2; 

if abs(nActions - uint32(nActions)) > tol
    error('stored h does not have power of 2 elements');
end

% initializations 
done = zeros(1, nEntries);      % a check if elemented already accounted for
grouped = zeros(1, nEntries);   % gives the indices grouped
g = 0;                          % working group number
groupSize = 2^(nActions - 1);   % each group will have size 2^(other actions)

%for n = 0:(nEntries-1)
for n = 1:(nEntries)
    group = zeros(1,groupSize);
    
    if ~done(n) % then hasn't been done yet
        for i = 0:(groupSize-1)   % count through the other actions
            mask = i;
            for digit = nActions:-1:(actionPosition+1)
                mask = bitset(mask, digit, bitget(mask, digit - 1));
                %bitset(mask, digit+1, bitget(mask, digit));
            end
            mask = bitset(mask,actionPosition,0);
            group(i+1) = bitxor(n-1,mask)+1;
            if group(i+1) == 0
                error('stop here')
                %group(i+1) = 100;
            end
            done(group(i+1)) = 1;
            grouped((g * groupSize)+i+1) = group(i+1);
            
        end
        
        if numel(grouped) > nEntries
            disp([n mask group(i+1)])
            error('too many elements in grouped')
        end
        
        g = g+1;
    end
end