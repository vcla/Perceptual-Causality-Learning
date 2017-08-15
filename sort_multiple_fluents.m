function [ sorted ] = sort_multiple_fluents( light, monitor, door, sort_row )
% function [ sorted ] = sort_multiple_fluents( light, monitor, door )
% 
% sorts columns by the given sort_row.  


% examine (sort_row) entry in first column.  move largest to sorted.  delete from
% current.

sorted = [];

% while ~isempty(monitor) || ~isempty(door) || ~isempty(light)
%while light(sort_row,1) > 0 || monitor(sort_row,1) > 0 || door(sort_row,1) > 0
while light(sort_row,1) > -100 || monitor(sort_row,1) > -100 || door(sort_row,1) > -100

%     if isempty(monitor)
%         monitor(sort_row,1) = -100;
%     end
%     
%     if isempty(light)
%         light(sort_row,1) = -100;
%     end
%     
%     if isempty(door)
%         door(sort_row,1) = -100;
%     end

    if light(sort_row,1) > monitor(sort_row,1)
        % then light is larger, see if door is larger still
        if door(sort_row,1) > light(sort_row,1)
            % then door is the biggest
            sorted = [sorted door(:,1)];
            door(:,1) = [];
            door(:,(end+1)) = -100;
        else
            % light is biggest
            sorted = [sorted light(:,1)];
            light(:,1) = [];
            light(:,(end+1)) = -100;
        end
    else
        % light is not larger than monitor
        if door(sort_row,1) > monitor(sort_row,1)
            % then door is biggest
            sorted = [sorted door(:,1)];
            door(:,1) = [];
            door(:,(end+1)) = -100;
        else
            %monitor is biggest
            sorted = [sorted monitor(:,1)];
            monitor(:,1) = [];
            monitor(:,(end+1)) = -100;
        end
    end
    
%     if isempty(monitor)
%         monitor(sort_row,1) = -100;
%     end
%     
%     if light(sort_row,1) == -100
%         light = [];
%     end
%     
%     if door(sort_row,1) == -100
%         door = [];
%     end
%     
%     if monitor(sort_row,1) == -100
%         monitor = [];
%     end
%disp([size(sorted) size(light) size(monitor) size(door)])
end


end

