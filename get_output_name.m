function [ outputtypetext ] = get_output_name( outputtype, testcase )
%GET_OUTPUT_NAME 
%   

DOOR = 1;
MONITOR = 2;
LIGHT = 3;
EXP1_DOOR = 4;
ELEVATOR = 5;

if (testcase == DOOR) || (testcase == EXP1_DOOR) || (testcase == ELEVATOR)
    zero = 'C';
    one = 'O';
elseif (testcase == MONITOR) || (testcase == LIGHT)
    zero = 'O_0';
    one = 'O_1';
else
    error('unknown testcase');
end

if outputtype == 1
    % current 0, previous 0
    outputtypetext = strcat(' Stay $', zero, '$');
elseif outputtype == 2
    % current 0, previous 1.  on to off.
    outputtypetext = [' $', one, ' \to ', zero, '$'];
elseif outputtype == 3
    % current 1, previous 0.  off to on.
    outputtypetext = [' $', zero, ' \to ', one, '$'];
elseif outputtype == 4
    % current 1, previous 1
    outputtypetext = strcat(' Stay $', one, '$');
elseif outputtype == 5
    % start example
    outputtypetext = strcat(' First Fit');
else
    error('unknown outputtype')
end


end

