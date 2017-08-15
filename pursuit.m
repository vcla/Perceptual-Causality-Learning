function [output] = pursuit(dat, displayTEBool, displayChiSqBool, ...
                            displayInfoTableBool, fluctuationBool, deps, nIterations, ...
                            outputTypes, nCauses)
% [output] = pursuit(dat, displayTEBool, displayChiSqBool, ...
%                            displayInfoTableBool, fluctuationBool, deps, nIterations, ...
%                            outputTypes, nCauses)
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
%       displayInfoTableBool = boolean if table of information gains by 
%                               iteration output desired
%
%       deps = #deps rows x maxdepsize cols ~ sets of dependencies
%              Ex: [2 3 4; <- one dependency group
%                   9 7 0; <- another one
%                   5 6 0] <- a third
%              Ex: [] <- for no dependencies
%               *** Zeros fill out the rows
%               *** these are columns from dep, not action numbers and
%                   do not take into account that the fluent is first.
%
%       nIterations = number of iterations to run, defaults to 20.
%
%
%   Output:
%       Row 1: Output type for selected causal relation
%       Row 2: Action for selected causal relation
%       Row 3: Info gain for selected causal relation
%       Row 4: TE for selected causal relation
%       Row 5: Chi-Square for selected causal relation


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


%%% INITIALIZE DESIRED OUTPUTS %%%

if nIterations == false
    nIterations = 20;
end

% initialize total causal effect for output/display
if displayTEBool
    TEOutput = [];
end

% initialize chi square for output/display
if displayChiSqBool
    chiSquareOutput = [];
end

% initialize table of information gains for output/display
if displayInfoTableBool
    table_of_info_gains = [];
end


%%% INITIALIZATIONS %%%

% TODO: replace stored_h initialization with call to initializeDepH

if fluctuationBool
    % FLUCTUATION
    nExamples = size(dat,1);
end

% assume inertial (previous fluent value) is last column of dat
inertial_index = size(dat,2);

if any(dat(:,1) > 10)
    error('looks like dat has frames in first column...')
end

% initialize the best's (will grow as vectors each iteration)
bestactions = 1;        % the best action selected in each iter
bestoutput = 0;         % the corresponding output type (1:4)
bestactionscore = 0;    % the corresponding information gain
causaleffect = 0;       % the calculated total causal effect
%causaleffect2 = 0;      % the causal effect (not counting pursuing changes)
bestchisquare = 0;      % chi square for the best selected causal relation

% initialize stored_h (model counts) and stored_f (true counts)
% stored_h: actions are independent of fluent value change, and 
%           calculates as P(A) * P(\Delta F) from tabulated observations
% store_f: tabulates (Fluent, Previous Fluent, Action) for each action
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


% create a lookup table to give which dep group an action belongs to
deplookup = createDepLookUp( dat, deps );
if max(deplookup) ~= size(deps,1)
    error('deplookup does not match number of rows of deps');
end

%initialize cell depSetH to hold stored_h for each dep set
depSetH = cell(1, size(deps,1));
for depSetIndex = 1:numel(depSetH)
    depSetH{depSetIndex} = initializeDepH(dat,deps(depSetIndex,:));
end

%disp(depSetH{9})
%asdf

%%% THE MAIN PURSUIT LOOP %%%
% in each iteration, examine each action against each fluent change type,
% keeping the pair that gives the highest information gain

for iteration = 1:nIterations
    nextbestaction = 0;
    nextbestactionscore = 0;
    nextbesth = [];
    
    % for each type of change F(-1) -> F
    %for outputtype = 1:4
    for outputtype = outputTypes
        
        % set the groups for the indices
        if outputtype == 1      %F0 F(-1)0
            indices10 = 1;
            indices11 = 2;
        elseif outputtype == 2  %F0 F(-1)1
            indices10 = 3;
            indices11 = 4;
        elseif outputtype == 3  %F1 F(-1)0
            indices10 = 5;
            indices11 = 6;
        elseif outputtype == 4 %F1 F(-1)1
            indices10 = 7;
            indices11 = 8;
        end

        indices00 = 1:2:7; 
        indices00(indices00 == indices10) = [];

        indices01 = 2:2:8;
        indices01(indices01 == indices11) = [];

% FOR FIRST FIT
% indices00 = [1 3];
% indices11 = [6 8];
% indices01 = [2 4];
% indices10 = [5 7];
        
        % examine each action with each output type
        for actionindex = 2:(size(dat,2)-1) % minus one to not count "inertial"
