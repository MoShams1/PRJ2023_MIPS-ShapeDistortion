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

distortion_expected_FG = (leftHand_FG-rightHand_FG) ./ hBarLength_FG;
distortion_expected_FE = (leftHand_FE-rightHand_FE) ./ hBarLength_FE;

nsubjects = numel(distortion_expected_FG);

figure('units','inches','outerposition',[1 1 3.5 8])

%% apply exclusion
% distortion_observed_FG(ind_exclude) = [];
% distortion_observed_FE(ind_exclude) = [];
% distortion_expected_FG(ind_exclude) = [];
% distortion_expected_FE(ind_exclude) = [];

%% click location order check
ind_FG = (frontDotX_FG > centerDotX_FG) > backDotX_FG;
ind_FE = (frontDotX_FE > centerDotX_FE) > backDotX_FE;
% distortion_expected_FG(~ind_FG) = [];
% distortion_observed_FG(~ind_FG) = [];
% distortion_expected_FE(~ind_FE) = [];
% distortion_observed_FE(~ind_FE) = [];

%% click location separation check
[~,sig1_FG] = signrank(frontDotX_FG, centerDotX_FG);
[~,sig2_FG] = signrank(frontDotX_FG, centerDotX_FG);
% ind_FE = (frontDotX_FE > centerDotX_FE) > backDotX_FE;
% distortion_expected_FG(~ind_FG) = [];
% distortion_observed_FG(~ind_FG) = [];
% distortion_expected_FE(~ind_FE) = [];
% distortion_observed_FE(~ind_FE) = [];

%% plot difference (FG)
subplot(2,1,1)

szMarker = 100;
alphaMarker = .4;
c = 'k';
ticks = -1:.5:2;
lims = [-.6 2.2];

hold on
scatter(distortion_expected_FG, distortion_observed_FG, ...
    szMarker, c, 'fill', ...
    'markerfacealpha',alphaMarker)

title 'Flash-Grab'

xlabel 'Inferred distortion'
xline(0,'-')
xticks(ticks)
xlim(lims)

ylabel 'Observed distortion'
yline(0,'-')
yticks(ticks)
ylim(lims)

text(1.5, -.45, ['N = ',num2str(nsubjects)])

axis square
addUnityLine

cleanplot

fprintf([ ...
    '\n <FG distortion>' ...
    '\n median observed: %4.2f' ...
    '\n median inferred: %4.2f\n'], ...
    median(distortion_observed_FG), ...
    median(distortion_expected_FG))

%% plot scatter (FE)
subplot(2,1,2)

scatter(distortion_expected_FE, distortion_observed_FE, ...
    szMarker, c, 'fill', ...
    'markerfacealpha',alphaMarker)

title 'Frame'

xlabel 'Inferred distortion'
xline(0,'-')
xticks(ticks)
xlim(lims)

ylabel 'Observed distortion'
yline(0,'-')
yticks(ticks)
ylim(lims)

text(1.5, -.45, ['N = ',num2str(nsubjects)])

axis square
addUnityLine

cleanplot

fprintf([ ...
    '\n <FE distortion>' ...
    '\n median observed: %4.2f' ...
    '\n median inferred: %4.2f\n'], ...
    median(distortion_observed_FE), ...
    median(distortion_expected_FE))


%% plot scatter observed-inferred distortion

figure('units','inches','outerposition',[0 0 4 4])
hold on

FG_diff = distortion_observed_FG - distortion_expected_FG;
FE_diff = distortion_observed_FE - distortion_expected_FE;

szMarker = 100;
alphaMarker = .4;
c = 'k';
ticks = -2:.5:2;
lims = [-1 1];

scatter(FG_diff, FE_diff, ...
    szMarker, c, 'fill', ...
    'markerfacealpha',alphaMarker)

title 'Distortion difference (Observed - Inferred)'

xlabel 'Flash-Grab'
xline(0,'-')
xticks(ticks)
xlim(lims)

ylabel 'Frame'
yline(0,'-')
yticks(ticks)
ylim(lims)

text(1.5, -.75, ['N = ',num2str(nsubjects)])

axis square
addUnityLine

cleanplot

%% plot observed-inferred distortion

figure('units','inches','outerposition',[0 0 4 4])

data_mat = [FG_diff, FE_diff];

xs = scatterbar_median(data_mat);
errorbar(1:2, median(data_mat), MAD(data_mat), ...
    'o','color','k','linewidth',2,'marker','none')

plot(xs', data_mat', 'color', .5 * ones(1,3))

xticks(1:2)
xticklabels({'FG', 'FE'})

ylabel({'Distortion'; '(observed - inferred)'})
yline(0,'-')
% ylim([-.2 1])

text(2.3, -1.4, ['N = ',num2str(nsubjects)])
pbaspect([1,2,1])

cleanplot

%%
[delta, ~, p, W, z, r] = signrank_full(FG_diff, FE_diff);
fprintf([ ...
    '\n <Distortion difference>' ...
    '\n -----------------------' ...
    '\n median difference = %4.1f'...
    '\n W = %5.2f' ...
    '\n z = %5.2f' ...
    '\n p = %5.3f' ...
    '\n r = %4.2f \n'], ...
delta,W,z,p,r)
statbar(1,2, 1, p);

%% save figure
% set(gcf,'papersize',[8.3 11.7])
% saveas(gcf,'../results/fig05.pdf')


