function [output] = all_outputs_together(dat, displayTEBool, displayChiSqBool)
% The "old" way of handling dependencies.  need to verify my new way is
% better.
%
%   input:
%       dat     Rows: examples
%               Columns: actions (1 if action occurred in example, 0 o/w)
%               First column: fluent value at t
%               Last column: inertial value (fluent value at t-1)
%
%       displayTEBool = boolean if total causal effect output desired
%
%       displayChiSqBool = boolean if chi square output desired
%
%
%


% clear all; 
% 
% %%%%%%%%%% DOOR
% dat = csvread('Exp2_output_data.txt', 1,0);
% % remove the columns 1(frame), 3(monitor), 4 (light), 5(agent)
% dat = remove_cols(dat, [1, 3, 4, 5]);
% dat = add_inertial(dat);
% 
% %%%%%%%%%% LIGHT
% dat = csvread('Exp2_output_data.txt', 1,0);
% % remove the columns 1(frame), 2(door_status), 3(monitor), 5(agent)
% dat = remove_cols(dat, [1, 2, 3, 5]);
% dat = add_inertial(dat);
% 
% %%%%%%%%%% MONITOR
% dat = csvread('Exp2_output_data.txt', 1,0);
% % remove the columns 1(frame), 2(door), 4 (light), 5(agent)
% dat = remove_cols(dat, [1, 2, 4, 5]);
% dat = add_inertial(dat);
% 
% %%%%%%%%%% HIERARCHICAL DOOR
% dat = [];
% dat = csvread('Exp1_output_data_key.txt', 1,0);  % key lock
% dat = logical([dat; csvread('Exp1_output_data2.txt',1,0)]); %door no lock
% dat = [dat; csvread('Exp1_output_data3.txt',1,0)]; % pass code lock
% % TODO: add on the other outputs for experiment 1!!!
% dat = prepare_exp1_dat(dat);
% dat = remove_cols(dat, [1, 3]);
% dat = add_inertial(dat);


% assuming inertial is last column of dat
inertial_index = size(dat,2);

% initialize the bestactions
bestactions = 1;
bestoutput = 0;
bestactionscore = 0;
causaleffect = 0;
causaleffect2 = 0;


if displayTEBool
    % initialize output
    TEOutput = [];
end

if displayChiSqBool
    chiSquareOutput = [];
end

% initialize stored_h and stored_f
stored_h = zeros(8,inertial_index);
stored_f = zeros(8,inertial_index);
tmp = tabulate(dat,[1 inertial_index]);
h_fluent = [tmp(1) tmp(1) tmp(2) tmp(2) tmp(3) tmp(3) tmp(4) tmp(4)];
if numel(tmp) > 4
    error('tmp too large');
end
for actionindex = 2:size(dat,2)
    stored_f(:,actionindex) = tabulate(dat,[1 inertial_index actionindex]);
    stored_f(:,actionindex) = stored_f(:,actionindex)/sum(stored_f(:,actionindex));
    
    tmp = tabulate(dat,actionindex);
    h_action = [tmp tmp tmp tmp];
    stored_h(:,actionindex) = h_fluent .* h_action / sum(h_fluent .* h_action);
end

table_of_info_gains = [];

for iteration = 1:20
    nextbestaction = 0;
    nextbestactionscore = 0;
    nextbesth = [];
    
    for outputtype = 1:4

        if outputtype == 1 %F0 A0
            indices10 = 1;
            indices11 = 2;
        elseif outputtype == 2 %F0 A1
            indices10 = 3;
            indices11 = 4;
        elseif outputtype == 3 %F1 A0
            indices10 = 5;
            indices11 = 6;
        elseif outputtype == 4 %F1 A1
            indices10 = 7;
            indices11 = 8;
        end

        indices00 = 1:2:7; 
        indices00(indices00 == indices10) = [];

        indices01 = 2:2:8;
        indices01(indices01 == indices11) = [];


        for actionindex = 2:(size(dat,2)-1) % minus one to not count "inertial"
            % make sure we don't repeat an action/output type combo
            tmpind = find(bestactions == actionindex);
            if ~any(bestoutput(tmpind) == outputtype) % then the action is already included
