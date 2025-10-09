clc
clear
close all

load distortion_observed.mat
load click_positions.mat

hBarLength_FG = frontDotX_FG - backDotX_FG;
hBarLength_FE = frontDotX_FE - backDotX_FE;

leftHand_FG = centerDotX_FG - backDotX_FG;
leftHand_FE = centerDotX_FE - backDotX_FE;

rightHand_FG = frontDotX_FG - centerDotX_FG;
rightHand_FE = frontDotX_FE - centerDotX_FE;

distortion_inferred_FG = (leftHand_FG-rightHand_FG) ./ hBarLength_FG;
distortion_inferred_FE = (leftHand_FE-rightHand_FE) ./ hBarLength_FE;

nsubjects = numel(distortion_inferred_FG);

%% apply exclusion
% distortion_observed_FG(ind_exclude) = [];
% distortion_observed_FE(ind_exclude) = [];
% distortion_expected_FG(ind_exclude) = [];
% distortion_expected_FE(ind_exclude) = [];

%% click location order check
% ind_FG = (frontDotX_FG > centerDotX_FG) > backDotX_FG;
% ind_FE = (frontDotX_FE > centerDotX_FE) > backDotX_FE;
% distortion_expected_FG(~ind_FG) = [];
% distortion_observed_FG(~ind_FG) = [];
% distortion_expected_FE(~ind_FE) = [];
% distortion_observed_FE(~ind_FE) = [];

%% click location separation check
% [~,sig1_FG] = signrank(frontDotX_FG, centerDotX_FG);
% [~,sig2_FG] = signrank(frontDotX_FG, centerDotX_FG);
% ind_FE = (frontDotX_FE > centerDotX_FE) > backDotX_FE;
% distortion_expected_FG(~ind_FG) = [];
% distortion_observed_FG(~ind_FG) = [];
% distortion_expected_FE(~ind_FE) = [];
% distortion_observed_FE(~ind_FE) = [];

%% plot FG

figure('units','inches','outerposition',[1 1 10 8])
subplot(2,4,[1 2])

szMarker = 100;
alphaMarker = .4;
c = 'k';
ticks = -1:.5:2;
scatter_lims = [-.75 2.3];
diff_lims = [-2.2 1.5];

hold on
scatter(distortion_inferred_FG, distortion_observed_FG, ...
    szMarker, c, 'fill', ...
    'markerfacealpha',alphaMarker)

xlabel 'Shape distortion (Inferred)'
xline(0,'-')
xticks(ticks)
xlim(scatter_lims)

ylabel 'Shape distortion (Observed)'
yline(0,'-')
yticks(ticks)
ylim(scatter_lims)

text(1.5, -.45, ['N = ',num2str(nsubjects)])

axis square
addUnityLine

cleanplot

[FG_corr_rho, FG_corr_p] = corr(distortion_inferred_FG,distortion_observed_FG, ...
    'type', 'spearman');

fprintf([ ...
    '\n <FG>' ...
    '\n -----------------------' ...
    '\n median observed distortion: %4.2f' ...
    '\n median inferred distortion: %4.2f\n'], ...
    median(distortion_observed_FG), ...
    median(distortion_inferred_FG))

fprintf([ ...
    '\n spearman rho: %4.2f' ...
    '\n pval: %5.2f'], ...
    FG_corr_rho, FG_corr_p)


% plot difference

subplot(2,4,3)
hold on

data_mat_FG = distortion_observed_FG - distortion_inferred_FG;
xs = scatterbar_median(data_mat_FG);
errorbar(1, median(data_mat_FG), MAD(data_mat_FG), ...
    'o','color','k','linewidth',2,'marker','none')

set(gca,'xcolor','none')

ylabel({'Shape distortion difference', '(Observed – Inferred)'})
yline(0,'-')
ylim(diff_lims)

