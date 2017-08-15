function [ ] = format_TEOutput( output, nEntries )
% function [ ] = format_TEOutput( accumulate_output, nEntries )

LIGHT = 3;

disp('%%%%%%%%%%%%%%%%%%%%%%%%');

% title row
disp('Fluent Change Type & Action & Total Effect & Info Gain & Info Gain Rank & Cause \\');
disp('\hline');

actionNumber = LIGHT;

for row = 1:nEntries
    if ((output(1,row) == 3) || (output(1,row) == 2)) && (output(2,row) == 9)
        correct = '1';
    else
        correct = '0';
    end
    disp_text = [get_output_name(output(1,row),LIGHT), ' & '];
    disp_text = [disp_text '$A_{', int2str(output(2,row)), '}$', ' & '];
    disp_text = [disp_text num2str(output(4,row), '%.4f'), ' & '];
    disp_text = [disp_text num2str(output(3,row),'%.4f'), ' & '];
    disp_text = [disp_text num2str(output(6,row)), ' & '];
    disp_text = [disp_text correct ' \\'];
    disp(disp_text);
end

disp('%%%%%%%%%%%%%%%%%%%%%%%%');