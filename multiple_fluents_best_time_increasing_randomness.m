function out = multiple_fluents_best_time_increasing_randomness(perm_dat, saveImageBool)

DOOR = 1;
MONITOR = 2;
LIGHT = 3;
colors = 'bgrcmk';
legend_text = {};

actionLag = 1;
frameLag = 103;

fig_light = figure();
fig_door = figure();

for testcase = [DOOR LIGHT]
    % inertial_index = 13;

    for flipProb = [.2 .1 0]
        
        rand_dat = perm_dat;
        rand_matrix = rand(size(rand_dat,1),11);
        rand_dat(:,6:end) = abs(rand_dat(:,6:end) - (rand_matrix < flipProb));

        dat = rand_dat;
        
        if testcase == DOOR
            %%% Experiment: DOOR
            casetext = 'Door';
            % remove the columns 3(monitor), 4 (light), 5(agent)
            dat = remove_cols(dat, [3, 4, 5]);

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
        dat = add_inertial2(dat,frameLag, actionLag,true); % using intersection

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

        if testcase == LIGHT
            %light_output = accumulate_output;
            fig_id = fig_light;
        elseif testcase == DOOR
            %door_output = accumulate_output;
            fig_id = fig_door;
        else
            error('invalid test case');
        end

        plot_output(accumulate_output, casetext, fig_id);
        set(gcf, 'PaperPositionMode', 'auto');
        pause
    end

end

    if saveImageBool
        error('todo')
        pause; 
        print('-dpng',['images\' casetext '_info_gains']);
    end


disp('%%%%%%%%% END EXPERIMENT: MULTIPLE FLUENTS BEST TIME %%%%%%%%%%%%%%%%%');

