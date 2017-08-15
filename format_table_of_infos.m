function [ ] = format_table_of_infos( table_of_info_gains )
%FORMAT_TABLE_OF_INFO_GAINS Summary of this function goes here
%   Detailed explanation goes here

nCausalRelations = 20;
nRows = 15;

if nRows > size(table_of_info_gains,1)
    error('requesting more iterations than table_of_info_gains has');
end

if nCausalRelations > size(table_of_info_gains,2)
    error('requesting more actions than table_of_info_gains has');
end

% come up with best order for the causal relations (then display according to that order)
index_order = zeros(1,nCausalRelations);  
for i = 1:nCausalRelations
    % in the ith iteration, find which causal relation has the highest info gain
    tmp = find(table_of_info_gains(i,:) == max(table_of_info_gains(i,:)));
    if ~isempty(intersect(tmp,index_order))
        %disp(index_order);
        %disp(intersect(tmp,index_order));
        tmp = setdiff(tmp,index_order);
        warning('did not find unique CR for the iteration');
        if isempty(tmp)
            error('could not find specified number of causal relations');
        end
    end
    index_order(i) = tmp(1);
end

if numel(index_order) ~= numel(unique(index_order))
    disp(index_order)
    disp(tmp)
    error('one of the causal relations is getting used more than once');
end


% display the fluent type and action
fluent_row = ' ';
action_row = ' ';
for i = 1:nCausalRelations
    if mod(index_order(i),4) == 1
        % then outputtype 00 - Stay 0
        fluent_row = [fluent_row ' & Stay $C$'];
    elseif mod(index_order(i),4) == 2
        % then outputtype 01 - change from 1 to 0
        fluent_row = [fluent_row ' & $O \to C$'];
    elseif mod(index_order(i),4) == 3
        % then outputtype 10 - change from 0 to 1
        fluent_row = [fluent_row ' & $C \to O$'];
    elseif mod(index_order(i),4) == 0
        % then outputtype 11 - Stay 1
        fluent_row = [fluent_row ' & Stay $O$'];
    end
    
    action_row = [action_row ' & $A_{' int2str(ceil(index_order(i)/4)) '}$'];
end
% for i = 1:(size(table_of_info_gains,2)/4)
%     fluent_row = [fluent_row ' & Stay $C$ & $O \to C$ & $C \to O$ & Stay $O$'];
%     for j = 1:4
%         action_row = [action_row ' & $A_{' int2str(i+1) '}$'];
%     end
% end
 
disp([ fluent_row '\\'])
disp([action_row '\\'])
 
% display contents of table
for iteration = 1:nRows
    info_row = ['$k = ' int2str(iteration) '$ '];
    for col = index_order % 1:size(table_of_info_gains,2)
        % catch the max of the row -- toss special stuff around it to highlight it's the best solution
        % TODO: this highlights all if more than one is max.  
        if table_of_info_gains(iteration,col) == max(table_of_info_gains(iteration,:))
            if (iteration == find(index_order == col)) && table_of_info_gains(iteration,col) > .1
                info_row = [info_row, ' & \cellcolor[gray]{.8} \textbf{', num2str(table_of_info_gains(iteration,col),'%.4f'), '}'];
            else
                info_row = [info_row, ' & \textbf{', num2str(table_of_info_gains(iteration,col),'%.4f'), '}'];
            end
        else
            info_row = [info_row, ' & ', num2str(table_of_info_gains(iteration,col),'%.4f')];
        end

    end
    disp([info_row '\\']);
end

