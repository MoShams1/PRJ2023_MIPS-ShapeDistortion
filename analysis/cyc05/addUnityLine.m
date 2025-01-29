% addUnityLine()
% Mohammad Shams <m.shamsahmar@gmail.com>
% June 2024

function addUnityLine()
x_limits = xlim;
y_limits = ylim;
min_val = min([x_limits, y_limits]);
max_val = max([x_limits, y_limits]);
line([min_val max_val], [min_val max_val], 'color','k')
axis([min_val max_val min_val max_val])
end