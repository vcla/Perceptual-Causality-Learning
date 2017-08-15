function [ new_dat ] = synthesizeDat( nExamples, nSnacks, nConfusion  )
%SYNTHESIZEDAT 
%   
% T-AOG
% S -> A1 | A2 | A3
% A1 -> a11 a12 a13     ...     -> VEND A
% A2 -> a21 a22 a23     ...     -> VEND B
% A3 -> a31 a32 a33     ...     -> VEND C

%nExamples = 2;
%nConfusion = 1;
% nSnacks = 3;

vend_duration = 10;
arrive_duration = 100;  % arrive vend (this is big to separate instances)
pay_duration = 20;
push_duration = 10;  % push buttons 1
get_candy_duration = 20;  % get candy
leave_duration = 20;  % leave vend
        
confusion_duration = 50;  % time to complete confusion

% initialize start time
frame = 1;

% start dat with nothing.  each row will be a new frame.  at the end,
% squash 0 rows to nothing, and add frame information to first column.
dat = [];

fluents = [];


% vend each snack nExamples times
% first: come up with order of vending snacks 
totalVends = ones(nExamples,nSnacks) * diag(1:nSnacks);
snackOrder = randperm(numel(totalVends));
snackOrder = totalVends(snackOrder);
snackOrder = reshape(snackOrder,1,numel(snackOrder));

% for each vend item, create actions to get snack
% actions in dat -- list push buttons first 
for getSnack = snackOrder
    timeToArrive = randn(1) + arrive_duration;
    frame = frame + timeToArrive;
    frame = round(frame);
    dat(frame, nSnacks + 1) = 1;
%disp(size(dat))
    timeToPay = randn(1) + pay_duration;
    frame = frame + timeToPay;
    frame = round(frame);
    dat(frame, nSnacks + 2) = 1;
%disp(size(dat))

    % push the buttons -- push getsnack button
    timeToPush = randn(1) + push_duration;
    frame = frame + timeToPush;
    frame = round(frame);
    dat(frame, getSnack) = 1;
%disp(size(dat))

    % compositions -- arrive & push (each)
    combo_column = nSnacks + 4 + getSnack;
    dat(frame, combo_column) = 1;    
%disp(size(dat))

    % compositions -- arrive & push & pay
    combo_column = nSnacks + 4 + nSnacks + getSnack;
    dat(frame, combo_column) = 1;
%disp(size(dat))

    % UPDATE FLUENT -- getsnack candy vended
    timeToVend = rand(1) + vend_duration;
    frame = frame + timeToVend;
    frame = round(frame);
    fluents(frame,getSnack) = 1;

    
    timeToGetCandy = rand(1) + get_candy_duration;
    frame = frame + timeToGetCandy;
    frame = round(frame);
    dat(frame, nSnacks + 3) = 1;
%disp(size(dat))

    timeToLeave = rand(1) + leave_duration;
    frame = frame + timeToLeave;
    frame = round(frame);
    dat(frame, nSnacks + 4) = 1;
%disp(size(dat))

    %%% compositions - arrive & leave
    dat(frame, nSnacks + 4 + nSnacks + nSnacks + 1) = 1;
%disp(size(dat))

%disp([ getSnack frame])
end

%disp(size(dat))


% add on vending actions that fail -- arrive and leave
for getSnack = snackOrder
    timeToArrive = randn(1) + arrive_duration;
    frame = frame + timeToArrive;
    frame = round(frame);
    dat(frame, nSnacks + 1) = 1;
    
    timeToLeave = rand(1) + leave_duration;
    frame = frame + timeToLeave;
    frame = round(frame);
    dat(frame, nSnacks + 4) = 1;
    
    %%% compositions - arrive & leave
    dat(frame, nSnacks + 4 + nSnacks + nSnacks + 1) = 1;
%disp([ getSnack frame])
end
%disp(size(dat))

% add on vending actions that fail -- arrive, push, and leave
for getSnack = snackOrder
    timeToArrive = randn(1) + arrive_duration;
    frame = frame + timeToArrive;
    frame = round(frame);
    dat(frame, nSnacks + 1) = 1;
    
    % push the buttons -- push getsnack button
    timeToPush = randn(1) + push_duration;
    frame = frame + timeToPush;
    frame = round(frame);
    dat(frame, getSnack) = 1;

    % compositions -- arrive & push (each)
    combo_column = nSnacks + 4 + getSnack;
    dat(frame, combo_column) = 1;    
    
    timeToLeave = rand(1) + leave_duration;
    frame = frame + timeToLeave;
    frame = round(frame);
    dat(frame, nSnacks + 4) = 1;
    
    %%% compositions - arrive & leave
    dat(frame, nSnacks + 4 + nSnacks + nSnacks + 1) = 1;

end

%disp(size(dat))
%asdf

%%% CONFUSION
% add on nConfusion
confusion = (rand(size(dat,1),nConfusion) <= 1/(confusion_duration +1 ));


%%% MAKE COMPOSE DAT BY COMBINING FRAMES, FLUENTS, ACTIONS, CONFUSIONS
% make fluents same size
fluents(frame,:) = 0;

%combine fluent and action
if size(fluents, 1) > size(dat,1) 
    error('fluent is bigger than action');
end
new_dat = [(1:size(fluents,1))' fluents dat confusion];
%indices to squash
tmpinds = find(sum(new_dat(:,2:end),2) == 0);
new_dat(tmpinds,:) = [];
