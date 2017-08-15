function [ output_args ] = plotROC( masked, color, figureNumber,xOffset,yOffset )
%function [ output_args ] = plotROC( masked, color, figureNumber )
%   Input
%       masked = vector in order of detections, 0 -> wrong, 1 -> correct
%

if ~exist('figureNumber')
    figure();
else
    figure(figureNumber);
end

hold on;

% TODO: deal with boundaries -- maybe return max_x/max_y?
max_y = 0; max_x = 0;


x = (1:numel(masked)) - cumsum(masked);
%figure();
allX = [0 x] - xOffset;
allY = [0 cumsum(masked)] - yOffset;
plot(allX,allY, strcat(color,'-'),'linewidth',3,'MarkerSize',10)
set(gca,'FontSize',16);

% try to find new axis boundaries
if sum(masked) > max_y
    max_y = sum(masked);
end
if max(x) > max_x
    max_x = max(x);
end

xlabel('False Alarm', 'FontSize',18);
ylabel('True Causal Relation','FontSize',18);

hold off;

