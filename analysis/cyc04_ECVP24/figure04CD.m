clc
clear

load click_positions.mat

hBarCenter_FG = mean([backDotX_FG,frontDotX_FG], 2);
hBarCenter_FE = mean([backDotX_FE,frontDotX_FE], 2);


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

subplot(2,2,3)

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

xticks(ticks)
xlabel({'Single dots'' position shift (dva)'; 'Flash-Grab'})

yticks(ticks)
ylabel({'Single dots'' position shift (dva)'; 'Frame'})

text(4, .25, ['N = ',num2str(numel(hBarCenter_FG))])

title ''
legend off
cleanplot

fprintf('\n*** FG median position shift: %4.2f dva', median(hBarCenter_FG))
fprintf('\n*** FE median position shift: %4.2f dva\n', median(hBarCenter_FE))

%% plot difference

subplot(2,2,4)

data_mat = (hBarCenter_FE-hBarCenter_FG)./hBarCenter_FG*100;

scatterbar_median(data_mat);
errorbar(1, median(data_mat), MAD(data_mat), ...
    'o','color','k','linewidth',2,'marker','none')

xticks(1)
set(gca,'xcolor','none')

ylabel({'Position shift difference (%)', '(Frame vs. Flash-Grab)'})
yticks(0:50:200)
ylim([-10 225])
yline(0,'-')

% add statistics
[delta, ~, p, W, z, r] = signrank_full(data_mat);
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


