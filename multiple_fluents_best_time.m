function out = multiple_fluents_best_time(perm_dat, saveImageBool)

DOOR = 1;
MONITOR = 2;
LIGHT = 3;
colors = 'bgrcmk';
legend_text = {};

actionLag = 1;
frameLag = 103;

for testcase = [DOOR MONITOR LIGHT]
    % inertial_index = 13;

    dat = perm_dat;

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

    % add previous fluent value to the end of dat, remove frame
    % information
    dat = create_examples_with_prev_fluent(dat,frameLag, actionLag,true); % using intersection
    
    if testcase == LIGHT
        accumulate_output = pursuit(dat,true,false,false,true,[],40,[2:3],1);  
    elseif testcase == DOOR
        %accumulate_output = pursuit(dat,false,false,true,true,[],40,[2:3]);  
        accumulate_output = pursuit(dat,false,false,true,true,[],40, [2:3],2);  
        disp('TALLY OF TRUE CAUSE (DOOR, OPEN DOOR)');
        c = tabulate(dat,[1 13 4]); disp([(c(1)+c(3)+c(7)) c(5) (c(2)+c(4)+c(8)) c(6)]);
        disp('TALLY OF NON-CAUSE (DOOR, TOUCH LIGHT SWITCH');
        c = tabulate(dat,[1 13 9]); disp([(c(1)+c(3)+c(7)) c(5) (c(2)+c(4)+c(8)) c(6)]);
    else
        accumulate_output = pursuit(dat,false,false,false,true,[],40,[2:3]);  
    end
    accumulate_output = [testcase*ones(1,size(accumulate_output,2)); accumulate_output];

    % keep only the causal effect examining here (remove second one)
%    accumulate_output(end,:) = [];
    %disp(accumulate_output);

    % add on the answers
    inertial_index = 13;
    accumulate_output = [answers(accumulate_output(1:4,:),inertial_index); accumulate_output(5:end,:)];

    % return latex formatted table
%         disp('%%%%%%%%%%%%%%%%%%%');
%        format_latex(accumulate_output,10);
%         disp('%%%%%%%%%%%%%%%%%%%');

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

    plot_output(accumulate_output, casetext);
    set(gcf, 'PaperPositionMode', 'auto');
    if saveImageBool
        pause; 
        print('-dpng',['images\' casetext '_info_gains']);
    end

end

% combine all the fluents--sort the accumulated output by the KL divergence
sorted = sort_multiple_fluents(light_output, monitor_output, door_output,4);

plot_output(sorted,'All Fluents')
set(gcf, 'PaperPositionMode', 'auto');
if saveImageBool
    pause; print -dpng images\allfluents_info_gains
end

disp('%%%%%%%%%%%%%%%%%%%');
format_latex(sorted, 20);
disp('%%%%%%%%%%%%%%%%%%%');

% resort by chi square and TE, plot ROC's by info, chi square, TE
fig_num = figure();
counter = 1;
for sort_row = [4 6]
    sorted = sort_multiple_fluents(abs(light_output), abs(monitor_output), abs(door_output), sort_row);
    %sorted(5,:)
    plotROC(sorted(5,:),colors(counter),fig_num,(counter-2)*.005*40, (counter-2)*.005*6)
    counter = counter + 1;
end
axis([-3 60 -0.1 10.3])
legend('Info Gain', 'TE', 'Location','Best','FontSize',20);

disp('%%%%%%%%% END EXPERIMENT: MULTIPLE FLUENTS BEST TIME %%%%%%%%%%%%%%%%%');

