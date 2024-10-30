clc
clear
close all

load click_positions.mat

% hBarCenter_FG = mean([centerDotX_FG], 2);
% hBarCenter_FE = mean([centerDotX_FE], 2);

% hBarCenter_FG = mean([backDotX_FG], 2);
% hBarCenter_FE = mean([backDotX_FE], 2);

% hBarCenter_FG = mean([frontDotX_FG], 2);
% hBarCenter_FE = mean([frontDotX_FE], 2);

hBarCenter_FG = mean([backDotX_FG,frontDotX_FG], 2);
hBarCenter_FE = mean([backDotX_FE,frontDotX_FE], 2);

% hBarCenter_FG = mean([backDotX_FG,frontDotX_FG,centerDotX_FG], 2);
% hBarCenter_FE = mean([backDotX_FE,frontDotX_FE,centerDotX_FE], 2);

figure('units','inches','outerposition',[0 0 6.5 4])
% sgtitle 'Overall position shift'



%% plot scatter + model

mdl = fitlm(hBarCenter_FG, hBarCenter_FE);

fprintf([ ...
    '<Fit parameters> \n' ...
    '---------------- \n' ...
    'y = %4.2fx + (%4.2f) \n' ...
    'adjR2: %4.2f \n'], ...
    mdl.Coefficients.Estimate(2), ...
    mdl.Coefficients.Estimate(1), ...
    mdl.Rsquared.Adjusted)

disp(mdl)

subplot(1,2,1)

szMarker = 100;
alphaMarker = .2;
lwFit = 3;
lwBound = 2.5;
c = 'k';
ticks = 0:10;

hold on
scatter(hBarCenter_FG, hBarCenter_FE, ...
    szMarker, c, 'fill', ...
    'markerfacealpha',alphaMarker)
h = plot(mdl);

hData = findobj(h,'DisplayName','Data');
hFit = findobj(h,'DisplayName','Fit');
hBound = findobj(h,'DisplayName','Confidence bounds');
hBound = findobj(h,'LineStyle',hBound.LineStyle, 'Color', hBound.Color);

set(hFit,'color',c,'linewidth',lwFit)
set(hBound,'color',c,'linestyle',':','linewidth',lwBound)

hData.MarkerFaceColor = 'none';
hData.MarkerEdgeColor = 'none';

addUnityLine
axis square

xticks(ticks)
xlabel({'Position shift (dva)'; 'Flash-Grab'})

yticks(ticks)
ylabel({'Position shift (dva)'; 'Frame'})

title ''
legend off
cleanplot



%% plot difference

subplot(1,2,2)

% data_mat = hBarCenter_FE./hBarCenter_FG;
data_mat = (hBarCenter_FE-hBarCenter_FG)./hBarCenter_FG*100;

scatterbar(data_mat);
errorbar(1, mean(data_mat), SE(data_mat), ...
    'o','color','k','linewidth',2,'marker','none')

xticks(1)
set(gca,'xcolor','none')

ylabel({'Position shift difference (%)'})
yticks(0:50:200)
ylim([50 220])
% yline(1,'-')

% add statistics
[delta, ~, p, W, z, r] = signrank_full(data_mat - 1);
fprintf([ ...
    '\n <Distortion difference>' ...
    '\n -----------------------' ...
    '\n median difference = %4.1f %%' ...
    '\n W = %5.2f' ...
    '\n z = %5.2f' ...
    '\n p = %5.3f' ...
    '\n r = %4.2f \n'], ...
delta,W,z,p,r)
statbar(1,1,210,p)

pbaspect([1,3,1])
cleanplot



%% save figure
set(gcf,'papersize',[8.3 11.7])
saveas(gcf,'../results/fig04.pdf')


