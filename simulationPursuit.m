function [model] = simulationPursuit(dat, nIterations, fluctuationBool)
% first: use pursuit.m to find the number of causes you need
% then use this to return the model
%
%
%   input:
%       dat     Rows: examples
%               Columns: actions (1 if action occurred in example, 0 o/w)
%               First column: fluent value at t
%               Last column: inertial value (fluent value at t-1)
%
%
%   Output:
%       Row 1: Output type for selected causal relation
%       Row 2: Action for selected causal relation
%       Row 3: Info gain for selected causal relation
%       Row 4: TE for selected causal relation
%       Row 5: Chi-Square for selected causal relation


%%% INITIALIZATIONS %%%

deps = []; % cannot handle dependent sets here (todo later)
outputTypes = 3; % cannot handle others (todo later)

% FLUCTUATION
if fluctuationBool
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

%disp(stored_h)

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

        % examine each action with each output type
        for actionindex = 2:(size(dat,2)-1) % minus one to not count "inertial"
            
            % make sure we don't repeat an action/output type combo
            tmpind = find(bestactions == actionindex);
            if ~any(bestoutput(tmpind) == outputtype) 
                % then the action/output is not already included
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
    causaleffect = [causaleffect (f(4)/(f(4)+f(2)) - f(3)/(f(3)+f(1)))];
    
    % calculate the chi square for the best causal relation 
    tmpf = tabulate(dat,[1 inertial_index nextbestaction]);
    tmpf = f * sum(tmpf);
    bestchisquare = [bestchisquare chiSquare([tmpf(1:2); tmpf(3:4)])];

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

%disp(stored_h)

end % end pursuit iteration, accruing best 20 actions


% prepare output
output = [bestoutput; bestactions; bestactionscore; causaleffect; bestchisquare];
output = output(:,2:end); % drop the fake (initialized) first entry
%disp(output);

if fluctuationBool
    % FLUCTUATION adjust for sampling variability
    output(3,:) = output(3,:) - 1/nExamples;
    output(3,:) = output(3,:) .* (output(3,:) > 0);
end

%disp(output)

% prepare model to return
model = tabulate(dat,[1 size(dat,2)]); 
model = model / sum(model);
for i = 1:nIterations
    % get action (todo later -- get fluent change too)
    action = output(2,i);
    
    tmpModelValues = stored_h(:,action);
%disp(tmpModelValues')
    
    oldModel = model;
    
    model = zeros(1,numel(oldModel)*2);
    
    for j = 1:(numel(oldModel)/4)
        model(2*j-1) = oldModel(j) * tmpModelValues(1) / (tmpModelValues(1) + tmpModelValues(2));
        model(2*j) = oldModel(j) * tmpModelValues(2) / (tmpModelValues(1) + tmpModelValues(2));
    %    j
    end

    for j = (numel(oldModel)/4 + 1):(2*numel(oldModel)/4)
        model(2*j-1) = oldModel(j) * tmpModelValues(3) / (tmpModelValues(3) + tmpModelValues(4));
        model(2*j) = oldModel(j) * tmpModelValues(4) / (tmpModelValues(3) + tmpModelValues(4));
   %     j
    end

    for j = (2*numel(oldModel)/4 + 1):(3*numel(oldModel)/4)
        model(2*j-1) = oldModel(j) * tmpModelValues(5) / (tmpModelValues(5) + tmpModelValues(6));
        model(2*j) = oldModel(j) * tmpModelValues(6) / (tmpModelValues(5) + tmpModelValues(6));
  %      j
    end
    
    for j = (3*numel(oldModel)/4 + 1):(4*numel(oldModel)/4)
        model(2*j-1) = oldModel(j) * tmpModelValues(7) / (tmpModelValues(7) + tmpModelValues(8));
        model(2*j) = oldModel(j) * tmpModelValues(8) / (tmpModelValues(7) + tmpModelValues(8));
 %       j
    end
    
%    model
    
    
end
