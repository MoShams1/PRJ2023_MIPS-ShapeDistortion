clc
clear
close all

load click_positions.mat

positionShift_FG = mean([backDotX_FG,centerDotX_FG,frontDotX_FG], 2);
positionShift_FE = mean([backDotX_FE,centerDotX_FE,frontDotX_FE], 2);

% hBarCenter_FG_pop = mean(mean([backDotX_FG,centerDotX_FG,frontDotX_FG], 1));
% hBarCenter_FE_pop = mean(mean([backDotX_FE,centerDotX_FE,frontDotX_FE], 1));

nsubjects = length(positionShift_FG);

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
ticks = 0:.5:10;
lims = [-0.2 2];

scatter(positionShift_FG, positionShift_FE, ...
    szMarker, c, 'fill', ...
    'markerfacealpha',alphaMarker)

% scatter(hBarCenter_FG_pop, hBarCenter_FE_pop, ...
%       szMarker*1.5, c_median, 'x');

% title 'Position shift (dva)'

xlabel 'Position shift [dva] (Flash-Grab)'
xline(0,'-')
xticks(ticks)
xlim(lims)

ylabel 'Position shift [dva] (Frame)'
yline(0,'-')
yticks(ticks)
ylim(lims)

text(1.5, .15, ['N = ',num2str(nsubjects)])

axis square
addUnityLine

cleanplot

fprintf([ ...    
    '\n -----------------------' ...
    '\n FE median position shift = %4.2f'...
    '\n FG median position shift = %4.2f\n'], ...
median(positionShift_FE), ...
median(positionShift_FG))


% plot difference

subplot(1,3,3)
hold on

subplot(1,3,3)
hold on

data_mat = positionShift_FE - positionShift_FG;
xs = scatterbar_median(data_mat);
errorbar(1, median(data_mat), MAD(data_mat), ...
    'o','color','k','linewidth',2,'marker','none')

set(gca,'xcolor','none')

ylabel({'Position shift difference [dva]', '(Frame – Flash-Grab)'})
yline(0,'-')
ylim([-.5 1.5])

% stat
[delta, ~, p, W, z, r] = signrank_full(positionShift_FE, positionShift_FG);
fprintf([ ...
    '\n <Position shift difference>' ...
    '\n -----------------------' ...
    '\n median difference = %4.2f [dva]'...
    '\n W = %5.2f' ...
    '\n z = %5.2f' ...
    '\n p = %5.3f' ...
    '\n r = %4.2f \n'], ...
delta,W,z,p,r)
statbar(1, 1, 1.5, p);

pbaspect([1,2,1])

cleanplot


%% save figure
set(gcf,'papersize',[8.3 11.7])
saveas(gcf,'../../results/fig05.pdf')


