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

figure('units','inches','outerposition',[1 1 6 6])
% sgtitle 'Expected distortion'



%% plot difference

subplot(2,2,[1 3])

data_mat = [distortion_expected_FE, distortion_expected_FG];

xs = scatterbar(data_mat);
plot(xs',data_mat','color',.5.*ones(1,3))
errorbar(1:2, mean(data_mat), SE(data_mat), ...
    'o','color','k','linewidth',2,'marker','none')

xticks(1:2)
xticklabels({'FG','FE'})

ylabel 'Distortion'
yticks(-10:.5:10)
ylim([-.5 1.3])
yline(0,'-')

% add statistics
[delta, deltap, p, W, z, r] = signrank_full(data_mat(:,1),data_mat(:,2));
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
statbar(1,2,1,p)

pbaspect([1,2,1])
cleanplot



%% plot scatters

% FG

subplot(2,2,2)

szMarker = 100;
alphaMarker = .2;
lwFit = 3;
lwBound = 2.5;
c = 'k';
axis_limits = [-.5 1 -.5 1];
ticks = -1:.5:1;

% hold on
scatter(distortion_expected_FG, distortion_observed_FG, ...
    szMarker, c, 'fill', ...
    'markerfacealpha',alphaMarker)

axis(axis_limits)
addUnityLine
axis square

xticks(ticks)
% xlabel 'Expected distortion'
xline(0)

yticks(ticks)
% ylabel 'Observed distortion'
yline(0)

title 'Flash-Grab'
cleanplot



% FE

subplot(2,2,4)

% hold on
scatter(distortion_expected_FE, distortion_observed_FE, ...
    szMarker, c, 'fill', ...
    'markerfacealpha',alphaMarker)

axis(axis_limits)
addUnityLine
axis square

xticks(ticks)
% xlabel 'Expected distortion'
xline(0)

yticks(ticks)
% ylabel 'Observed distortion'
yline(0)

title 'Frame'
cleanplot



%% save figure
set(gcf,'papersize',[10 10])
saveas(gcf,'../../results/ecvp24_fig05.pdf')


