clc
clear
close all

load pse_norm.mat
load click_err_withoutFixation.mat

barLength = .95;
probeY = 4.82;

% FG
backDotX_FG = click_err_x_FG(:,1) - barLength;
frontDotX_FG = click_err_x_FG(:,3) + barLength;
shapeX_FG = mean([backDotX_FG, frontDotX_FG], 2);

% FE
backDotX_FE = click_err_x_FE(:,1) - barLength;
frontDotX_FE = click_err_x_FE(:,3) + barLength;
shapeX_FE = mean([backDotX_FE, frontDotX_FE], 2);

%% overall shape position shift

figure

subplot(1,2,1)
data_mat = [shapeX_FG, shapeX_FE];
xs = scatterbar(data_mat);
plot(xs', data_mat', 'color',.5.*ones(1,3))
errorbar(1:2, mean(data_mat), SE(data_mat), ...
    'o','color','k','linewidth',2,'marker','none')

xticks(1:2)
xticklabels({'FG', 'FE'})

ylabel({'Shape position shift (dva)'})
ylim([0 5])
yticks(-5:1:10)
yline(0)

% text(1, -35, 'N = 13', 'horizontalalignment','center');

% pbaspect([.3 1 1])
cleanplot_poster



subplot(1,2,2)
data_mat = (shapeX_FE-shapeX_FG) ./ shapeX_FG * 100;
scatterbar(data_mat);
errorbar(1, mean(data_mat), SE(data_mat), ...
    'o','color','k','linewidth',2,'marker','none')

xticks(1)
set(gca,'xcolor','none')

ylabel({'Difference (%)'})
ylim([0 250])
yticks(0:100:250)
yline(0,'--')

% text(1, -35, 'N = 13', 'horizontalalignment','center');

pbaspect([.3 1 1])
cleanplot_poster



% add stats

[delta, deltap, p, W, z, r] = signrank_full(pse_norm_FG, pse_norm_FE);
fprintf([ ...
    '\n <Norm. distortion>' ...
    '\n ------------------' ...
    '\n mean decrease = %4.1f dva' ...
    '\n mean decrease = %3.0f %%' ...
    '\n W = %5.2f' ...
    '\n z = %5.2f' ...
    '\n p = %5.3f' ...
    '\n r = %4.2f \n'], ...
delta,deltap,W,z,p,r)
subplot(1,2,1)
statbar_poster(1,2, 5, p);

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