%disp([actionindex outputtype]);


                % call up true observations (f)
                f = stored_f(:,actionindex);
                f = [sum(f(indices00)) sum(f(indices01)) f(indices10) f(indices11)];
                f = f/sum(f);
% disp('f')
% disp(f)            

                h = stored_h(:,actionindex);
                h = [sum(h(indices00)) sum(h(indices01)) h(indices10) h(indices11)];
                h = h / sum(h);
% disp('h')
% disp(h)
                % calculate info gain
                info = calc_KL(f, h);
%disp([nextbestactionscore info]);
                
%                 if (actionindex == 2) && (outputtype == 3)
%                     disp(info);
%                     disp(stored_h(:,actionindex)/sum(stored_h(:,actionindex)));
%                 end
                table_of_info_gains(iteration, ((actionindex - 2)*4 + outputtype)) = info;
                
                if displayTEBool && (iteration == 1)
                    TEOutput = [TEOutput [info; (f(4)/(f(4)+f(2)) - f(3)/(f(3)+f(1)))]];
                end
                
                if displayChiSqBool && (iteration == 1)
                    tmpf = tabulate(dat,[1 inertial_index actionindex]);
                    tmpf = [sum(tmpf(indices00)) sum(tmpf(indices01)); tmpf(indices10) tmpf(indices11)];
                    chiSquareOutput = [chiSquareOutput [0; chiSquare(tmpf)]];
                    chiSquareOutput(1,end) = info;
                    %asdf
                end

                % keep best info/action/h
                if info > nextbestactionscore
                    nextbestaction = actionindex;
                    nextbestactionscore = info;
                    nextbestoutput = outputtype;
                    nextindices00 = indices00;
                    nextindices01 = indices01;
                    nextindices10 = indices10;
                    nextindices11 = indices11;
                    nextbestf = f;
                end
            end % check for action/outputtype



        end % actionindex
    end % outputtype

    % append best action to bestaction
    bestoutput = [bestoutput nextbestoutput];
    bestactions = [bestactions nextbestaction];
    bestactionscore = [bestactionscore nextbestactionscore];

    % calculate causal effect P(F = 1 | do(A)) - P(F = 1 | do(not A))
    f = stored_f(:,nextbestaction);
    causaleffect2 = [causaleffect2 ((f(6) + f(8))/(sum(f(2:2:8))) - (f(5)+f(7))/(sum(f(1:2:7)))) ];
    
    % calculate the causal effect P(del F | do(A)) - P(del F | do(not A))
    f = nextbestf;
    causaleffect = [causaleffect (f(4)/(f(4)+f(2)) - f(3)/(f(3)+f(1)))];

    if nextbestactionscore < .00001
        break;
    end

    % calculate the new h
    stored_h(nextindices11,nextbestaction) = f(4);
    stored_h(nextindices10,nextbestaction) = f(3);
    % split the f(1) across the nextindices00
    tmpsum = sum(stored_h(nextindices00,nextbestaction));
    stored_h(nextindices00,nextbestaction) = f(1) * stored_h(nextindices00,nextbestaction) / tmpsum;
    % split the f(2) accross the nextindices01
    tmpsum = sum(stored_h(nextindices01,nextbestaction));
    stored_h(nextindices01,nextbestaction) = f(2) * stored_h(nextindices01,nextbestaction) / tmpsum;
    stored_h(:,nextbestaction) = stored_h(:,nextbestaction) / sum(stored_h(:,nextbestaction));

end % end iteration, accruing best 20 actions


output = [bestoutput; bestactions; bestactionscore; causaleffect; causaleffect2];
output = output(:,2:end);
%disp(output);
disp('TABLE OF INFO GAINS');
format_table_of_infos(table_of_info_gains);

if displayTEBool
    disp('TABLE OF INFO VS TE');
    % sort by info, put rank as first row
    TEOutput = sortrows(TEOutput',-1)';
    TEOutput = [1:size(TEOutput,2); TEOutput];
    % sort by TE (now in 3rd row)
    TEOutput = sortrows(TEOutput',-3)';
    disp(TEOutput);
end

if displayChiSqBool
    disp('TABLE OF INFO VS CHI SQ')
    chiSquareOutput = sortrows(chiSquareOutput',-2)';
    disp(chiSquareOutput);
end

