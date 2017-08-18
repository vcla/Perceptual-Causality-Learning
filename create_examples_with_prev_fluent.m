function [ new_dat ] = create_examples_with_prev_fluent( dat, frameLag, actionLag, intersectBool )
% CREATE_EXAMPLES_WITH_PREV_FLUENT appends the previous fluent value to each 
% line and creates examples for use in pursuit
%
%   Input: 
%       dat = matrix with examples as rows, frame in first column, 
%            current fluent value next (only one fluent), actions following
%       frameLag = number of frames within which to consider an example
%       actionLag = number of action change points within which to consider
%                   an example
%       intersectBool = boolean for whether to take intersection or union
%                   of frameLag and actionLag.  
%       NOTE: if just want one of frameLag or actionLag, enter 0 for the
%       other
%
%   Output:
%       dat = a new version of the input dat that has the previous fluent
%                   value tacked on as a last column and has merged rows to
%                   create examples (collected according to the actionLag 
%                   and frameLag. 


% dat = [1 0 1; 3 1 0; 4 0 1; 10 0 0 ]
% frameLag = 2
% actionLag = 0

% dat = csvread('Exp2_output_data.txt', 1,0);
% %dat = remove_cols(dat, [3, 4, 5]);
% dat = remove_cols(dat, [2, 3, 5]);

% sort rows of dat by time
if ~issorted(dat(:,1))
    dat = sortrows(dat,1);
%     warning('dat is not sorted by times');
end


if all(dat(:,1) < 2)
    disp([frameLag actionLag max(dat(:,1)) min(dat(:,1))])
    error('need frame information in column 1');
end

if (frameLag == 0) && (actionLag == 0)
    error('frameLag and actionLag both zero');
end

nCols = size(dat,2);
inertial_index = nCols + 1;
nActions = nCols - 2; % subtract for frame and fluent

% initialize new_dat to hold examples
new_dat = [];

example_indices = []; % NEW
actions_in_examples = []; % NEW

for index = 2:size(dat,1)

    rowTime = dat(index,1);
    
    % create a place holder to store the working example
    example = zeros(1,inertial_index);
    
    % populate the time, fluent
    example(1) = rowTime;
    example(2) = dat(index,2);
    
    % populate previous fluent.  note: this always comes from previous
    % fluent value (regardless of frame).  if it wasn't, then there would
    % be a change point (and therefore a new row)
    example(end) = dat((index-1),2);
    

    % NEW: check if fluent change.  if fluent change, build example.  if
    % not fluent change, still might need it (if it has the actions from
    % the fluent changes. To do this, we can construct examples, keeping 
    if example(end) ~= example(2) % NEW: then it's a fluent change, mark it
        
%disp(example)

        % pick out the indices that have frame < rowTime within frameLag
        % this returns empty if frameLag is 0
        byFrameInds = ( find(dat(:,1) < rowTime & dat(:,1) >= (rowTime - frameLag)) )';

        % pick out indices that have frame < rowTime and number of action
        % change points within actionLag
        byActionInds = (index - 1):-1:(index - actionLag);
        % only keep ones that are 1 or above (real indices)
        byActionInds = intersect(1:size(dat,1),byActionInds);

        if frameLag > 0 && actionLag > 0 && intersectBool == true  % NEW: simplified this
            byLagInds = intersect(byFrameInds, byActionInds);
        else
            byLagInds = union(byFrameInds, byActionInds);
        end


        % NEW -  stop accruing indices if already in examples (TODO: include in paper)
        if ~isempty(intersect(byLagInds,actions_in_examples))
            byLagInds = setdiff(byLagInds,actions_in_examples);
%             disp([index 0 rowTime 0 byLagInds]);
%             warning('some of the examples were going to overlap');
        end

        if any(dat(byLagInds,1) >= dat(index,1)) % NEW: error checking
            disp([index byLagInds])
            disp([dat(byLagInds,1) dat(index,1)])
            error('byLagInds contains frames higher than the current index');
        end
%disp(byLagInds)
        example_indices = [example_indices index];
        actions_in_examples = [actions_in_examples byLagInds];

        
        % determine if actions happened over those indices
        tmpAction = zeros(1,nActions);
        if ~isempty(byLagInds)
            for tmpIndex = byLagInds
%                 if any(tmpAction & dat(tmpIndex,3:end))
%                     disp([index byLagInds]);
%                     disp(dat(byLagInds,:))
%                     warning('action is counted twice')
%                 end
                tmpAction = (tmpAction | dat(tmpIndex,3:end));
            end

        end

        % keep only the actions
        example(3:(end-1)) = tmpAction;

        % populate the row of dat with the example we just composed
        new_dat = [new_dat; example];
%disp(new_dat)        
    end
    
end

% datsum = sum(dat)
% newdatsum = sum(new_dat)

% disp(dat)
% disp(new_dat)



%%% PART 2 -- INERTIAL EXAMPLES 
% determine which action columns are important (possible causes), set others to 0
causal_actions = setdiff(find(sum(new_dat) > 0), [1 2 size(new_dat,2)]);
non_causal_actions = setdiff(3:size(dat,2), causal_actions);
%dat(:,non_causal_actions) = 0;


% remove all the rows with actions we've put into examples so they can't get recounted
dat(actions_in_examples,3:end) = 0;

% now start at the end.  find nonzero row.  form example by getting inds as
% above, with added condition that the fluent can't change value.  populate
% inertial, and add on to new_dat.
% inertial_indices = setdiff(1:size(dat,1),example_indices);
% inertial_indices = sort(inertial_indices,'descend');
inertial_indices = size(dat,1) : -1 : 1;

for index = inertial_indices
    if any(dat(index,3:end) > 0)
        
%disp('%%%')
%disp(index)
        fluent = dat(index,2);
        rowTime = dat(index,1);

        byFrameInds = ( find(dat(:,1) <= rowTime & dat(:,1) > (rowTime - frameLag)) )';

        byActionInds = (index):-1:(index - actionLag + 1);
        byActionInds = intersect(1:size(dat,1),byActionInds);

        if frameLag > 0 && actionLag > 0 && intersectBool == true  
            byLagInds = intersect(byFrameInds, byActionInds);
        else
            byLagInds = union(byFrameInds, byActionInds);
        end
        
%disp(byLagInds)

        % make sure byLagInds also have same fluent value
        fluentFail = 0;
        for tmp = sort(byLagInds,'descend')
            if dat(tmp,2) ~= fluent
                fluentFail = tmp;
                break;
            end
        end
        
        if ~isempty(byLagInds)
            byLagInds = byLagInds(byLagInds > fluentFail);
        end
        
%disp(byLagInds)
        

        % determine if actions happened over those indices
        tmpAction = zeros(1,nActions);
        if ~isempty(byLagInds)
            for tmpIndex = byLagInds
%                 if any(tmpAction & dat(tmpIndex,3:end))
%                     disp([index byLagInds]);
%                     disp(dat(byLagInds,:))
%                     warning('action is counted twice')
%                 end
                tmpAction = (tmpAction | dat(tmpIndex,3:end));
            end

        end

        % add the inertial example on
        new_dat = [new_dat; rowTime fluent tmpAction fluent];
        
        % set the used action rows to 0
        dat(byLagInds,3:end) = 0;
        
        if any(sum(dat(index:end,3:end)) > 0)
            error('some of dat has not been zeroed out');
        end
    
    end
   
    
end
%disp(new_dat)
%new_dat(:,non_causal_actions) = 0;
% datsum
% sum(new_dat)

% asdf


% delete row without an example (first row)
% new_dat(1,:) = [];
% dat
% new_dat
% assdf

% delete frame information
new_dat(:,1) = [];