[delta, ~, p, W, z, r] = signrank_full(distortion_inferred_FG, distortion_observed_FG);
fprintf([ ...    
    '\n -----------------------' ...
    '\n median difference = %4.2f'...
    '\n W = %5.2f' ...
    '\n z = %5.2f' ...
    '\n p = %5.3f' ...
    '\n r = %4.2f \n'], ...
delta,W,z,p,r)
statbar(1, 1, 1.5, p);

pbaspect([1,2,1])

cleanplot


%% plot FE

subplot(2,4,[5 6])

szMarker = 100;
alphaMarker = .4;
c = 'k';
ticks = -1:.5:2;
scatter_lims = [-.75 2.3];

hold on
scatter(distortion_inferred_FE, distortion_observed_FE, ...
    szMarker, c, 'fill', ...
    'markerfacealpha',alphaMarker)

xlabel 'Shape distortion (Inferred)'
xline(0,'-')
xticks(ticks)
xlim(scatter_lims)

ylabel 'Shape distortion (Observed)'
yline(0,'-')
yticks(ticks)
ylim(scatter_lims)

text(1.5, -.45, ['N = ',num2str(nsubjects)])

axis square
addUnityLine

cleanplot

[FE_corr_rho, FE_corr_p] = corr(distortion_inferred_FE,distortion_observed_FE, ...
    'type', 'spearman');

fprintf([ ...
    '\n <FE>' ...
    '\n -----------------------' ...
    '\n median observed distortion: %4.2f' ...
    '\n median inferred distortion: %4.2f\n'], ...
    median(distortion_observed_FE), ...
    median(distortion_inferred_FE))

fprintf([ ...
    '\n spearman rho: %4.2f' ...
    '\n pval: %5.2f'], ...
    FE_corr_rho, FE_corr_p)


% plot difference

subplot(2,4,7)
hold on

data_mat_FE = distortion_observed_FE - distortion_inferred_FE;
xs = scatterbar_median(data_mat_FE);
errorbar(1, median(data_mat_FE), MAD(data_mat_FE), ...
    'o','color','k','linewidth',2,'marker','none')

set(gca,'xcolor','none')

ylabel({'Shape distortion difference', '(Observed – Inferred)'})
yline(0,'-')
ylim(diff_lims)

[delta, ~, p, W, z, r] = signrank_full(distortion_inferred_FE, distortion_observed_FE);
fprintf([ ...    
    '\n -----------------------' ...
    '\n median difference = %4.2f'...
    '\n W = %5.2f' ...
    '\n z = %5.2f' ...
    '\n p = %5.3f' ...
    '\n r = %4.2f \n'], ...
delta,W,z,p,r)
statbar(1, 1, 1.5, p);

pbaspect([1,2,1])

cleanplot

axis_size = get(gca,'Position');

%%
% plot difference of the two differences
% figure
subplot(2,4,4)
% hold on

data_mat_diff = data_mat_FE - data_mat_FG;
xs = scatterbar_median(data_mat_diff);
errorbar(1, median(data_mat_diff), MAD(data_mat_diff), ...
    'o','color','k','linewidth',2,'marker','none')

set(gca,'xcolor','none')

ylabel({'Difference in shape distortion difference', '(Frame – Flash-Grab)'})
yline(0,'-')
ylim([-2.5 1])

[delta, ~, p, W, z, r] = signrank_full(data_mat_FE, data_mat_FG);
fprintf([ ...    
    '\n <FE vs. FG>' ...
    '\n -----------------------' ...
    '\n median difference = %4.2f'...
    '\n W = %5.2f' ...
    '\n z = %5.2f' ...
    '\n p = %5.3f' ...
    '\n r = %4.2f \n'], ...
delta,W,z,p,r)
statbar(1, 1, 1, p);

pbaspect([1,2,1])

cleanplot

set(gca,'Position',[.8 .5-axis_size(4)/2 axis_size(3) axis_size(4)])

%% save figure
set(gcf,'papersize',[8.3 11.7])
saveas(gcf,'../../results/fig07.pdf')


