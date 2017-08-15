function [ trueobservations ] = tabulate( dat, actions )
%TABULATE 
% count number of occurrences of each combo of actions

trueobservations = zeros(1,(2^numel(actions)));

for rowindex = 1:size(dat,1)
    datarow = dat(rowindex,:);
    index = 1; % needs to be offset by 1 for matlab
    for i = numel(actions):-1:1
        actionindex = actions(i);
        column = numel(actions) - i;
        index = index + 2^column * datarow(actionindex);
        %disp([rowindex i]);
        if index > numel(trueobservations)
            disp([actionindex column index rowindex]);
            error('trying to record tally out of scope; likely have frame info in dat');
        end
    end

    trueobservations(index) = trueobservations(index) + 1;
    %disp([index datarow])
end   %for rowindex = 1:size(dat,1)


end

