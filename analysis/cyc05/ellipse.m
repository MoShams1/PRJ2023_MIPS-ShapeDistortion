% draw ellipse
% Mohammad Shams <m.shams.ahmar@gmail.com>
% March 2025
%
% ellipse(x0,y0,a,b,color,alpha)
% x0: center x
% y0: center y
% a: horizontal axis (half length)
% b: vertical axis (half width)
% alpha: transparency rate


function ellipse(x0,y0,a,b,color,alpha)

theta = linspace(0, 2*pi, 100); % Angle values
x = a * cos(theta); 
y = b * sin(theta);
X = x + x0;
Y = y + y0;
fill(X, Y, color, 'facealpha',alpha, 'edgecolor','none');