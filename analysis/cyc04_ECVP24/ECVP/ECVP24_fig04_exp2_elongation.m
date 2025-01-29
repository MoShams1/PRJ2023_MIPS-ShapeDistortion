clc
clear
close all

load click_positions.mat

bar_original_length = .95 * 2;
hBarElongation_FG = (abs(frontDotX_FG-backDotX_FG) - bar_original_length) / ...
    bar_original_length * 100;
hBarElongation_FE = (abs(frontDotX_FE-backDotX_FE) - bar_original_length) / ...
    bar_original_length * 100;

figure('units','inches','outerposition',[1 1 10 5])
% sgtitle 'Elongation (%)'



%% plot scatter + model

mdl = fitlm(hBarElongation_FG, hBarElongation_FE);

fprintf([ ...
    '<Fit parameters> \n' ...
    '---------------- \n' ...
    'y = %4.2fx + (%4.2f) \n' ...
    'adjR2: %4.2f \n'], ...
    mdl.Coefficients.Estimate(2), ...
    mdl.Coefficients.Estimate(1), ...
    mdl.Rsquared.Adjusted)

subplot(1,2,1)

szMarker = 100;
alphaMarker = .2;
lwFit = 3;
lwBound = 2.5;
c = 'k';
ticks = -100:50:150;

hold on
scatter(hBarElongation_FG, hBarElongation_FE, ...
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
xlabel({'Elongation (%)'; 'Flash-Grab'})
xline(0)

yticks(ticks)
ylabel({'Elongation (%)'; 'Frame'})
yline(0)

title ''
legend off
cleanplot



%% plot difference

subplot(1,2,2)

data_mat = hBarElongation_FE-hBarElongation_FG;
scatterbar(data_mat);
errorbar(1, mean(data_mat), SE(data_mat), ...
    'o','color','k','linewidth',2,'marker','none')

xticks(1)
set(gca,'xcolor','none')

ylabel 'Difference (pp)'
yticks(-100:50:100)
ylim([-130 50])
yline(0,'-')

% add statistics
[delta, deltap, p, W, z, r] = signrank_full(data_mat);
fprintf([ ...
    '\n <Distortion difference>' ...
    '\n -----------------------' ...
    '\n mean decrease = %4.1f pp' ...
    '\n mean decrease = %3.0f %%' ...
    '\n W = %5.2f' ...
    '\n z = %5.2f' ...
    '\n p = %5.3f' ...
    '\n r = %4.2f \n'], ...
delta,deltap,W,z,p,r)
statbar(1,1,-130,p)

pbaspect([1,3,1])
cleanplot



%% save figure
set(gcf,'papersize',[10 10])
saveas(gcf,'../../results/ecvp24_fig04.pdf')


