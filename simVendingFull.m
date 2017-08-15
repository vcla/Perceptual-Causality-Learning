function [ dat ] = simVendingFull( nExamples, nConfusion  )
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

% arrive 
arrive_block = [1];
% pay (yes, no)
pay_block = [1; 0];
% push letter (a b c d e f null)
letter_block = [eye(6); zeros(1,6)]; 
% push number (0 ... 9 null)
number_block = [eye(10); zeros(1,10)];
% get snack (0 null)
snack_block = [1; 0];
% leave
leave_block = [1];

% generate one run of each action combination in the AOG for the vending
dat_so_far = arrive_block;
dat_so_far = addBlock(pay_block, dat_so_far);
dat_so_far = addBlock(letter_block, dat_so_far);
dat_so_far = addBlock(number_block, dat_so_far);
dat_so_far = addBlock(snack_block, dat_so_far);
dat_so_far = addBlock(leave_block, dat_so_far);

% vend chocolate: (if money & d & 1)
% faking this -- call it money & a & 0 -- indices 2 3 9
dat = dat_so_far;
dat = [(dat(:,2) & dat(:,3) & dat(:,9)) dat];
dat = [dat dat(:,1)];  % index 22 is correct cause


% add replicates
dat = repmat(dat,[nExamples 1]);

% add confusing actions -- occur approximately 30 times each replicate
confusion = (rand(size(dat,1),nConfusion) <= 30/308); %sum(confusion)
dat = [dat confusion];

% add "previous" fluent on
dat = [dat zeros(size(dat(:,1)))];

