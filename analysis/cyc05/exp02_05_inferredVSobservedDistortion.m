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

figure('units','inches','outerposition',[1 1 3.5 8])

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
alphaMarker = .2;
c = 'k';
ticks = -1:.25:1;

hold on
scatter(distortion_expected_FG, distortion_observed_FG, ...
    szMarker, c, 'fill', ...
    'markerfacealpha',alphaMarker)

axis([-1 1 -1 1])
addUnityLine

xticks(ticks)
xlabel 'Inferred distortion'
xline(0)

yticks(ticks)
ylabel 'Observed distortion'
yline(0)

text(.05, .9, ['N = ',num2str(numel(distortion_expected_FG))])

title ''
legend off
cleanplot

fprintf([ ...
    '\n <FG distortion>' ...
    '\n median observed: %4.2f' ...
    '\n median inferred: %4.2f\n'], ...
    median(distortion_observed_FG), ...
    median(distortion_expected_FG))

cleanplot

%% plot scatter (FE)
subplot(2,1,2)

scatter(distortion_expected_FE, distortion_observed_FE, ...
    szMarker, c, 'fill', ...
    'markerfacealpha',alphaMarker)

axis([-1 1 -1 1])
addUnityLine

xticks(ticks)
xlabel 'Inferred distortion'
xline(0)

yticks(ticks)
ylabel 'Observed distortion'
yline(0)

text(.05, .9, ['N = ',num2str(numel(distortion_expected_FE))])

title ''
legend off
cleanplot

fprintf([ ...
    '\n <FE distortion>' ...
    '\n median observed: %4.2f' ...
    '\n median inferred: %4.2f\n'], ...
    median(distortion_observed_FE), ...
    median(distortion_expected_FE))

cleanplot

%% save figure
% set(gcf,'papersize',[8.3 11.7])
% saveas(gcf,'../results/fig05.pdf')


