function [ ] = format_latex( accumulate_output, nEntries )
%FORMAT_LATEX Summary of this function goes here
%   Detailed explanation goes here

DOOR = 1;
MONITOR = 2;
LIGHT = 3;
EXP1_DOOR = 4;

if nEntries > 10
    % need to split in 2 blocks...  divide in half
    nBlocks = 2;
else
    nBlocks = 1;
end

if any((accumulate_output(5,:) ~= 0) & (accumulate_output(5,:) ~=1))
    error('answer row is not zeros and ones');
end

if any( accumulate_output(7,:) < 0 )
    error('chi square row has negatives');
end

if any( accumulate_output(4,:) < 0 )
    error('info gain row has negatives');
end

if any( accumulate_output(1,:) < 0 )
    error('object title row has negatives');
end

if any((accumulate_output(2,:) ~= 1) & (accumulate_output(2,:) ~=2) & (accumulate_output(2,:) ~=3)& (accumulate_output(2,:) ~=4))
    error('output type row is not 1:4');
end

for output_block = 1:nBlocks
    object_title_row = 'OBJECT';
    output_type_row = 'FLUENT';
    action_row = 'ACTION';
    info_row = 'INFO';
    cause_row = 'CAUSE';
    causal_effect_row = 'TE';
    chi_square_row = '$\chi^2$'; 

    entry_indices = (10*output_block - 9):(10*output_block);
    if nEntries < max(entry_indices)
        entry_indices = intersect(entry_indices,1:nEntries);
    end
    for entry = entry_indices
        object_title_row = [object_title_row, ' & ', get_object_name(accumulate_output(1,entry))];
        output_type_row = strcat(output_type_row, ' & ', get_output_name(accumulate_output(2,entry),accumulate_output(1,entry)));
        action_row = [action_row, ' & ', '$A_{', int2str(accumulate_output(3,entry) - 1), '}$']; % subt 1 to offset for "inertial"
        if accumulate_output(4,entry) < 0.000001
            info_row = [info_row, ' & ', '0.0000'];
        else
            info_row = [info_row, ' & ', num2str(accumulate_output(4,entry),'%.4f')];
        end
        cause_row = [cause_row, ' & ', int2str(accumulate_output(5,entry))];
        causal_effect_row = [causal_effect_row, ' & ', num2str(accumulate_output(6,entry), '%.4f')];
        chi_square_row = [chi_square_row, ' & ', num2str(accumulate_output(7,entry), '%.3f')];
    end

    disp([object_title_row, ' \\']);
    disp([output_type_row, ' \\']);
    disp([action_row, ' \\']);
    disp([info_row, ' \\']);
    disp([cause_row, ' \\']);
    disp('\hline');
    disp([causal_effect_row, ' \\']);
    disp(chi_square_row);
end


end

