clc
clear
close all

load distortion_observed.mat
load click_positions.mat

hBarLength_FG = abs(frontDotX_FG - backDotX_FG);
hBarLength_FE = abs(frontDotX_FE - backDotX_FE);

leftHand_FG = abs(centerDotX_FG - backDotX_FG);
leftHand_FE = abs(centerDotX_FE - backDotX_FE);

rightHand_FG = abs(frontDotX_FG - centerDotX_FG);
rightHand_FE = abs(frontDotX_FE - centerDotX_FE);

distortion_expected_FG = (leftHand_FG-rightHand_FG) ./ hBarLength_FG;
distortion_expected_FE = (leftHand_FE-rightHand_FE) ./ hBarLength_FE;

figure('units','inches','outerposition',[1 1 6.75 8])


%% plot scatter
% mdl = fitlm(distortion_expected_FG, distortion_expected_FE);
% 
% fprintf([ ...
%     '<Fit parameters> \n' ...
%     '---------------- \n' ...
%     'y = %4.2fx + (%4.2f) \n' ...
%     'adjR2: %4.2f \n'], ...
%     mdl.Coefficients.Estimate(2), ...
%     mdl.Coefficients.Estimate(1), ...
%     mdl.Rsquared.Adjusted)
% 
% disp(mdl)

subplot(2,2,1)

szMarker = 100;
alphaMarker = .2;
% lwFit = 3;
% lwBound = 2.5;
c = 'k';
ticks = -1:.25:1;

hold on
scatter(distortion_expected_FG, distortion_expected_FE, ...
    szMarker, c, 'fill', ...
    'markerfacealpha',alphaMarker)
% h = plot(mdl);

% hData = findobj(h,'DisplayName','Data');
% hFit = findobj(h,'DisplayName','Fit');
% hBound = findobj(h,'DisplayName','Confidence bounds');
% hBound = findobj(h,'LineStyle',hBound.LineStyle, 'Color', hBound.Color);

% set(hFit,'color',c,'linewidth',lwFit)
% set(hBound,'color',c,'linestyle',':','linewidth',lwBound)

% hData.MarkerFaceColor = 'none';
% hData.MarkerEdgeColor = 'none';

% axis([0 1 0 1])
addUnityLine

xticks(ticks)
xlabel({'Inferred shape distortion'; 'Flash-Grab'})
xline(0)

yticks(ticks)
ylabel({'Inferred shape distortion'; 'Frame'})
yline(0)

text(-.35, .9, ['N = ',num2str(numel(hBarLength_FG))])

title ''
legend off
cleanplot

fprintf('\n*** FG median observed distortion: %4.2f', median(distortion_expected_FG))
fprintf('\n*** FE median observed distortion: %4.2f\n', median(distortion_expected_FE))

%% plot inferred distortion difference

subplot(2,2,2)

data_mat = (distortion_expected_FE-distortion_expected_FG) ...
    ./ distortion_expected_FG * 100;

scatterbar_median(data_mat);
errorbar(1, median(data_mat), MAD(data_mat), ...
    'o','color','k','linewidth',2,'marker','none')

xticks(1)
set(gca,'xcolor','none')

ylabel({'Inferred distortion difference (%)', '(Frame vs. Flash-Grab)'})
yticks(-150:150:300)
ylim([-150 300])
yline(0)

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
statbar(1,1,300,p)

pbaspect([1,3,1])
cleanplot

%% save figure
% set(gcf,'papersize',[8.3 11.7])
% saveas(gcf,'../results/fig04.pdf')


