% THIS FILE PRODUCES ALL OUTPUT FOR THE ACM TIST PAPER

% NOTE: pause waits for adjustment of legend before saving image. :)

clear all; 
close all;

saveImageBool = false;
    % if true, saves images to folder images/



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% BEGIN EXPERIMENT: MULTIPLE FLUENTS BEST TIME %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DOOR = 1;
MONITOR = 2;
LIGHT = 3;
colors = 'bgrcmk';
legend_text = {};

actionLag = 1;
frameLag = 103;

perm_dat = csvread('data/Exp2_output_data.txt', 1,0);
multiple_fluents_best_time(perm_dat, saveImageBool)
pause;


% This function randomly flips actions
% cols 6-end = actions
multiple_fluents_best_time_increasing_randomness(perm_dat, saveImageBool)


% % randomly flipping fluents does terribly.  i think this is because i'm
% % flipping values, not fluent changes.
% flipProb = .3;
% rand_dat = perm_dat;
% %rand_dat= [perm_dat; perm_dat; perm_dat; perm_dat];
% %rand_dat2 = rand_dat;
% % cols 2-4 = fluents
% rand_matrix = rand(size(rand_dat,1),3);
% rand_dat(:,2:4) = abs(rand_dat(:,2:4) - (rand_matrix < flipProb));
% % cols 6-5 = actions
% multiple_fluents_best_time(rand_dat, saveImageBool)


pause;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% END EXPERIMENT: MULTIPLE FLUENTS BEST TIME %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% BEGIN EXPERIMENT: CHANGING TIMES (FRAMES) %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DOOR = 1;
MONITOR = 2;
LIGHT = 3;
colors = 'bgrcmk';
counter = 1;
frameLag = 0;
actionLag = 0;
legend_text = {};

% create figures for storing ROC curves
fig_all = figure();
%fig_door = figure();
fig_monitor = figure();
%fig_light = figure();

