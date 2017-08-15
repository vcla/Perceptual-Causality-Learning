function [ tmp ] = calc_info( dat )
%CALC_INFO 
% feed in a data matrix where the first column is the fluent.  The rest of 
% the columns are the action (or whatever) you want to consider as "causes"
%   
% Input
%       dat: matrix where each row is an example
%               column 1: fluent value for which the row is an example
%               columns 2 to end: actions/etc that we are examining for
%                                   causal relationship
%
% Output
%       tmp: matrix that gives frequencies and info gains
%       row of tmp = [f0a0 f1a0 f0a1 f1a1 f0 f1 infoA0 infoA1 allinfo]


nExamples = size(dat,1);
% NOTE: i was subtracting one from that, no clue why!

% initialize tmp to hold output for information gains
tmp = [];

for action = 2:size(dat,2)
    % for each action, which are located in dat cols (skipping the first)
    
    % calculate the frequencies for each combination of F and A
    f0a0 = sum( (dat(:,1) == 0) & (dat(:,action) == 0));
    f0a1 = sum( (dat(:,1) == 0) & (dat(:,action) == 1));
    f1a0 = sum( (dat(:,1) == 1) & (dat(:,action) == 0));
    f1a1 = sum( (dat(:,1) == 1) & (dat(:,action) == 1));

    % calculate the marginals for F and A
    f1 = f1a0 + f1a1;
    f0 = f0a0 + f0a1;
    a0 = f1a0 + f0a0;
    a1 = f1a1 + f0a1;
    
    
    %%%  NOTE: These synthesized values are based on synthesizing F alone,
    %%%  not F and A because we're only interested in replacing P(F) with P(F|A)
        
    % calculate info gain for conditional when NOT do(A)
    f = f1a0/a0; h = f1/size(dat,1);
    infoA0 = bernoulli_KL(f, h);
    infoA0 = a0/(a0+a1) * infoA0;
    
    % calculate info gain for conditional when do(A)
    f = f1a1/a1;
    infoA1 = bernoulli_KL(f, h);
    infoA1 = a1/(a0+a1) * infoA1;
    
    
    %%%  NOTE: these synthesized values are synthesizing F and A independently
        % TODO: might be place where lose reusability (if need to combine
        % actions on the fly, or if actions are not independent)
    % calculate info gain for joint
    allinfo = 0;
    allH = [(f0*a0) (f0*a1) (f1*a0) (f1*a1)]/(nExamples*nExamples);
    allH = allH / sum(allH);
    allF = [f0a0 f0a1 f1a0 f1a1]/nExamples;
    for term = 1:4
        % TODO: this might be point where we lose reusability because 4 is hard coded
        if allF(term) ~= 0
            allinfo = allinfo + allF(term) * log( allF(term) / allH(term) );
        end
    end
    
%     nExamples
%     f0 + f1
%     sum(allF)
%     allF 
%     allH 
%     asdf
    
    if allinfo < 0
        if abs(allinfo) > 0.000000001
            allH
            allF
            sum(allF)
            sum([f0a0 f0a1 f1a0 f1a1])
            nExamples        
            allinfo
            [f0a0 f1a0 f0a1 f1a1 f0 f1 infoA0 infoA1 allinfo]
            error('allinfo is too negative')
        end
    end
    
    % prepare output
    tmp = [tmp; f0a0 f1a0 f0a1 f1a1 f0 f1 infoA0 infoA1 allinfo];

end

%[Y I] = sort(tmp,1,'descend');
%X = (1:size(tmp,1))';
% [X tmp(:,1:7) I(:,7) tmp(:,8) I(:,8) tmp(:,9) I(:,9)]

disp('[    f0a0     f1a0      f0a1      f1a1       f0       f1        infoA0    infoA1    allinfo]');
disp(tmp);


end