%        for actionindex = 2:(size(dat,2)) % minus one to not count "inertial"
            
            % make sure we don't repeat an action/output type combo
            tmpind = find(bestactions == actionindex);
            if ~any(bestoutput(tmpind) == outputtype) 
                % then the action/output is not already included
%disp([actionindex outputtype]);

                % call up true observations (f)
                f = stored_f(:,actionindex);
                f = [sum(f(indices00)) sum(f(indices01)) f(indices10) f(indices11)];
% FOR FIRST FIT: f = [sum(f(indices00)) sum(f(indices01)) sum(f(indices10)) sum(f(indices11))];
                f = f/sum(f);
% disp('f')
% disp(f)            

                h = stored_h(:,actionindex);
                h = [sum(h(indices00)) sum(h(indices01)) h(indices10) h(indices11)];
% FOR FIRST FIT: h = [sum(h(indices00)) sum(h(indices01)) sum(h(indices10)) sum(h(indices11))];
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

                if displayInfoTableBool 
                    % adjust for sampling error
                    if fluctuationBool
                        % FLUCTUATION
                        table_of_info_gains(iteration, ((actionindex - 2)*4 + outputtype)) = max((info - 1/nExamples),0);
                    else
                        table_of_info_gains(iteration, ((actionindex - 2)*4 + outputtype)) = info;
                    end
                end
                
                if displayTEBool && (iteration == 1)
                    %TEOutput = [TEOutput [info; (f(4)/(f(4)+f(2)) - f(3)/(f(3)+f(1)))]];
                    if fluctuationBool
                        % FLUCTUATION
                        tmpTE = [max((info - 1/nExamples),0); (f(4)/(f(4)+f(2)) - f(3)/(f(3)+f(1)))];
                    else
                        tmpTE = [info; (f(4)/(f(4)+f(2)) - f(3)/(f(3)+f(1)))];
                    end
                    tmpTE = [tmpTE; (f(4)/(f(4)+f(2)) - (nCauses - 1)/nCauses * (h(4)/(h(4)+h(2))))];
                    %tmpTE = [tmpTE; (f(4)/(f(4)+f(2)) -  (h(4)/(h(4)+h(2))))];
                    TEOutput = [TEOutput tmpTE];
                end
                
                if displayChiSqBool && (iteration == 1)
                    tmpf = tabulate(dat,[1 inertial_index actionindex]);
                    tmpf = [sum(tmpf(indices00)) sum(tmpf(indices01)); tmpf(indices10) tmpf(indices11)];
                    chiSquareOutput = [chiSquareOutput [0; hellingerChiSquare(tmpf)]];
                    %chiSquareOutput = [chiSquareOutput [0; chiSquare(tmpf)]];
                    if fluctuationBool
                        % FLUCTUATION
                        chiSquareOutput(1,end) = max((info-1/nExamples),0);
                    else
                        chiSquareOutput(1,end) = info;
                    end
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
%disp([iteration actionindex outputtype info size(f)])
            end % check for action/outputtype

        end % actionindex
    end % outputtype
    
    if nextbestaction == 0
        % then no action was found
%        warning('No action could be found with info gain above tol');
        break;
    end

%disp([nextbestaction nextbestoutput nextbestactionscore size(nextbestf)])

    % append best action to bestaction
    bestoutput = [bestoutput nextbestoutput];
    bestactions = [bestactions nextbestaction];
    bestactionscore = [bestactionscore nextbestactionscore];

%     % calculate causal effect P(F = 1 | do(A)) - P(F = 1 | do(not A))
%     f = stored_f(:,nextbestaction);
%     causaleffect2 = [causaleffect2 ((f(6) + f(8))/(sum(f(2:2:8))) - (f(5)+f(7))/(sum(f(1:2:7)))) ];

    
    % calculate the causal effect P(del F | do(A)) - P(del F | do(not A))
    f = nextbestf;
    %causaleffect = [causaleffect (f(4)/(f(4)+f(2)) - f(3)/(f(3)+f(1)))];
    causaleffect = [causaleffect ( (f(4)/(f(4)+f(2)) - ...
                                    f(3)/(f(3)+f(1))     ) / ...
                              ( 1 - f(3)/(f(3)+f(1)) )      )]; % delta P / (1 - P(effect | no cause))
            % causal power.  NOTE: i replaced this formula for the CogSci
            % submission...  this way i can compare the causal power
    
    % calculate the chi square for the best causal relation 
    tmpf = tabulate(dat,[1 inertial_index nextbestaction]);
    tmpf = f * sum(tmpf);
    bestchisquare = [bestchisquare hellingerChiSquare([tmpf(1:2); tmpf(3:4)])];
    %bestchisquare = [bestchisquare chiSquare([tmpf(1:2); tmpf(3:4)])];
    
    if nextbestactionscore < .00001
        break;
    end

    % calculate the new h
