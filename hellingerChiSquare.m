function [ chisq ] = hellingerChiSquare( dat )
%CHISQUARE computes the Hellinger Chi-Square statistic for a contingency table.
% Note: this does not round the expected values
%
%   Input: 
%       dat = table of frequency data
%              EX: [c0 c2; 
%                   c1 c3]
%
%   Output: 
%       chisq = Chi-Square test statistic

% TODO: NEEDS ERROR CHECKING -- NO IDEA IF I HAVE CORRECT CALCULATION


colTotals = sum(dat,1);
rowTotals = sum(dat,2);
grandTotal = sum(rowTotals);
chisq = 0;

for rowNumber = 1:size(dat,1)
    for colNumber = 1:size(dat,2)
        pObserved = dat(rowNumber,colNumber)/grandTotal;
        expected = (rowTotals(rowNumber) * colTotals(colNumber) / grandTotal);
        pExpected = expected/grandTotal;
        chisq = chisq + (sqrt(pObserved) - sqrt(pExpected))^2;
        % vs chisq: (O - E)^2/E  this one is: (O/T - E/T)^2
    end
end

chisq = 4*grandTotal*chisq;