secondsLags = 15:15:90;
for frameLag = (secondsLags * 2.3);
% for frameLag = 50:50:250    
%for actionLag = [1 5 10]
    for testcase = [DOOR MONITOR LIGHT]
        % inertial_index = 13;

        dat = csvread('data/Exp2_output_data.txt', 1,0);

        if testcase == DOOR
            %%% Experiment: DOOR
            casetext = 'Door';
            % remove the columns 3(monitor), 4 (light), 5(agent)
            dat = remove_cols(dat, [3, 4, 5]);

        elseif testcase == MONITOR
            %%% Experiment: MONITOR
            casetext = 'Monitor';
            % remove the columns 2(door), 4 (light), 5(agent)
            dat = remove_cols(dat, [2, 4, 5]);

        elseif testcase == LIGHT
            %%% Experiment: LIGHT
            casetext = 'Light';
            % remove the columns 2(door_status), 3(monitor), 5(agent)
            dat = remove_cols(dat, [2, 3, 5]);

        else
            error('TEST CASE wrong for 1st round');
        end

        % add previous fluent value to the end of dat, remove frame information
        dat = add_inertial2(dat,frameLag, actionLag); % 0 frameLag, 1 actionLag

        accumulate_output = pursuit(dat,false,false,false, true,(2:12)',44, [2:3]); 
        accumulate_output = [testcase*ones(1,size(accumulate_output,2)); accumulate_output];

        % keep only the causal effect examining here (remove second one)
        accumulate_output(end,:) = [];

        % add on the answers
        inertial_index = 13;
        accumulate_output = [answers(accumulate_output(1:4,:),inertial_index); accumulate_output(5,:)];

        if testcase == MONITOR
            monitor_output = accumulate_output;
            fig_id = fig_monitor;
            plotROC(accumulate_output(5,:),colors(counter),fig_id, (counter-2)*.005*20, (counter-2)*.005*4);
            title(casetext)

        elseif testcase == LIGHT
            light_output = accumulate_output;
            %fig_id = fig_light;
        elseif testcase == DOOR
            door_output = accumulate_output;
            %fig_id = fig_door;
        else
            error('invalid test case');
        end


    end

    % combine all the fluents - sort the accumulated output by the KL divergence
    sorted = sort_multiple_fluents(light_output, monitor_output, door_output, 4);
    
    % lose monitor
    monitor_sorted_inds = find(sorted(1,:) == 2);
    sorted(:,monitor_sorted_inds) = [];

    plotROC(sorted(5,:), colors(counter),fig_all,(counter-2)*.005*40, (counter-2)*.005*6);
    title('Door and Light Fluents Together', 'FontSize',18);
    
    if frameLag ~= 0
        legend_text{counter} = [int2str(frameLag/2.3) ' seconds'];
    elseif actionLag ~= 0
        if actionLag == 1
            action_text = ' action';
        else
            action_text = ' actions';
        end
        legend_text{counter} = [int2str(actionLag) action_text];
    else 
        error('wrong variable name')
    end
    
    counter = counter + 1;
    
end

legend(legend_text, 'Location', 'Best','FontSize',20);
axis([-2 40 -0.1 6.2])
set(gcf, 'PaperPositionMode', 'auto');
if saveImageBool
    pause; print -dpng images\frame_all; 
end


figure(fig_monitor);
legend(legend_text, 'Location', 'Best','FontSize',20);
axis([-1 20 -0.1 4.1])
set(gcf, 'PaperPositionMode', 'auto');
if saveImageBool
    pause; print -dpng images\frame_monitor
end

disp('%%%%%%%%%%%%%% END EXPERIMENT: CHANGING TIMES (FRAMES) %%%%%%%%%%%%%%%%%%%%')
pause;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% END EXPERIMENT: CHANGING TIMES (FRAMES) %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% BEGIN EXPERIMENT: CHANGING ACTION CHANGE POINTS %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DOOR = 1;
MONITOR = 2;
LIGHT = 3;
colors = 'bgrcmk';
counter = 1;
frameLag = 0;
actionLag = 0;
legend_text = {};

% create figures for storing ROC curves
fig_all = figure();
%fig_door = figure();
fig_monitor = figure();
%fig_light = figure();


for actionLag = 1:6
    for testcase = [DOOR MONITOR LIGHT]
        % inertial_index = 13;

        dat = csvread('data/Exp2_output_data.txt', 1,0);

        if testcase == DOOR
            %%% Experiment: DOOR
            casetext = 'Door';
            % remove the columns 3(monitor), 4 (light), 5(agent)
            dat = remove_cols(dat, [3, 4, 5]);

        elseif testcase == MONITOR
            %%% Experiment: MONITOR
            casetext = 'Monitor';
            % remove the columns 2(door), 4 (light), 5(agent)
            dat = remove_cols(dat, [2, 4, 5]);

        elseif testcase == LIGHT
            %%% Experiment: LIGHT
            casetext = 'Light';
            % remove the columns 2(door_status), 3(monitor), 5(agent)
            dat = remove_cols(dat, [2, 3, 5]);

        else
            error('TEST CASE wrong for 1st round');
        end

        % add previous fluent value to the end of dat, remove frame information
        dat = add_inertial2(dat,frameLag, actionLag); % 0 frameLag, 1 actionLag

        accumulate_output = pursuit(dat,false,false,false,true,(2:12)',44, [2:3]);  
        accumulate_output = [testcase*ones(1,size(accumulate_output,2)); accumulate_output];

        % keep only the causal effect examining here (remove second one)
        accumulate_output(end,:) = [];

        % add on the answers
        inertial_index = 13;
        accumulate_output = [answers(accumulate_output(1:4,:),inertial_index); accumulate_output(5,:)];

        if testcase == MONITOR
            monitor_output = accumulate_output;
            fig_id = fig_monitor;
            plotROC(accumulate_output(5,:),colors(counter),fig_id, (counter-2)*.005*20, (counter-2)*.005*4);
            title(casetext)
        elseif testcase == LIGHT
            light_output = accumulate_output;
            %fig_id = fig_light;
        elseif testcase == DOOR
            door_output = accumulate_output;
            %fig_id = fig_door;
        else
            error('invalid test case');
        end

 
    end

    % combine all the fluents - sort the accumulated output by the KL divergence
    sorted = sort_multiple_fluents(light_output, monitor_output, door_output, 4);
    
    % lose monitor
    monitor_sorted_inds = find(sorted(1,:) == 2);
    sorted(:,monitor_sorted_inds) = [];

    plotROC(sorted(5,:), colors(counter),fig_all, (counter-2)*.005*40, (counter-2)*.005*6);
    title('Door and Light Fluents Together');
    
    if actionLag ~= 0
        if actionLag == 1
            action_text = ' action';
        else
            action_text = ' actions';
        end
        legend_text{counter} = [int2str(actionLag) action_text];
    else 
        error('wrong variable name')
    end
    
    counter = counter + 1;
    
end

legend(legend_text, 'Location', 'Best','FontSize',20);
axis([-2 40 -0.1 6.2])
set(gcf, 'PaperPositionMode', 'auto');
if saveImageBool
    pause; print -dpng images\action_all
end


figure(fig_monitor);
legend(legend_text, 'Location', 'Best','FontSize',20);
axis([-1 20 -0.1 4.1])
set(gcf, 'PaperPositionMode', 'auto');
if saveImageBool
    pause; print -dpng images\action_monitor
end

disp('%%%%%%%%%%%%%% END EXPERIMENT: CHANGING ACTION CHANGE POINTS %%%%%%%%%%%%%%');
pause;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% END EXPERIMENT: CHANGING ACTION CHANGE POINTS %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% BEGIN EXPERIMENT: CHANGING ACTIONS AND FRAMES (INTERSECTION) %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DOOR = 1;
MONITOR = 2;
LIGHT = 3;
colors = 'bgrcmk';
counter = 1;
legend_text = {};

% create figures for storing ROC curves
fig_all = figure();
% fig_door = figure();
% fig_monitor = figure();
% fig_light = figure();

secondsLag = [15 45];
 for frameLag = [35 103]
     for actionLag = 1:3
%for frameLag = 50:50:150
%    for actionLag = 1:2
%figure();
%i = 1;
        for testcase = [DOOR MONITOR LIGHT]
            % inertial_index = 13;

            dat = csvread('data/Exp2_output_data.txt', 1,0);

            if testcase == DOOR
                %%% Experiment: DOOR
                casetext = 'Door';
                % remove the columns 3(monitor), 4 (light), 5(agent)
                dat = remove_cols(dat, [3, 4, 5]);

            elseif testcase == MONITOR
                %%% Experiment: MONITOR
                casetext = 'Monitor';
                % remove the columns 2(door), 4 (light), 5(agent)
                dat = remove_cols(dat, [2, 4, 5]);

            elseif testcase == LIGHT
                %%% Experiment: LIGHT
                casetext = 'Light';
                % remove the columns 2(door_status), 3(monitor), 5(agent)
                dat = remove_cols(dat, [2, 3, 5]);

            else
                error('TEST CASE wrong for 1st round');
            end

            % add previous fluent value to the end of dat, remove frame information
            dat = add_inertial2(dat,frameLag, actionLag, true); % true for intersection of frames

            accumulate_output = pursuit(dat,false,false,false,true,(2:12)',44,[2:3]);  
            accumulate_output = [testcase*ones(1,size(accumulate_output,2)); accumulate_output];

            % keep only the causal effect examining here (remove second one)
            accumulate_output(end,:) = [];

            % add on the answers
            inertial_index = 13;
            accumulate_output = [answers(accumulate_output(1:4,:),inertial_index); accumulate_output(5,:)];

            if testcase == MONITOR
                monitor_output = accumulate_output;
                %fig_id = fig_monitor;
            elseif testcase == LIGHT
                light_output = accumulate_output;
                %fig_id = fig_light;
            elseif testcase == DOOR
                door_output = accumulate_output;
                %fig_id = fig_door;
            else
                error('invalid test case');
            end
%plot_output(accumulate_output, casetext)

        end


        % combine all the fluents - sort the accumulated output by the KL divergence
        sorted = sort_multiple_fluents(light_output, monitor_output, door_output, 4);
%plot_output(sorted,'All Fluents')

        plotROC(sorted(5,:), colors(counter),fig_all,(counter-2)*.005*40, (counter-2)*.005*6);
        title('Multiple Fluents: Change Time and Action (Intersection)');

        legend_text{counter} = ['min(' int2str(frameLag / 2.3) ' seconds, '];
        legend_text{counter} = [legend_text{counter} int2str(actionLag) ' actions)'];
%title(legend_text{counter})
        counter = counter + 1;
        
    end

 end

legend(legend_text, 'Location', 'Best','FontSize',18);
axis([-3 60 -0.1 10.3])
set(gcf, 'PaperPositionMode', 'auto');
if saveImageBool
    pause; print -dpng images\action_frame_intersection
end

disp('%%%%%%%%%% END EXPERIMENT: CHANGING ACTIONS AND FRAMES (INTERSECTION) %%%%%');
pause;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% END EXPERIMENT: CHANGING ACTIONS AND FRAMES (INTERSECTION) %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% BEGIN EXPERIMENT: CHANGING ACTIONS AND FRAMES (UNION) %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DOOR = 1;
MONITOR = 2;
LIGHT = 3;
colors = 'bgrcmk';
counter = 1;
legend_text = {};

% create figures for storing ROC curves
fig_all = figure();
% fig_door = figure();
% fig_monitor = figure();
% fig_light = figure();


for frameLag = [35 103]
    for actionLag = 1:3

        for testcase = [DOOR MONITOR LIGHT]
            % inertial_index = 13;

            dat = csvread('data/Exp2_output_data.txt', 1,0);

            if testcase == DOOR
                %%% Experiment: DOOR
                casetext = 'Door';
                % remove the columns 3(monitor), 4 (light), 5(agent)
                dat = remove_cols(dat, [3, 4, 5]);

            elseif testcase == MONITOR
                %%% Experiment: MONITOR
                casetext = 'Monitor';
                % remove the columns 2(door), 4 (light), 5(agent)
                dat = remove_cols(dat, [2, 4, 5]);

            elseif testcase == LIGHT
                %%% Experiment: LIGHT
                casetext = 'Light';
                % remove the columns 2(door_status), 3(monitor), 5(agent)
                dat = remove_cols(dat, [2, 3, 5]);

            else
                error('TEST CASE wrong for 1st round');
            end

            % add previous fluent value to the end of dat, remove frame information
            dat = add_inertial2(dat,frameLag, actionLag, false); % false for union of frames

            accumulate_output = pursuit(dat,false,false,false,true,(2:12)',44,[2:3]);  
            accumulate_output = [testcase*ones(1,size(accumulate_output,2)); accumulate_output];

            % keep only the causal effect examining here (remove second one)
            accumulate_output(end,:) = [];

            % add on the answers
            inertial_index = 13;
            accumulate_output = [answers(accumulate_output(1:4,:),inertial_index); accumulate_output(5,:)];

            if testcase == MONITOR
                monitor_output = accumulate_output;
                %fig_id = fig_monitor;
            elseif testcase == LIGHT
                light_output = accumulate_output;
                %fig_id = fig_light;
            elseif testcase == DOOR
                door_output = accumulate_output;
                %fig_id = fig_door;
            else
                error('invalid test case');
            end

        end

        % combine all the fluents - sort the accumulated output by the KL divergence
        sorted = sort_multiple_fluents(light_output, monitor_output, door_output, 4);
        plotROC(sorted(5,:), colors(counter),fig_all,(counter-2)*.005*40, (counter-2)*.005*6);
        title('Multiple Fluents: Change Time and Action (Union)');

        legend_text{counter} = ['max(' int2str(frameLag/2.3) ' seconds, '];
        legend_text{counter} = [legend_text{counter} int2str(actionLag) ' actions)'];


% plot_output(sorted,'All Fluents')
% title(legend_text{counter})

        counter = counter + 1;
        
    end


end

% display what we have
legend(legend_text, 'Location', 'Best','FontSize',18);  
axis([-3 50 -0.1 10.3])
set(gcf, 'PaperPositionMode', 'auto');
if saveImageBool
    pause; print -dpng images\action_frame_union
end

disp('%%%%%%%%%% END EXPERIMENT: CHANGING ACTIONS AND FRAMES (UNION) %%%%%%%%%%%%');
pause;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% END EXPERIMENT: CHANGING ACTIONS AND FRAMES (UNION) %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%













%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% BEGIN EXPERIMENT: CHANGING NUMBER OF EXAMPLES %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DOOR = 1;
colors = 'bgrcmk';
counter = 1;
legend_text = {};

% create figures for storing ROC curves
fig_all = figure();

actionLag = 0;
frameLag = 103;

dat = csvread('data/Exp2_output_data.txt', 1,0);

casetext = 'Door';
% remove the columns 3(monitor), 4 (light), 5(agent)
dat = remove_cols(dat, [3, 4, 5]);

% add previous fluent value to the end of dat, remove frame information
dat = add_inertial2(dat,frameLag, actionLag); % 0 frameLag, 1 actionLag
perm_dat = dat;

for nExamples = 5:5:30

    dat = perm_dat;
    
    % cut the number of examples
    tmp = randperm(size(dat,1));
    inds = find(tmp <= nExamples);
    
    dat = dat(inds,:);

    accumulate_output = pursuit(dat,false,false,false,true,(2:12)',44,[2:3]);  
    accumulate_output = [DOOR*ones(1,size(accumulate_output,2)); accumulate_output];

    % keep only the causal effect examining here (remove second one)
    accumulate_output(end,:) = [];

    % add on the answers
    inertial_index = 13;
    accumulate_output = [answers(accumulate_output(1:4,:),inertial_index); accumulate_output(5,:)];

    plotROC(accumulate_output(5,:),colors(counter),fig_all,(counter-2)*.005*14, (counter-2)*.005*4);
    title('Door, Changing Number of Examples')
    
    legend_text{counter} = [int2str(nExamples) ' Examples'];

    counter = counter + 1;
    
end

axis([-1 14 -0.1 4.1])
legend(legend_text, 'Location', 'Best','FontSize',18);
set(gcf, 'PaperPositionMode', 'auto');
if saveImageBool
    pause; print -dpng images\door_changing_examples
end

disp('%%%%%%%%%%%%%% END EXPERIMENT: CHANGING NUMBER OF EXAMPLES %%%%%%%%%%%%%%%%');
pause;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% END EXPERIMENT: CHANGING NUMBER OF EXAMPLES %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%















% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%% BEGIN EXPERIMENT: LIGHT WITH PRECONDITION %%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% %%% LIGHT: PRECONDITION OF OFF (LIGHT)
% actionLag = 1;
% frameLag = 30;
% 
% dat = csvread('data/Exp2_output_data.txt', 1,0);
% % remove the columns 1(frame), 2(door_status), 3(monitor), 5(agent)
% dat = remove_cols(dat, [2, 3, 5]);
% dat = [dat ((dat(:,2)==1) & dat(:,10)) ((dat(:,2)==0) & dat(:,10))]; %inertial_index = 15; % should 15 be in deps too?
% dat = add_inertial2(dat,frameLag, actionLag,true); % using intersection
% dat = dat_by_fluent_change(dat,'10');
% calc_info(dat);
% 
% disp('%%%%%%%%%%%%%%%%%%%');
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%% END EXPERIMENT: LIGHT WITH PRECONDITION %%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% BEGIN EXPERIMENT: HIERARCHICAL DOOR (KEY, UNLOCK, FORCE IN) %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

EXP1_DOOR = 4;
LOCK = 5;
WITHOUTLOCK = 6;
WITHDEPS = 7;
WITHOUTDEPS = 8;
% outputindex = 5;
% outputtype = 'First Fit';
testcase = EXP1_DOOR;

frameLag = 60;
actionLag = 1;

for data_used = [LOCK]%, WITHOUTLOCK]
    for deps_used = [WITHDEPS]%, WITHOUTDEPS]
        
        accumulate_output = [];
        dat = [];
        dat = csvread('data/Exp1_output_data_key.txt', 1,0);  % key lock
        dat = [dat; csvread('data/Exp1_output_data3.txt',1,0)]; % pass code lock
            
        dat1 = csvread('data/Exp1_output_data_key.txt', 1,0);  % key lock
        dat1 = prepare_exp1_dat(dat1);
        dat1 = remove_cols(dat1, [3]);
        dat1 = add_inertial2(dat1,frameLag, actionLag,false); % true for using intersection


        dat2 = csvread('data/Exp1_output_data3.txt',1,0); % pass code lock
        dat2 = prepare_exp1_dat(dat2);
        dat2 = remove_cols(dat2, [3]);
        dat2 = add_inertial2(dat2,frameLag, actionLag,false); % true for using intersection

        if data_used == WITHOUTLOCK
            dat3 = csvread('data/Exp1_output_data2.txt',1,0); %door no lock
            dat3 = prepare_exp1_dat(dat3);
            dat3 = remove_cols(dat3, [3]);
            dat3 = add_inertial2(dat3,frameLag, actionLag,false); % true for using intersection

            dat = [dat1; dat2; dat3];
            title_text = 'Without lock';
        elseif data_used == LOCK
            dat = [dat1; dat2];
            title_text = 'Locking doors only';
        end

         exp1_inertial = size(dat,2);
        % data2 has 2's.  squash everything to 1's.
        dat = int8(logical(dat)); 
        dat = double(dat);

        if deps_used == WITHDEPS
            % dep sets action [2 5 0; 3 4 6]
            %deps = [3 6 9 0 0; 2 4 5 7 10];
            deps = [3 6 9 0; 4 5 7 10];  % changed 12/14/2011
            title_text = [title_text, ', with dependent sets'];
        elseif deps_used == WITHOUTDEPS
            deps = [];
            title_text = [title_text, ', without dependent sets'];
        end

        accumulate_output = pursuit(dat,false,false,false,true,deps,20,[3]);
        %accumulate_output = [accumulate_output pursuit(dat,false,false,false,true,[],[2:3])];
        accumulate_output = [testcase*ones(1,size(accumulate_output,2)); accumulate_output];

        % add on the answers
        inertial_index = exp1_inertial;
        accumulate_output = [answers(accumulate_output(1:4,:),inertial_index); accumulate_output(5:6,:)];

        [sorted_vals index_sorts] = sort(accumulate_output(7,:),'descend');
        
        % return latex formatted table
        disp([ '%%%%%%%%%%%%%%%%%%% ' title_text ' %%%%%%%%%%%%%%%%%%%']);
        format_latex(accumulate_output,min(6,size(accumulate_output,2)));
        disp(['\\']);
        rank_display = ['Rank of $\chi^2$ '];
        for tmpInd = 1:min(6,size(accumulate_output,2))
            rank_display = [rank_display ' & ' int2str(index_sorts(tmpInd))];
        end
        disp(rank_display);
        disp('%%%%%%%%%%%%%%%%%%%');        

    end
end


plot_output(accumulate_output(1:5,:),'Learning Pursuit')
pause;


accumulate_output(4,:) = accumulate_output(end,:)
a = accumulate_output(1:5,:); a = a';
[b ind] = sort(a,1,'descend');
a = sortrows(a,-4);
plot_output(a','Chi-Square')
ylabel('Chi-Square')
pause;


disp('%%%%%%%%%%% END EXPERIMENT: HIERARCHICAL DOOR (KEY, UNLOCK, FORCE IN) %%%%%');
pause;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% END EXPERIMENT: HIERARCHICAL DOOR (KEY, UNLOCK, FORCE IN) %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%










%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% BEGIN EXPERIMENT: ELEVATOR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% NOTE: 1/30/2013 -- changed causaleffect variable to Causal Power
%%% calculation for submission to Cog Sci Conference

%clear all;

ELEVATOR = 5;
testcase = ELEVATOR;

counter = 0;
correct_combos_info = [];
correct_combos_chi = 0;
correct_combos_TE = 0;
tmp_correct_combos_info = 0;

perm_dat = prepElevDat('elevator.csv', false);
%     'enter1'    'enter2'    'exit1'    'exit2'    'onphone'   'pickup'    'pushbutton'    'readpaper'    'walkby'    'walkedaway'    'enter'    'exit'
perm_dat = remove_cols(perm_dat, [4 5 6 7]); % drop separate enters/exits
perm_dat = remove_cols(perm_dat, 3); % drop agent number

%perm_dat = perm_dat(100:end,:);

tmp_store_correct = [];

for frameLag = (0):(5*2.3):(300*2.3)
%for frameLag = (30*2.3):(15*2.3):(500*2.3)  % this give perfect detection!
%for frameLag = 50:50:500
    for actionLag = 1:8
        dat = perm_dat;
        dat = add_inertial2(dat, frameLag, actionLag, false);
        inertial_index = size(dat,2);
        accumulate_output = pursuit(dat,false,false,false,true,[],48,[3]);  % can get perfect by only looking at 3
        accumulate_output = [testcase*ones(1,size(accumulate_output,2)); accumulate_output];
        accumulate_output = [answers(accumulate_output(1:4,:),inertial_index); accumulate_output(5:6,:)];
        
        if accumulate_output(5,1) == 1
            % then we have found a time that works
            correct_combos_info = [correct_combos_info; frameLag actionLag accumulate_output(6,1)];
        end
        
        tmpInds1 = find(accumulate_output(5,:) == 1);

        tmp_correct_combos_info = tmp_correct_combos_info  + isCorrect(tmpInds1,accumulate_output,4);        
        if tmp_correct_combos_info ~= size(correct_combos_info,1)
            error('info');
        end
        
        correct_combos_chi = correct_combos_chi  + isCorrect(tmpInds1,accumulate_output,7);
        correct_combos_TE = correct_combos_TE  + isCorrect(tmpInds1,accumulate_output,6);
        
%         if isCorrect(tmpInds1,accumulate_output,7) ~= isCorrect(tmpInds1,accumulate_output,4)
%             accumulate_output
%             tabulate(dat,[1 10 4])
%             tabulate(dat,[1 10 5])
%             disp([frameLag actionLag])
%             correct_combos_info(end,:)
%             if frameLag == 517.5 && actionLag == 8
%                 error()
%             end
%         end

        % if we're right, but TE is wrong
        if isCorrect(tmpInds1,accumulate_output,4) && ~isCorrect(tmpInds1,accumulate_output,6)
            c = tabulate(dat,[1 10 4]); 
            if (c(2)+c(4)+c(8)) == 3 && c(6) == 16
                tmp_store_correct = [tmp_store_correct; frameLag actionLag (c(1)+c(3)+c(7)) c(5) (c(2)+c(4)+c(8)) c(6)];
            end
        end
        
        counter = counter + 1;
    end
end

disp('%%%%%% COMPARISON AGAINST TE %%%%%%%%%');

disp(['There were ' int2str(size(correct_combos_info,1)) ' of ' int2str(counter) ' combinations that got the elevator right (union)'])
disp([ 'TE: ' int2str(correct_combos_TE)]);
disp(['Chi: ' int2str(correct_combos_chi)]);
%disp(correct_combos);

disp('Combo & Info Gain & TE \\')
disp('\hline')
disp(['Max & \textbf{' num2str( size(correct_combos_info,1)/counter*100, '%.2f') '\%} & ' ...
    num2str( correct_combos_TE/counter*100, '%.2f') '\% \\'])


counter = 0;
correct_combos_info = [];
correct_combos_chi =0;
correct_combos_TE = 0;
tmp_correct_combos_info = 0;

for frameLag = (0):(5*2.3):(300*2.3)
%for frameLag = 50:50:500
    for actionLag = 1:8
        dat = perm_dat;
        dat = add_inertial2(dat, frameLag, actionLag, true);
        inertial_index = size(dat,2);
        accumulate_output = pursuit(dat,false,false,false,true,[],48,3);  
        accumulate_output = [testcase*ones(1,size(accumulate_output,2)); accumulate_output];
        accumulate_output = [answers(accumulate_output(1:4,:),inertial_index); accumulate_output(5:6,:)];
        
        if accumulate_output(5,1) == 1
            % then we have found a time that works
            correct_combos_info = [correct_combos_info; frameLag actionLag accumulate_output(6,1)];
        end
        
        tmpInds1 = find(accumulate_output(5,:) == 1);

        tmp_correct_combos_info = tmp_correct_combos_info  + isCorrect(tmpInds1,accumulate_output,4);        
        if tmp_correct_combos_info ~= size(correct_combos_info,1)
            error('info');
        end
        
        correct_combos_chi = correct_combos_chi  + isCorrect(tmpInds1,accumulate_output,7);
        correct_combos_TE = correct_combos_TE  + isCorrect(tmpInds1,accumulate_output,6);

        if isCorrect(tmpInds1,accumulate_output,4) && ~isCorrect(tmpInds1,accumulate_output,6)
            c = tabulate(dat,[1 10 4]); 
            if (c(2)+c(4)+c(8)) == 3 && c(6) == 16
                tmp_store_correct = [tmp_store_correct; frameLag actionLag (c(1)+c(3)+c(7)) c(5) (c(2)+c(4)+c(8)) c(6)];
            end
        end
        
        counter = counter + 1;
    end
end

disp(['Min & \textbf{' num2str( size(correct_combos_info,1)/counter*100, '%.2f') '\%} & ' ...
    num2str( correct_combos_TE/counter*100, '%.2f') '\% \\'])

disp(['There were ' int2str(size(correct_combos_info,1)) ' of ' int2str(counter) ' combinations that got the elevator right (intersection)'])
disp([ 'TE: ' int2str(correct_combos_TE)]);
disp(['Chi: ' int2str(correct_combos_chi)]);


%disp(correct_combos);

% There were 13 of 265 combinations that got the elevator right
% (intersection)
%
% There were 156 of 265 combinations that got the elevator right
% (union)


disp('%%%%%%%% CHANGE BELOW: GREY THE CELL WITH CORRECT DETECTION, DELETE CHI SQUARE ROW %%%%%%%%%');

frameLag = 149.5; %57.5
actionLag = 1; %5
dat = perm_dat;
dat = add_inertial2(dat, frameLag, actionLag, false);
inertial_index = size(dat,2);
accumulate_output = pursuit(dat,false,false,false,true,[],48,[3]);  
accumulate_output = [testcase*ones(1,size(accumulate_output,2)); accumulate_output];
accumulate_output = [answers(accumulate_output(1:4,:),inertial_index); accumulate_output(5:6,:)];

format_latex(accumulate_output,min(6,size(accumulate_output,2)));
[sorted_TE sorted_TE_order] = sort(accumulate_output(6,:),'descend');

disp(['\\']);
rank_display = ['Rank of TE & '];
for tmpInd = 1:min(6,size(accumulate_output,2))
    rank_display = [rank_display ' & ' int2str(sorted_TE_order(tmpInd))];
end
disp(rank_display)

        
c = tabulate(dat,[1 10 4]); [(c(1)+c(3)+c(7)) c(5); (c(2)+c(4)+c(8)) c(6)]
c = tabulate(dat,[1 10 7]); [(c(1)+c(3)+c(7)) c(5); (c(2)+c(4)+c(8)) c(6)]



plot_output(accumulate_output(1:5,:),'Learning Pursuit')
pause;


accumulate_output(4,:) = accumulate_output((end-1),:)
a = accumulate_output(1:5,:); a = a';
[b ind] = sort(a,1,'descend');
a = sortrows(a,-4);
%plot_output(a','Total Effect (TE)')
%ylabel('Total Effect (TE)')
%axis([0 7 -0.1 .65])
plot_output(a','Causal Power') % THIS IS CHANGED IN PURSUIT.M...  variable causaleffect
ylabel('Causal Power')
axis([0 7 -0.1 1.1]) % note: if doing causal power, need to make the bound higher
pause;

disp('%%%%%%%%%%%%% END EXPERIMENT: ELEVATOR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
pause;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% END EXPERIMENT: ELEVATOR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%











%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% BEGIN EXPERIMENT: SIMULATED VENDING %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NOTE: fluctuation...  when incorporating fluctuation, the graphs come out
% wrong...  it's sort of an issue of ranking when the guys don't even
% finish the race.  have fluctuation turned off so that these guys are ok.

%clear all;

VENDING_1 = 6; % 1 snack

nExamples = 30;
nSnacks = 1; % only 1 fluent
nConfusion = 10;
dat = synthesizeDat(nExamples, nSnacks, nConfusion);

actionLag = 0;
frameLag = 150;

% remove unnecessary fluents
% add previous fluent value to the end of dat, remove frame information
perm_dat = add_inertial2(dat,frameLag, actionLag,true); % using intersection

% create interactions for confusions
dat = perm_dat;
for i = 1:nConfusion
    for j = 1:i
        dat = [dat (dat(:,i+10) & dat(:,j+10))];
    end
end
accumulate_output = pursuit(dat,false,false,false,false,[],13,[3])

% ignore preconstructed interactions.  create 2 all factor interactions
dat = perm_dat;
tmp_dat = dat(:,[2:6 18:20]); tmp_dat_size = size(tmp_dat,2);
interaction = [];
for i = 1:size(tmp_dat,2)
    for j = 1:(i-1)
        tmp_dat = [tmp_dat (tmp_dat(:,i) & tmp_dat(:,j))];
        interaction = [interaction [i; j]];
    end
end
dat = [dat(:,1) tmp_dat];
accumulate_output = pursuit(dat,false,false,false,false,[],13,[3])
interaction = [interaction; (1:size(interaction,2))+(1+tmp_dat_size)]  
% answer: 1,3


%%%%%%%%%%%
%%%% SIMULATION: VARYING PROBABILITY %%%%
% with probability -- mask .  TODO: repeat, average rank of 

tic;
clear all; 
answer = 22;
colors = 'bgrcmk';
nIterations = 500; 
probs = 0:.05:.25;
nConfusion = 10;
figure(); hold on;
counter = 1;
legend_text = {};

for nExamples = 5:20:100 % number of simulated examples 
    stored_ranks = zeros(nIterations, numel(probs));
    for iter = 1:nIterations
        for prob_index = 1:numel(probs);
            dat = simVendingFull(nExamples,nConfusion);

            prob_fail = probs(prob_index);
            dat = xor(dat,(rand(size(dat)) < prob_fail));
            dat = double(dat);
            accumulate_output = pursuit(dat,false,false,false,false,[3 4 10 22],40,[3]);
            tmp_rank = find(accumulate_output(2,:) == answer );
            if isempty(tmp_rank)
                rank = size(accumulate_output,2)+1;
            else
                rank = sum(accumulate_output(3,:) > accumulate_output(3,tmp_rank)) + 1;
            end
            if rank == 0
                error()
            end
            stored_ranks(iter,prob_index) = rank;
            %disp([nExamples iter prob_index rank]);
        end
    end
    disp([nExamples]);
    disp([ probs; mean(stored_ranks,1); std(stored_ranks,1) ])
    errorbar(probs+.002*(counter-1), mean(stored_ranks,1),std(stored_ranks,1),colors(counter),'linewidth',3,'MarkerSize',10)
    legend_text{counter} = [int2str(nExamples) ' replicates'];
    counter = counter + 1;
end
set(gca,'FontSize',16);
legend(legend_text, 'Location', 'Best','FontSize',18);
%ylabel(['Rank of True Cause (in ' int2str(size(dat,2)-1) ' actions)'], 'FontSize',18);
ylabel(['Rank of True Cause'], 'FontSize',18);
xlabel('Percent of Incorrect Action Detections', 'FontSize',18);
title(['Averages Using ' int2str(nIterations) ' samples of \_\_\_ examples']);
axis([-.05 .3 -4 30])
set(gcf, 'PaperPositionMode', 'auto');
% if saveImageBool
%     pause; print -dpng images\simulated; 
% end
hold off;
toc;
% NOTE: output saved in 'output of simulation.m'

% TODO: change n examples.  show it's not just the number of positive
% examples that matters.

% TODO: learn multiple fluents

% TODO: ST-AOG -- OR-AND vs AND-OR


%%% DIFFERENCE IN KL
clear all;
nExamples = 5;
probs = 0;
nConfusion = 10;
dat = simVendingFull(nExamples,nConfusion);
accumulate_output = pursuit(dat,false,false,false,true,[3 4 10 22],40,[3]); % with fluctuation
IG = accumulate_output(3,:); % pulling 3 more fluents in will just essentially reproduce this IG
nCandy = 3;
new_IG = [];
for i = 1:numel(IG)
    new_IG = [new_IG repmat(IG(i),[1 nCandy])];
%     new_IG
%     pause;
end
IG = new_IG;

figure()
set(gca,'FontSize',16);
plot(sum(IG)-[0 cumsum(IG)],'.-','MarkerSize',20,'LineWidth',2)
ylabel(['KL Divergence from CR'], 'FontSize',18);
xlabel('Number of Causal Relations', 'FontSize',18);
%title(['Averages Using ' int2str(nIterations) ' samples of \_\_\_ examples']);
%legend(legend_text, 'Location', 'Best','FontSize',18);
axis([0 40 -.001 0.13])
set(gcf, 'PaperPositionMode', 'auto');
if saveImageBool
    pause; print -dpng images\simulated_KL; 
end



%%%%%%%%%

dat = ***;

for nIterations = 1:5
    accumulate_output = pursuit(dat,false,false,false,false,[],nIterations,[3]);
    actions = accumulate_output(2,:);
    trueValues = tabulate(dat,[1 size(dat,2) actions]);  
    trueValues = trueValues/sum(trueValues);
    modelValues = simulationPursuit(dat,nIterations,true);
    calc_KL(trueValues,modelValues)
    calc_KL(modelValues,trueValues)
end

disp('%%%%%%%%%%%%% END EXPERIMENT: SIMULATED VENDING %%%%%%%%%%%%%%%%%%%%%%%%%%%');
pause;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% END EXPERIMENT: SIMULATED VENDING %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%










asdf


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% BEGIN EXPERIMENT: COLLABORATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: table is described by action of leave/enter, not of move/not move! change this

clear all;

COLLABORATION = 6;
testcase = COLLABORATION;

colors = 'bgrcmk';
counter = 1;
frameLag = 0;
actionLag = 0;
legend_text = {};

% fig_all = figure();

for frameLag = [25 35]
    for actionLag = 1:2
        dat = prepElevDat('collaboration.csv', false);
        %     'enter1'    'enter2'    'exit1'    'exit2'    'onphone'   'pickup'    'pushbutton'    'readpaper'    'walkby'    'walkedaway'    'enter'    'exit'
        dat = remove_cols(dat, [4 5 6 7]); % drop separate enters/exits
        dat = remove_cols(dat, 3); % drop agent number
        dat = add_inertial(dat, frameLag, actionLag, true);
        inertial_index = size(dat,2);
        accumulate_output = pursuit(dat,false,false,false,true,[],48);  
        accumulate_output = [testcase*ones(1,size(accumulate_output,2)); accumulate_output];
        accumulate_output = [answers(accumulate_output(1:4,:),inertial_index); accumulate_output(5:6,:)];
        
        %plotROC(accumulate_output(5,:), colors(counter),fig_all);
        legend_text{counter} = ['min(' int2str(frameLag) ' frames, '];
        legend_text{counter} = [legend_text{counter} int2str(actionLag) ' actions)'];
        
        plot_output(accumulate_output, legend_text{counter})
        
        format_latex(accumulate_output,min(6,size(accumulate_output,2)));
        
        counter = counter + 1;
    end
    
%     % display what we have
%     leg = legend(legend_text, 'Location', 'Best');
%     set(leg,'FontSize',12)
%     axis([-3 22 -0.1 1.3])
% 
%     %reset counter, legend, figure
%     counter = 1;
%     legend_text = {};
%     fig_all = figure();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% END EXPERIMENT:  COLLABORATION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