%perm_stored_h = stored_h;
    stored_h(nextindices11,nextbestaction) = f(4);
    stored_h(nextindices10,nextbestaction) = f(3);
    % split the f(1) across the nextindices00
    tmpsum = sum(stored_h(nextindices00,nextbestaction));
    stored_h(nextindices00,nextbestaction) = f(1) * stored_h(nextindices00,nextbestaction) / tmpsum;
    % split the f(2) accross the nextindices01
    tmpsum = sum(stored_h(nextindices01,nextbestaction));
    stored_h(nextindices01,nextbestaction) = f(2) * stored_h(nextindices01,nextbestaction) / tmpsum;
    stored_h(:,nextbestaction) = stored_h(:,nextbestaction) / sum(stored_h(:,nextbestaction));
%disp('disp(perm_stored_h - stored_h)')    
%disp(perm_stored_h - stored_h)
    
    % check if action added is part of a dependency set
    depGroup = deplookup(nextbestaction);
%size(depSetH{8})
%size(stored_h)
%disp([depSetH{8}' stored_h(:,9) perm_stored_h(:,9) (depSetH{8}' - stored_h(:,9)) (depSetH{8}' - perm_stored_h(:,9)) ]);
    if depGroup > 0 % then it is 
        depSet = deps(depGroup,:);
        % clear the zero entries from depSet
        depSet = depSet(1:nnz(depSet)); % nnz() = number of nonzero
        if any(depSet == 0)
            error('depSet not in correct order');
        end
        % update the storedDepH   TODO: check works here!
        depSetH{depGroup} = updateDepH( stored_h(:,nextbestaction), ... 
            nextbestaction, depSet, depSetH{depGroup} );
%disp([depSetH{8}' stored_h(:,9) perm_stored_h(:,9) (depSetH{8}' - stored_h(:,9)) (depSetH{8}' - perm_stored_h(:,9)) ]);

        % update stored_h for actions in dependency set with storedDepH 
        tmpStoredH = pushDepH(depSet,depSetH{depGroup});
%disp([depSetH{8}' stored_h(:,9) perm_stored_h(:,9) (depSetH{8}' - stored_h(:,9)) (depSetH{8}' - perm_stored_h(:,9)) ]);
        old_stored_h = stored_h;
        stored_h(:,depSet) = tmpStoredH;
        if any(abs(old_stored_h(:,nextbestaction) - stored_h(:,nextbestaction)) > 0.000000001)
            disp(iteration);
            disp(abs(old_stored_h - stored_h) > 0.000000001)
            disp(old_stored_h);
            disp(stored_h);
            error('stored_h does not update correctly from depSetH');
        end
    end
%disp([depSetH{8}' stored_h(:,9) perm_stored_h(:,9) (depSetH{8}' - stored_h(:,9)) (depSetH{8}' - perm_stored_h(:,9)) ]);
%disp(stored_h)
% if iteration > 2
%     break;
% end

end % end pursuit iteration, accruing best 20 actions


% prepare output
output = [bestoutput; bestactions; bestactionscore; causaleffect; bestchisquare];
output = output(:,2:end); % drop the fake (initialized) first entry
%disp(output);

if fluctuationBool
    % FLUCTUATION adjust for sampling variability
    output(3,:) = output(3,:) - 1/nExamples;
    output(3,:) = output(3,:) .* (output(3,:) > 0);
%disp(output)
end

%%% DISPLAY DESIRED OUTPUTS %%%

if displayInfoTableBool
    disp('TABLE OF INFO GAINS');
    format_table_of_infos(table_of_info_gains);
end

if displayTEBool
    disp('TABLE OF INFO VS TE');
%     % sort by info, put rank as first row
    TEOutput = sortrows(TEOutput',-1)';
    TEOutput = [1:size(TEOutput,2); TEOutput];
    TEOutput = [TEOutput; abs(TEOutput(3,:))];
    % sort by TE (now in 3rd row)
    lastRow = size(TEOutput,1);
    TEOutput = sortrows(TEOutput',-lastRow)';
    disp(TEOutput(1:4,:));
    
%     TEOutput = [output; 1:size(output,2); abs(output(4,:))];
%     TEOutput = sortrows(TEOutput',-7)';
%     format_TEOutput(TEOutput,10);
    
end

if displayChiSqBool
    disp('TABLE OF INFO VS CHI SQ')
    chiSquareOutput = sortrows(chiSquareOutput',-2)';
    disp(chiSquareOutput);
end

