function [ accumulate_output ] = answers( accumulate_output, INERTIAL_INDEX )
%ANSWERS 
%   First row:  object id
%   Second:     fluent change type id
%   Third:      Action index
%   Fourth:     action scores

DOOR = 1;
MONITOR = 2;
LIGHT = 3;
EXP1_DOOR = 4;
ELEVATOR = 5;
VENDING = 6;

accumulate_output(2,:) = accumulate_output(2,:) + 4;
OUTPUT00 = 4 + 1;  % stay off
OUTPUT01 = 4 + 2;  % on to off
OUTPUT10 = 4 + 3;  % off to on
OUTPUT11 = 4 + 4;  % stay on
OUTPUT_FIRSTROUND = 4 + 5;

accumulate_output(5,:) = 0;

for colindex = 1:size(accumulate_output,2)
    col = accumulate_output(:,colindex);
    object = col(1);
    fluentchange = col(2);
    action = col(3);

    if object == DOOR
        if fluentchange == OUTPUT00
            possible_answers = [];
        elseif fluentchange == OUTPUT01
            % Causes for Open: (1,3) +1
            possible_answers = [3 5];
        elseif fluentchange == OUTPUT10
            % Causes for Closed: (2,4) + 1
            possible_answers = [2 4];
        elseif fluentchange == OUTPUT11
            possible_answers = [];
        %elseif fluentchange == OUTPUT_FIRSTROUND
        %    possible_answers = INERTIAL_INDEX;
        else
            error('No fluent change of that type');
        end
    
    elseif object == MONITOR
        % 6Power_Monitor,Touch_Mouse,Touch_Keyboard
        if fluentchange == OUTPUT00
            possible_answers = [];
        elseif fluentchange == OUTPUT01
            possible_answers = 6;
        elseif fluentchange == OUTPUT10
            possible_answers = [6 7 8];
            % TODO: time passes, also
        elseif fluentchange == OUTPUT11
            possible_answers = []; % TODO: also 7 8
        %elseif fluentchange == OUTPUT_FIRSTROUND
        %    possible_answers = INERTIAL_INDEX;
        else
            error('No fluent change of that type');
        end
    elseif object == LIGHT
        %9Touch_Switch,Conversation,Pick_Up,Walk_By
        if fluentchange == OUTPUT00
            possible_answers = [];
        elseif fluentchange == OUTPUT01
            if INERTIAL_INDEX > 13
                error('cannot consider mixed here')
                %possible_answers = 13;
            else
                possible_answers = 9;
            end
        elseif fluentchange == OUTPUT10
            if INERTIAL_INDEX > 13
                error('cannot consider mixed here');
                %possible_answers = 13; % then considering interaction
            else
                possible_answers = 9;
            end
        elseif fluentchange == OUTPUT11
            possible_answers = [];
        %elseif fluentchange == OUTPUT_FIRSTROUND
        %    possible_answers = INERTIAL_INDEX;
        else
            error('No fluent change of that type');
        end
    elseif object == EXP1_DOOR
        % We should observe rows 8 and 9 for the causes to change the door to open
        %   9 is composed of "knock" (3) and "open_inside (6)
        %   10 is composed of "push" (7) and "unlock" (4 or 5)
        if fluentchange == OUTPUT00
            possible_answers = INERTIAL_INDEX;
        elseif fluentchange == OUTPUT01
            %possible_answers = 8; TODO: re-examine video, separate "leave
            %door" from "touching door"
            possible_answers = [];
        elseif fluentchange == OUTPUT10
            possible_answers = [10 6];
        elseif fluentchange == OUTPUT11
            possible_answers = INERTIAL_INDEX;
        %elseif fluentchange == OUTPUT_FIRSTROUND
        %    possible_answers = [10, 6];
        else
            error('No fluent change of that type');
        end
    elseif object == ELEVATOR
        if fluentchange == OUTPUT00
            possible_answers = [];
        elseif fluentchange == OUTPUT01
            possible_answers = [];
        elseif fluentchange == OUTPUT10
            possible_answers = [4];
        elseif fluentchange == OUTPUT11
            possible_answers = [];
        else
            error('No fluent change of that type');
        end
%     elseif object == VENDING_1
%         if fluentchange == OUTPUT10
%             possible_answers = [8];
%         else
%             error('No fluent change of that type');
%         end
    else
        error('No object of that type (function answers.m)');
    end
    
%disp([object, fluentchange-4, action, fluentchange, possible_answers])
    if any(possible_answers == action)
        accumulate_output(5,colindex) = 1;
    end
    
end

accumulate_output(2,:) = accumulate_output(2,:) - 4;


end

