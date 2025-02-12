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


%% plot difference (FG)
subplot(2,2,1)

szMarker = 100;
alphaMarker = .2;
c = 'k';
ticks = 0:.25:1;

hold on
scatter(distortion_expected_FG, distortion_observed_FG, ...
    szMarker, c, 'fill', ...
    'markerfacealpha',alphaMarker)

% axis([-.1 1 -.1 1])
addUnityLine

xticks(ticks)
xlabel 'Inferred distortion'
xline(0)

yticks(ticks)
ylabel 'Observed distortion'
yline(0)

text(.05, .9, ['N = ',num2str(numel(hBarLength_FG))])

title ''
legend off
cleanplot

fprintf([ ...
    '\n <FG distortion>' ...
    '\n median observed: %4.2f' ...
    '\n median inferred: %4.2f\n'], ...
    median(distortion_observed_FG), ...
    median(distortion_expected_FG))

% ------------------- plot difference
subplot(2,2,2)

% data_mat = hBarCenter_FE./hBarCenter_FG;
data_mat = (distortion_observed_FG-distortion_expected_FG)./distortion_expected_FG*100;

scatterbar_median(data_mat);
errorbar(1, median(data_mat), MAD(data_mat), ...
    'o','color','k','linewidth',2,'marker','none')

xticks(1)
set(gca,'xcolor','none')

ylabel({'Distortion difference (%)'; '(Observed vs. Inferred)'})
yticks(-200:50:200)
% ylim([-200 50])
yline(0,'-')

% add statistics
[delta, ~, p, W, z, r] = signrank_full(data_mat);
fprintf([ ...
    '\n <Distortion difference FG (Observed vs. Inferred>' ...
    '\n -----------------------' ...
    '\n median difference = %4.1f %%' ...
    '\n W = %5.2f' ...
    '\n z = %5.2f' ...
    '\n p = %5.3f' ...
    '\n r = %4.2f \n'], ...
delta,W,z,p,r)
statbar(1,1,-210,p)

pbaspect([1,3,1])
cleanplot

%% plot scatter (FE)
subplot(2,2,3)

hold on
scatter(distortion_expected_FE, distortion_observed_FE, ...
    szMarker, c, 'fill', ...
    'markerfacealpha',alphaMarker)

% axis([-.1 1 -.1 1])
addUnityLine

xticks(ticks)
xlabel 'Inferred distortion'
xline(0)

yticks(ticks)
ylabel 'Observed distortion'
yline(0)

text(.05, .9, ['N = ',num2str(numel(hBarLength_FG))])

title ''
legend off
cleanplot

fprintf([ ...
    '\n <FE distortion>' ...
    '\n median observed: %4.2f' ...
    '\n median inferred: %4.2f\n'], ...
    median(distortion_observed_FE), ...
    median(distortion_expected_FE))

% ------------------- plot difference
subplot(2,2,4)

data_mat = (distortion_observed_FE-distortion_expected_FE)./distortion_expected_FE*100;

scatterbar_median(data_mat);
errorbar(1, median(data_mat), MAD(data_mat), ...
    'o','color','k','linewidth',2,'marker','none')

xticks(1)
set(gca,'xcolor','none')

ylabel({'Distortion difference (%)'; '(Observed vs. Inferred)'})
yticks(-200:50:200)
% ylim([-200 50])
yline(0,'-')

% add statistics
[delta, ~, p, W, z, r] = signrank_full(data_mat);
fprintf([ ...
    '\n <Distortion difference FE (Observed vs. Inferred>' ...
    '\n -----------------------' ...
    '\n median difference = %4.1f %%' ...
    '\n W = %5.2f' ...
    '\n z = %5.2f' ...
    '\n p = %5.3f' ...
    '\n r = %4.2f \n'], ...
delta,W,z,p,r)
statbar(1,1,-210,p)

pbaspect([1,3,1])
cleanplot

%% Flash-Grab vs. Frame (difference comparison)
data_mat_FG = (distortion_observed_FG-distortion_expected_FG)./distortion_expected_FG*100;
data_mat_FE = (distortion_observed_FE-distortion_expected_FE)./distortion_expected_FE*100;
[delta, ~, p, W, z, r] = signrank_full(data_mat_FG, data_mat_FE);
fprintf([ ...
    '\n <Distortion difference comparison (FG vs. FE>' ...
    '\n -----------------------' ...
    '\n median difference = %4.1f %%' ...
    '\n W = %5.2f' ...
    '\n z = %5.2f' ...
    '\n p = %5.3f' ...
    '\n r = %4.2f \n'], ...
delta,W,z,p,r)

%% save figure
% set(gcf,'papersize',[8.3 11.7])
% saveas(gcf,'../results/fig05.pdf')


