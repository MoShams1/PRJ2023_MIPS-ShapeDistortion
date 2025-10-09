clc
clear
close all

load distortion_observed.mat
load click_positions.mat

% calculate inferred distortion
hBarLength_FG = frontDotX_FG - backDotX_FG;
hBarLength_FE = frontDotX_FE - backDotX_FE;

leftHand_FG = centerDotX_FG - backDotX_FG;
leftHand_FE = centerDotX_FE - backDotX_FE;

rightHand_FG = frontDotX_FG - centerDotX_FG;
rightHand_FE = frontDotX_FE - centerDotX_FE;

distortion_expected_FG = (leftHand_FG-rightHand_FG) ./ hBarLength_FG;
distortion_expected_FE = (leftHand_FE-rightHand_FE) ./ hBarLength_FE;


% calculate position shift
hBarCenter_FG = mean([backDotX_FG,centerDotX_FG,frontDotX_FG], 2);
hBarCenter_FE = mean([backDotX_FE,centerDotX_FE,frontDotX_FE], 2);

hBarCenter_FG_pop = mean(mean([backDotX_FG,centerDotX_FG,frontDotX_FG], 1));
hBarCenter_FE_pop = mean(mean([backDotX_FE,centerDotX_FE,frontDotX_FE], 1));


nsubjects = numel(distortion_expected_FG);

figure('units','inches','outerposition',[1 1 3.5 8])

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

text(2.3, -2.4, ['N = ',num2str(nsubjects)])
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

%%

figure('units','inches','outerposition',[1 1 8 8])

szMarker = 100;
alphaMarker = .4;
c = 'k';
ticks = -1:.5:2;
% lims = [-.6 2.2];

%% observed distortion vs. position shift (FG)
subplot(2,2,1)
hold on

scatter(hBarCenter_FG, distortion_observed_FG, ...
    szMarker, c, 'fill', ...
    'markerfacealpha',alphaMarker)

title 'Flash-Grab'

xlabel 'Position shift (dva)'
xline(0,'-')
xticks(ticks)
% xlim(lims)

ylabel 'Observed distortion'
yline(0,'-')
yticks(ticks)
% ylim(lims)

text(1.5, -.45, ['N = ',num2str(nsubjects)])

cleanplot

%% inferred distortion vs. position shift (FG)
subplot(2,2,2)
hold on

scatter(hBarCenter_FG, distortion_expected_FG, ...
    szMarker, c, 'fill', ...
    'markerfacealpha',alphaMarker)

title 'Flash-Grab'

xlabel 'Position shift (dva)'
xline(0,'-')
xticks(ticks)
% xlim(lims)

ylabel 'Inferred distortion'
yline(0,'-')
yticks(ticks)
% ylim(lims)

text(1.5, -.45, ['N = ',num2str(nsubjects)])

cleanplot

%% observed distortion vs. position shift (FE)
subplot(2,2,3)
hold on

scatter(hBarCenter_FE, distortion_observed_FE, ...
    szMarker, c, 'fill', ...
    'markerfacealpha',alphaMarker)

title 'Frame'

xlabel 'Position shift (dva)'
xline(0,'-')
xticks(ticks)
% xlim(lims)

ylabel 'Observed distortion'
yline(0,'-')
yticks(ticks)
% ylim(lims)

text(1.5, -.45, ['N = ',num2str(nsubjects)])

cleanplot

%% inferred distortion vs. position shift (FE)
subplot(2,2,4)
hold on

scatter(hBarCenter_FE, distortion_expected_FE, ...
    szMarker, c, 'fill', ...
    'markerfacealpha',alphaMarker)

title 'Frame'

xlabel 'Position shift (dva)'
xline(0,'-')
xticks(ticks)
% xlim(lims)

ylabel 'Inferred distortion'
yline(0,'-')
yticks(ticks)
% ylim(lims)

text(1.5, -.45, ['N = ',num2str(nsubjects)])

cleanplot
%% save figure
% set(gcf,'papersize',[8.3 11.7])
% saveas(gcf,'../results/fig05.pdf')


