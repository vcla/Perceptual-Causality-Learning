function [ object_name ] = get_object_name( testcase )
%GET_OBJECT_NAME Summary of this function goes here
%   Detailed explanation goes here

DOOR = 1;
MONITOR = 2;
LIGHT = 3;
EXP1_DOOR = 4;
ELEVATOR = 5;

if testcase == DOOR
    object_name = 'Door';
elseif testcase == MONITOR
    object_name = 'Monitor';
elseif testcase == LIGHT
    object_name = 'Light';
elseif testcase == EXP1_DOOR
    object_name = 'Door 2';
elseif testcase == ELEVATOR
    object_name = 'Elevator';
else
    disp(testcase);
    error('invalid testcase ');
end
   


end

