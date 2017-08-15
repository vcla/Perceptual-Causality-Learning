function [ dat ] = prepare_exp1_dat( dat )
%PREPARE_EXP1_DAT Summary of this function goes here
%   Detailed explanation goes here


%%%%%%%%%%%% ADD COLUMNS ON FOR COMPLETE MULTI-ACTION EVENTS %%%%%%%%%%%%%%
% find max of agent column (currently column 3)
max_agent = max(dat(:,3));

% keeping track of success per actor; initialize to 0.
success = zeros(3,1);

% set some constants
UNLOCKED = 2;
KNOCKED = 3;
UNLOCKED = 4;

% add two columns for our new data
dat(:,11:12) = 0;

% foreach frame
%   % this is a hardcoded simple state machine
for line = 1:size(dat,1)
    actor = dat(line,3);
    
    % if (leave | arrive) {
    if dat(line,10) || dat(line,4)
        success(actor) = 0;
    
    % else if (unlock1 or unlock2 and (success[actor] is 0 or undefined)) {
    elseif ((dat(line,6) || dat(line,7)) && (success(actor) == 0))
        success(actor) = UNLOCKED;
    
    % else if (knock and (success[actor] is 0 or undefiend)) {
    elseif (dat(line,5) && (success(actor) == 0))
        success(actor) = KNOCKED;
        
    % else if (openinside and (success[actor] is KNOCKED) {
    elseif (dat(line,8) && (success(actor) == KNOCKED))
        dat(line,11) = 1;  % set LET_IN to 1
        success(actor) = 0;
        
    %   } else if (push and success[actor] is UNLOCKED) {
    elseif (dat(line,9) && (success(actor) == UNLOCKED))
        dat(line,12) = 1;  % set FORCED_IN to 1
        success(actor) = 0;
        
    else
        success(actor) = 0;
        
    end
end

% FrameNum,Door_Status,Agent,Arrive_door,Knock,Unlock_key,Unlock_pass,Open_inside,Push_door,Leave_door, NEW:LET_IN, NEW:FORCED_IN	,
%    1         2        3      4          5      6                 7      8            9       10         11           12
% OUTPUT ACTION #:             1          2      3                 4      5            6       7           8            9      


%%%%%%%%%%%%%%%%%%%%%% SQUASH DUPLICATE TIMES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for line = size(dat,1):-1:2
    % if the previous time matches the current
    if dat(line,1) == dat(line-1,1)
        
        % then there's duplicated time; find all actions occurring at time
        tmp = dat(line,:) | dat(line-1,:);
        
        % put tmp in the previous line
        dat(line-1,2:end) = tmp(2:end);
        
        % remove current line
        dat(line,:) = [];
    end
end

end

