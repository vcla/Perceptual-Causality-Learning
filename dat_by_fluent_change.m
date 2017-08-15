function [ tmpdat ] = dat_by_fluent_change( dat, type )
% for changing input into calc_info
%
%DAT_BY_FLUENT_CHANGE 
%   first column of dat: FLUENT
%   last column of dat: INERTIAL_EXAMPLE
%   other columns of dat: ACTIONS
%   each row of dat should be one example for consideration
%   
%   this function takes in dat and a type
%       type '00': Fluent stays off
%       type '01': F = 0, F(-1) = 1; Fluent turns OFF
%       type '10': F = 1, F(-1) = 0; Fluent turns ON
%       type '11': Fluent stays on
%
%   The function returns tmpdat where the fluent has been replaced by 
%       1 if example is of correct type
%       0 if example isn't


nCols = size(dat,2);
inertial_index = nCols;


% separate the "on" examples from the "off" examples
dat_on = dat;
dat_on(dat_on(:,1) == 0,:) = [];   % get rid of examples of off
dat_on(:,1) = (~dat_on(:,inertial_index));
    % dat_on has a 0 for current fluent if previous was 1 (stay on)
    % dat_on has a 1 for current fluent if previous was 0 (turn off)
    % ie: dat_on marks if there was a change

dat_off = dat;
dat_off(dat_off(:,1) == 1,:) = [];  % get rid of examples of on
%dat_off(:,inertial_index) = ~dat_off(:,inertial_index);
dat_off(:,1) = (dat_off(:,inertial_index));  % TODO: double check this is the right calculation for "off"
    % dat_off has a 0 for current if stay off
    % dat_off has a 1 fur current if turns on
    % dat_off marks if there was a change


% % OUTPUT 2: SEPARATING "ON" FROM "OFF", LOOK AT CHANGE/NOT, ON FIRST
% disp('OUTPUT 2: SEPARATING "ON" FROM "OFF", LOOK AT CHANGE/NOT, ON FIRST');
% o2_on = calc_info(dat_on);
% o2_off = calc_info(dat_off);

if strcmp(type,'00')
    tmpdat_on = dat_on; 
    tmpdat_on(:,1) = 0; 
    tmpdat_off = dat_off;
    tmpdat_off(:,1) = ~dat_off(:,1); % turns inertial to example 
    tmpdat = [tmpdat_on; tmpdat_off];
elseif strcmp(type, '10')
    tmpdat_on = dat_on; % no need to change dat_on; 1's in correct places
    tmpdat_off = dat_off;
    tmpdat_off(:,1) = 0; % force all dat_off to 0's (non-examples)
    tmpdat = [tmpdat_on; tmpdat_off];
elseif strcmp(type, '01')
    tmpdat_on = dat_on; 
    tmpdat_on(:,1) = 0; % all examples ending in "on" are non-examples here
    tmpdat_off = dat_off;
    tmpdat = [tmpdat_on; tmpdat_off];
elseif strcmp(type, '11')  % from F = 1 to F = 1
    tmpdat_on = dat_on; 
    tmpdat_on(:,1) = ~dat_on(:,1); % turns inertial to example (1)
    tmpdat_off = dat_off;
    tmpdat_off(:,1) = 0; 
    tmpdat = [tmpdat_on; tmpdat_off];
else
    error('invalid type');
end

end

