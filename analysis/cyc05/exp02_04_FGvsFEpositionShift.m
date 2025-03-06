clc
clear

load click_positions.mat

hBarCenter_FG = mean([backDotX_FG,centerDotX_FG,frontDotX_FG], 2);
hBarCenter_FE = mean([backDotX_FE,centerDotX_FE,frontDotX_FE], 2);

nsubjects = length(hBarCenter_FG);

%% plot scatter + model

% mdl = fitlm(hBarCenter_FG, hBarCenter_FE);

% fprintf([ ...
%     '<Fit parameters> \n' ...
%     '---------------- \n' ...
%     'y = %4.2fx + (%4.2f) \n' ...
%     'adjR2: %4.2f \n'], ...
%     mdl.Coefficients.Estimate(2), ...
%     mdl.Coefficients.Estimate(1), ...
%     mdl.Rsquared.Adjusted)

% disp(mdl)

figure('units','inches','outerposition',[0 0 4 4])
hold on

szMarker = 100;
alphaMarker = .4;
c = 'k';
ticks = 0:.5:10;
lims = [-0.2 2];

scatter(hBarCenter_FG, hBarCenter_FE, ...
    szMarker, c, 'fill', ...
    'markerfacealpha',alphaMarker)
% h = plot(mdl);

% hData = findobj(h,'DisplayName','Data');
% hFit = findobj(h,'DisplayName','Fit');
% hBound = findobj(h,'DisplayName','Confidence bounds');
% hBound = findobj(h,'LineStyle',hBound.LineStyle, 'Color', hBound.Color);
% 
% set(hFit,'color',c,'linewidth',lwFit)
% set(hBound,'color',c,'linestyle',':','linewidth',lwBound)

% hData.MarkerFaceColor = 'none';
% hData.MarkerEdgeColor = 'none';

title 'Position shift (dva)'

xlabel 'Flash-Grab'
xline(0,'-')
xticks(ticks)
xlim(lims)

ylabel 'Frame'
yline(0,'-')
yticks(ticks)
ylim(lims)

text(1.5, .15, ['N = ',num2str(nsubjects)])

axis square
addUnityLine

cleanplot

fprintf('\n*** FG median position shift: %4.2f dva', median(hBarCenter_FG))
fprintf('\n*** FE median position shift: %4.2f dva\n', median(hBarCenter_FE))

%% plot difference

% subplot(2,2,4)
% 
% data_mat = (hBarCenter_FE-hBarCenter_FG)./hBarCenter_FG*100;
% 
% scatterbar_median(data_mat);
% errorbar(1, median(data_mat), MAD(data_mat), ...
%     'o','color','k','linewidth',2,'marker','none')
% 
% xticks(1)
% set(gca,'xcolor','none')
% 
% ylabel({'Position shift difference (%)', '(Frame vs. Flash-Grab)'})
% yticks(0:25:100)
% ylim([-10 110])
% yline(0,'-')
% 
% % add statistics
% [delta, ~, p, W, z, r] = signrank_full(data_mat);
% fprintf([ ...
%     '\n <Distortion difference>' ...
%     '\n -----------------------' ...
%     '\n median difference = %4.1f %%' ...
%     '\n W = %5.2f' ...
%     '\n z = %5.2f' ...
%     '\n p = %5.3f' ...
%     '\n r = %4.2f \n'], ...
% delta,W,z,p,r)
% statbar(1,1,110,p)
% 
% pbaspect([1,3,1])
% cleanplot

%% save figure
% set(gcf,'papersize',[8.3 11.7])
% saveas(gcf,'../results/fig04_wFixDot.pdf')


