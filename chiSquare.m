function [ chisq ] = chiSquare( dat )
%CHISQUARE computes the Chi-Square statistic for a contingency table.
% Note: this does not round the expected values
%
%   Input: 
%       dat = table of frequency data
%              EX: [c0 c2; 
%                   c1 c3]
%
%   Output: 
%       chisq = Chi-Square test statistic


colTotals = sum(dat,1);
rowTotals = sum(dat,2);
grandTotal = sum(rowTotals);

chisq = 0;
warningCount = 0;

for rowNumber = 1:size(dat,1)
    for colNumber = 1:size(dat,2)
        observed = dat(rowNumber,colNumber);
        %expected = round(rowTotals(rowNumber) * colTotals(colNumber) / grandTotal);
        expected = (rowTotals(rowNumber) * colTotals(colNumber) / grandTotal);
%disp([observed expected (observed - expected)^2/expected])
        if expected < 6
            warningCount = warningCount + 1;
        end
        chisq = chisq + (observed - expected)^2/expected;
    end
end

% if warningCount > 0
%     warning('expected frequency cell count not met');
% end