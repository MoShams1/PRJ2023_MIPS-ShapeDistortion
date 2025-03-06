clc
clear
close all

load click_positions.mat

hBarLength_FG = frontDotX_FG - backDotX_FG;
hBarLength_FE = frontDotX_FE - backDotX_FE;

leftHand_FG = centerDotX_FG - backDotX_FG;
leftHand_FE = centerDotX_FE - backDotX_FE;

rightHand_FG = frontDotX_FG - centerDotX_FG;
rightHand_FE = frontDotX_FE - centerDotX_FE;

distortion_expected_FG = (leftHand_FG-rightHand_FG) ./ hBarLength_FG;
distortion_expected_FE = (leftHand_FE-rightHand_FE) ./ hBarLength_FE;

nsubjects = length(distortion_expected_FG);

%% plot bar: FG distortion vs. FE distortion

figure('units','inches','outerposition',[0 0 4 4])
hold on

data_mat = [distortion_expected_FG, distortion_expected_FE];
xs = scatterbar_median(data_mat);
errorbar(1:2, median(data_mat), MAD(data_mat), ...
    'o','color','k','linewidth',2,'marker','none')
% xs = scatterbar(data_mat);
% errorbar(1:2, mean(data_mat), SE(data_mat), ...
%     'o','color','k','linewidth',2,'marker','none')

plot(xs', data_mat', 'color', .5 * ones(1,3))

xticks(1:2)
xticklabels({'FG', 'FE'})

ylabel 'Distortion'
yline(0,'-')
% ylim([-.2 1])

text(2.2, -.15, ['N = ',num2str(nsubjects)])
pbaspect([1,2,1])

cleanplot

%% plot scatter

figure('units','inches','outerposition',[0 0 4 4])
hold on

szMarker = 100;
alphaMarker = .4;
c = 'k';
ticks = -2:.5:3;
lims = [-1 2];

scatter(distortion_expected_FG, distortion_expected_FE, ...
      szMarker, c, 'fill', ...
      'markerfacealpha',alphaMarker);

title 'Inferred distortion'

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

fprintf('\n*** FG median observed distortion: %4.2f', median(distortion_expected_FG))
fprintf('\n*** FE median observed distortion: %4.2f\n', median(distortion_expected_FE))

%% plot inferred distortion difference

% figure
% 
% data_mat = (distortion_expected_FE-distortion_expected_FG) ...
%     ./ distortion_expected_FG * 100;
% 
% scatterbar_median(data_mat);
% errorbar(1, median(data_mat), MAD(data_mat), ...
%     'o','color','k','linewidth',2,'marker','none')
% 
% xticks(1)
% set(gca,'xcolor','none')
% 
% ylabel({'Inferred distortion difference (%)', '(Frame vs. Flash-Grab)'})
% yticks(0:50:150)
% % ylim([-10 150])
% yline(0)
% 
% % add statistics
% [delta, deltap, p, W, z, r] = signrank_full(data_mat);
% fprintf([ ...
%     '\n <Distortion difference>' ...
%     '\n -----------------------' ...
%     '\n mean decrease = %4.1f pp' ...
%     '\n mean decrease = %3.0f %%' ...
%     '\n W = %5.2f' ...
%     '\n z = %5.2f' ...
%     '\n p = %5.3f' ...
%     '\n r = %4.2f \n'], ...
% delta,deltap,W,z,p,r)
% statbar(1,1,150,p)
% 
% pbaspect([1,3,1])
% cleanplot

%% save figure
% set(gcf,'papersize',[8.3 11.7])
% saveas(gcf,'../results/fig04.pdf')


