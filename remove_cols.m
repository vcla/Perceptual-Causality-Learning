function [ dat ] = remove_cols( dat, colvars )
%REMOVE_COLS removes indicated column numbers from dat
%
%   Input: 
%       dat = matrix to delete columns from
%       colvars = columns to delete as row matrix
%
%   Output: 
%       dat = original input without the desired columns


dat(:,colvars) = [];

end

