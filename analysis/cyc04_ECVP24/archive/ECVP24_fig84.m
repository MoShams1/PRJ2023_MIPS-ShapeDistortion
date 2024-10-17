clc
clear
close all

load pse_norm.mat
load click_err_withoutFixation.mat

barLength = .95;

% FG
backDotX_FG = click_err_FG(:,1) - barLength;
centerDotX_FG = click_err_FG(:,2);
frontDotX_FG = click_err_FG(:,3) + barLength;
barLength_perceived_FG = abs(frontDotX_FG - backDotX_FG);

leftHand_FG = abs(centerDotX_FG - backDotX_FG);
rightHand_FG = abs(centerDotX_FG - frontDotX_FG);
pse_norm_FG_expected = (leftHand_FG-rightHand_FG) ./ barLength_perceived_FG;

% FE
backDotX_FE = click_err_FE(:,1) - barLength;
centerDotX_FE = click_err_FE(:,2);
frontDotX_FE = click_err_FE(:,3) + barLength;
barLength_perceived_FE = abs(frontDotX_FE - backDotX_FE);

leftHand_FE = abs(centerDotX_FE - backDotX_FE);
rightHand_FE = abs(centerDotX_FE - frontDotX_FE);
pse_norm_FE_expected = (leftHand_FE-rightHand_FE) ./ barLength_perceived_FE;

%% plot clicks
figure('units','inches','outerposition',[5, 2, 12 ,8])

subplot(1,2,1)
hold on
for i = 1:13
    line([-2 6], [i i], 'color','k')
end
scatter(backDotX_FG, 1:13, 'fill')
scatter(centerDotX_FG, 1:13, 'fill')
scatter(frontDotX_FG, 1:13, 'fill')
title FG
cleanplot

subplot(1,2,2)
hold on
for i = 1:13
    line([-2 6], [i i], 'color','k')
end
scatter(backDotX_FE, 1:13, 'fill')
scatter(centerDotX_FE, 1:13, 'fill')
scatter(frontDotX_FE, 1:13, 'fill')
title FE
cleanplot

%% plot bar lengths

x_labels = {'FG','FE'};

figure('units','inches','outerposition',[7 2 12 10])
subplot(1,2,1)

data_mat = [barLength_perceived_FG, barLength_perceived_FE];
xs = scatterbar(data_mat);
plot(xs', data_mat', 'color',.5.*ones(1,3))
errorbar(1:2, mean(data_mat), SE(data_mat), ...
    'o','color','k','linewidth',2,'marker','none')

xticks(1:2)
xticklabels(x_labels)

ylabel({'Shape distortion index', '(in direction of motion)'})
% ylim([-.1 .5])
% yticks(0:.25:.5)
yline(0)

text(1.5, -.05, 'N = 13', 'horizontalalignment','center');

cleanplot_poster


subplot(1,2,2)
data_mat = (barLength_perceived_FG-barLength_perceived_FE)./barLength_perceived_FG*100;
xs = scatterbar(data_mat);
errorbar(1, mean(data_mat), SE(data_mat), ...
    'o','color','k','linewidth',2,'marker','none')

xticks(1)
xticklabels({'FG vs FE'})

ylabel({'Difference (%)'})
% ylim([-50 100])
% yticks(-50:50:100)
yline(0)

text(1, -35, 'N = 13', 'horizontalalignment','center');

pbaspect([.3 1 1])
cleanplot_poster

% add stats

[delta, deltap, p, W, z, r] = signrank_full( ...
    barLength_perceived_FG, ...
    barLength_perceived_FE);
fprintf([ ...
    '\n <Horizontal bar length>' ...
    '\n -----------' ...
    '\n mean decrease = %4.1f dva' ...
    '\n mean decrease = %3.0f %%' ...
    '\n W = %5.2f' ...
    '\n z = %5.2f' ...
    '\n p = %5.3f' ...
    '\n r = %4.2f \n'], ...
delta,deltap,W,z,p,r)
subplot(1,2,1)
statbar_poster(1,2, .45, p);

[delta, deltap, p, W, z, r] = signrank_full( ...
    (barLength_perceived_FG-barLength_perceived_FE) ...
    ./barLength_perceived_FE*100);
fprintf([ ...
    '\n <Horizontal bar length difference>' ...
    '\n -----------' ...
    '\n mean decrease = %4.1f pp' ...
    '\n mean decrease = %3.0f %%' ...
    '\n W = %5.2f' ...
    '\n z = %5.2f' ...
    '\n p = %5.3f' ...
    '\n r = %4.2f \n'], ...
delta,deltap,W,z,p,r)
subplot(1,2,2)
statbar_poster(1,1, 90, p);

set(gcf, 'PaperSize',[12 12])

%% plot expected distortion

figure('units','inches','outerposition',[5, 2, 12 ,8])

marker_size = 200;
marker_alpha = .5;

subplot(1,2,1)
scatter(pse_norm_FG, pse_norm_FG_expected, ...
    marker_size,'k','fill','markerfacealpha',marker_alpha)
title 'Flash-Grab'
xlabel 'Observed distortion'
ylabel 'Expected distortion'
xticks(0:.5:1)
yticks(0:.5:1)
axis([-.1 1.1 -.1 1.1])
addUnityLine
axis square
cleanplot_poster

subplot(1,2,2)
scatter(pse_norm_FE, pse_norm_FE_expected, ...
    marker_size,'k','fill','markerfacealpha',marker_alpha)
title 'Frame'
xlabel 'Observed distortion'
ylabel 'Expected distortion'
xticks(0:.5:1)
yticks(0:.5:1)
axis([-.4 1.2 -.4 1.2])
addUnityLine
axis square
cleanplot_poster

%%

function xs = scatterbar(A)
% A: a cell of cetegories

A = mat2cell(A, size(A,1), ones(1, size(A,2)));

ncat    = numel(A); % number of categories
stdx    = .04; % standard deviation of scatters in each category
mean_line_length  = .4; % line length for mean
mean_line_width = 5;
marksz  = 100; % marker size
alpha = .15;

hold on
for icat = 1:ncat    
    rng default
    n = numel(A{icat});
    x = randn(n,1)*stdx + icat;
    xs(:,icat) = x;
    
    scatter(x,A{icat},marksz,'k','o','filled','markerfacealpha',alpha);
    line([icat-mean_line_length icat+mean_line_length],[mean(A{icat}) mean(A{icat})],...
        'color','k','linewidth',mean_line_width);
end

xlim([0 ncat+1])
set(gca,'xtick',1:ncat)
end



function addUnityLine()
x_limits = xlim;
y_limits = ylim;
min_val = min([x_limits, y_limits]);
max_val = max([x_limits, y_limits]);
line([min_val max_val], [min_val max_val], 'color','k')
end
