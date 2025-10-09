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

distortion_inferred_FG = (leftHand_FG-rightHand_FG) ./ hBarLength_FG;
distortion_inferred_FE = (leftHand_FE-rightHand_FE) ./ hBarLength_FE;

% distortion_expected_FG_pop = (mean(leftHand_FG)-mean(rightHand_FG)) ./ ...
%     mean(hBarLength_FG);
% distortion_expected_FE_pop = (mean(leftHand_FE)-mean(rightHand_FE)) ./ ...
%     mean(hBarLength_FE);

nsubjects = length(distortion_inferred_FG);

%% plot bar: FG distortion vs. FE distortion

% figure('units','inches','outerposition',[0 0 4 4])
% hold on
% 
% data_mat = [distortion_inferred_FG, distortion_inferred_FE];
% xs = scatterbar_median(data_mat);
% errorbar(1:2, median(data_mat), MAD(data_mat), ...
%     'o','color','k','linewidth',2,'marker','none')
% % xs = scatterbar(data_mat);
% % errorbar(1:2, mean(data_mat), SE(data_mat), ...
% %     'o','color','k','linewidth',2,'marker','none')
% 
% plot(xs', data_mat', 'color', .5 * ones(1,3))
% 
% xticks(1:2)
% xticklabels({'FG', 'FE'})
% 
% ylabel 'Inferred distortion'
% yline(0,'-')
% % ylim([-.2 1])
% 
% text(2.2, -.15, ['N = ',num2str(nsubjects)])
% pbaspect([1,2,1])
% 
% cleanplot

%% plot scatter

% figure('units','inches','outerposition',[0 0 4 4])
% hold on
% 
% clines = lines(7);
% 
% szMarker = 100;
% alphaMarker = .5;
% c = 'k';
% c_median = clines(7,:);
% ticks = -2:.5:3;
% lims = [-1 2.2];
% 
% scatter(distortion_inferred_FG, distortion_inferred_FE, ...
%       szMarker, c, 'fill', ...
%       'markerfacealpha',alphaMarker);
% 
% % scatter(distortion_expected_FG_pop, distortion_expected_FE_pop, ...
% %       szMarker*1.5, c_median, 'x');
% 
% title 'Inferred distortion'
% 
% xlabel 'Flash-Grab'
% xline(0,'-')
% xticks(ticks)
% xlim(lims)
% 
% ylabel 'Frame'
% yline(0,'-')
% yticks(ticks)
% ylim(lims)
% 
% text(1.5, -.75, ['N = ',num2str(nsubjects)])
% 
% axis square
% addUnityLine
% 
% cleanplot
% 
% fprintf('\n*** FG median observed distortion: %4.2f', median(distortion_inferred_FG))
% fprintf('\n*** FE median observed distortion: %4.2f\n', median(distortion_inferred_FE))

%% plots

% plot scatter

figure('units','inches','outerposition',[0 0 7.5 4])

subplot(1,3,[1 2])
hold on

clines = lines(7);

szMarker = 100;
alphaMarker = .5;
c = 'k';
c_median = clines(7,:);
ticks = -10:.5:10;
lims = [-.7 2.2];

scatter(distortion_inferred_FG, distortion_inferred_FE, ...
    szMarker, c, 'fill', ...
    'markerfacealpha',alphaMarker)

% scatter(hBarCenter_FG_pop, hBarCenter_FE_pop, ...
%       szMarker*1.5, c_median, 'x');

% title 'Position shift (dva)'

xlabel 'Inferred shape distortion (Flash-Grab)'
xline(0,'-')
xticks(ticks)
xlim(lims)

ylabel 'Inferred shape distortion (Frame)'
yline(0,'-')
yticks(ticks)
ylim(lims)

text(1.5, .15, ['N = ',num2str(nsubjects)])

axis square
addUnityLine

cleanplot

fprintf([ ...    
    '\n -----------------------' ...
    '\n FE median inferred shape distortion = %4.2f'...
    '\n FG median inferred shape distortion = %4.2f\n'], ...
median(distortion_inferred_FE), ...
median(distortion_inferred_FG))


% plot difference

subplot(1,3,3)
hold on

data_mat = distortion_inferred_FE - distortion_inferred_FG;
xs = scatterbar_median(data_mat);
errorbar(1, median(data_mat), MAD(data_mat), ...
    'o','color','k','linewidth',2,'marker','none')

set(gca,'xcolor','none')

ylabel({'Inferred shape distortion difference', '(Frame – Flash-Grab)'})
yline(0,'-')
ylim([-1 2.2])

% stat
[delta, ~, p, W, z, r] = signrank_full(distortion_inferred_FE, distortion_inferred_FG);
fprintf([ ...
    '\n <Inferred distortion difference>' ...
    '\n -----------------------' ...
    '\n median difference = %4.2f'...
    '\n W = %5.2f' ...
    '\n z = %5.2f' ...
    '\n p = %5.3f' ...
    '\n r = %4.2f \n'], ...
delta,W,z,p,r)
statbar(1, 1, 2.2, p);

pbaspect([1,2,1])

cleanplot

%% save figure
set(gcf,'papersize',[8.3 11.7])
saveas(gcf,'../../results/fig06.pdf')


