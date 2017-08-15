function [ handle ] = plot_output( varargin  )
%PLOT_OUTPUT Summary of this function goes here
% INPUT:
%       accumulate_output: pursued info gain is in 4th row
%       

accumulate_output = varargin{1};
titletext = varargin{2};

if nargin > 2
    handle = figure(varargin{3});
else
    handle = figure();
end

if any((accumulate_output(5,:) ~= 0) & (accumulate_output(5,:) ~=1))
    error('answer row is not zeros and ones');
end

hold on;

info = accumulate_output(4,:);
cause = accumulate_output(5,:);

x = 1:numel(info);
plot(x,info);

h1 = plot(x(cause > 0), info(cause > 0), 'go', 'LineWidth',3, 'MarkerSize',10);
h2 = plot(x(cause == 0), info(cause == 0), 'rx', 'LineWidth',3, 'MarkerSize',10);

max_y = max(info(cause > 0));
max_x = numel(x);

axis([0 (max_x + 1) 0 (max_y + .01)])

set(gca,'FontSize',16);

title(titletext, 'FontSize',16);
xlabel('Iteration Number', 'FontSize',18);
ylabel('Information Gain', 'FontSize',18);
legend([h1 h2], 'Human-Perceived Cause', 'Non-Cause','Location','Best','FontSize',20)

hold off;

end

