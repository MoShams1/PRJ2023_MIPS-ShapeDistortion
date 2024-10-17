clc
clear
close all

load pse_norm.mat
load click_err_withoutFixation.mat

barLength = .95;
probeY = 4.82;

% FG
backDotX_FG = click_err_x_FG(:,1) - barLength;
centerDotX_FG = click_err_x_FG(:,2);
frontDotX_FG = click_err_x_FG(:,3) + barLength;
% barLength_perceived_FG = abs(frontDotX_FG - backDotX_FG);

backDotY_FG = click_err_y_FG(:,1) + probeY;
centerDotY_FG = click_err_y_FG(:,2) + probeY;
frontDotY_FG = click_err_y_FG(:,3) + probeY;

% FE
backDotX_FE = click_err_x_FE(:,1) - barLength;
centerDotX_FE = click_err_x_FE(:,2);
frontDotX_FE = click_err_x_FE(:,3) + barLength;
% barLength_perceived_FE = abs(frontDotX_FE - backDotX_FE);

backDotY_FE = click_err_y_FE(:,1) + probeY;
centerDotY_FE = click_err_y_FE(:,2) + probeY;
frontDotY_FE = click_err_y_FE(:,3) + probeY;


%% plot clicks X position
% figure('units','inches','outerposition',[5, 2, 12 ,8])
% 
% subplot(1,2,1)
% hold on
% for i = 1:13
%     line([-2 6], [i i], 'color','k')
% end
% scatter(backDotX_FG, 1:13, 'fill')
% scatter(centerDotX_FG, 1:13, 'fill')
% scatter(frontDotX_FG, 1:13, 'fill')
% xlabel 'Click X position (dva)'
% ylabel Subjects
% yticks(1:13)
% title FG
% cleanplot
% 
% subplot(1,2,2)
% hold on
% for i = 1:13
%     line([-2 6], [i i], 'color','k')
% end
% scatter(backDotX_FE, 1:13, 'fill')
% scatter(centerDotX_FE, 1:13, 'fill')
% scatter(frontDotX_FE, 1:13, 'fill')
% xlabel 'Click X position (dva)'
% ylabel Subjects
% yticks(1:13)
% title FE
% cleanplot

%% plot clicks Y position
% figure('units','inches','outerposition',[5, 2, 12 ,8])
% 
% subplot(1,2,1)
% hold on
% for i = 1:13
%     line([1 7], [i i], 'color','k')
% end
% scatter(backDotY_FG, 1:13, 'fill')
% scatter(centerDotY_FG, 1:13, 'fill')
% scatter(frontDotY_FG, 1:13, 'fill')
% xlabel 'Click Y position (dva)'
% xline(4.82)
% ylabel Subjects
% yticks(1:13)
% title FG
% cleanplot
% 
% subplot(1,2,2)
% hold on
% for i = 1:13
%     line([1 7], [i i], 'color','k')
% end
% scatter(backDotY_FE, 1:13, 'fill')
% scatter(centerDotY_FE, 1:13, 'fill')
% scatter(frontDotY_FE, 1:13, 'fill')
% xlabel 'Click Y position (dva)'
% xline(4.82)
% ylabel Subjects
% yticks(1:13)
% title FE
% cleanplot

%% 2D plot of the click positions

c = lines(7);
cback = c(2,:);
ccenter = zeros(1,3);
cfront = c(5,:);
marker_size_single = 200;
marker_size_pop = 10;
marker_alpha = .1;
line_width = 3;
probe_x = .95;
probe_y = 4.82;



figure('units','inches','outerposition',[0, 2, 15 ,8])

% FG
subplot(1,2,1)
hold on

plot(-probe_x, probe_y, ...
    '<', 'markersize',20, 'markeredgecolor',cback,'markerfacecolor',cback)
plot(0, probe_y, ...
    'o', 'markersize',20, 'markeredgecolor',ccenter,'markerfacecolor',ccenter)
plot(probe_x, probe_y, ...
    '>', 'markersize',20, 'markeredgecolor',cfront,'markerfacecolor',cfront)

scatter(backDotX_FG, backDotY_FG, marker_size_single, cback, 'fill', ...
    'marker','<','markerfacealpha',marker_alpha);
scatter(centerDotX_FG, centerDotY_FG, marker_size_single, ccenter, 'fill', ...
    'marker','o','markerfacealpha',marker_alpha);
scatter(frontDotX_FG, frontDotY_FG, marker_size_single, cfront, 'fill', ...
    'marker','>','markerfacealpha',marker_alpha);

errorbar(mean(backDotX_FG),mean(backDotY_FG), ...
    -SE(backDotY_FG), +SE(backDotY_FG), ...
    -SE(backDotX_FG), +SE(backDotX_FG), ...
    'o','color',cback,'markerfacecolor',cback, 'markeredgecolor','none', ...
    'markersize',marker_size_pop,'linewidth',line_width);
errorbar(mean(centerDotX_FG),mean(centerDotY_FG), ...
    -SE(centerDotY_FG), +SE(centerDotY_FG), ...
    -SE(centerDotX_FG), +SE(centerDotX_FG), ...
    'o','color',ccenter,'markerfacecolor',ccenter, 'markeredgecolor','none', ...
    'markersize',marker_size_pop,'linewidth',line_width);
errorbar(mean(frontDotX_FG),mean(frontDotY_FG), ...
    -SE(frontDotY_FG), +SE(frontDotY_FG), ...
    -SE(frontDotX_FG), +SE(frontDotX_FG), ...
    'o','color',cfront,'markerfacecolor',cfront, 'markeredgecolor','none', ...
    'markersize',marker_size_pop,'linewidth',line_width);


title FG
xlabel 'Horizontal position (dva)'
xticks(-2:2:6)
ylabel 'Vertical position (dva)'
yticks(0:2:8)
axis([-2 6 0 8])
axis square
cleanplot_poster



% FE
subplot(1,2,2)
hold on

plot(-probe_x, probe_y, ...
    '<', 'markersize',20, 'markeredgecolor',cback,'markerfacecolor',cback)
plot(0, probe_y, ...
    'o', 'markersize',20, 'markeredgecolor',ccenter,'markerfacecolor',ccenter)
plot(probe_x, probe_y, ...
    '>', 'markersize',20, 'markeredgecolor',cfront,'markerfacecolor',cfront)

scatter(backDotX_FE, backDotY_FE, marker_size_single, cback, 'fill', ...
    'marker','<','markerfacealpha',marker_alpha);
scatter(centerDotX_FE, centerDotY_FE, marker_size_single, ccenter, 'fill', ...
    'marker','o','markerfacealpha',marker_alpha);
scatter(frontDotX_FE, frontDotY_FE, marker_size_single, cfront, 'fill', ...
    'marker','>','markerfacealpha',marker_alpha);

errorbar(mean(backDotX_FE),mean(backDotY_FE), ...
    -SE(backDotY_FE), +SE(backDotY_FE), ...
    -SE(backDotX_FE), +SE(backDotX_FE), ...
    'o','color',cback,'markerfacecolor',cback, 'markeredgecolor','none', ...
    'markersize',marker_size_pop,'linewidth',line_width);
errorbar(mean(centerDotX_FE),mean(centerDotY_FE), ...
    -SE(centerDotY_FE), +SE(centerDotY_FE), ...
    -SE(centerDotX_FE), +SE(centerDotX_FE), ...
    'o','color',ccenter,'markerfacecolor',ccenter, 'markeredgecolor','none', ...
    'markersize',marker_size_pop,'linewidth',line_width);
errorbar(mean(frontDotX_FE),mean(frontDotY_FE), ...
    -SE(frontDotY_FE), +SE(frontDotY_FE), ...
    -SE(frontDotX_FE), +SE(frontDotX_FE), ...
    'o','color',cfront,'markerfacecolor',cfront, 'markeredgecolor','none', ...
    'markersize',marker_size_pop,'linewidth',line_width);


title FE
xlabel 'Horizontal position (dva)'
xticks(-2:2:6)
ylabel 'Vertical position (dva)'
yticks(0:2:8)
axis([-2 6 0 8])
axis square
cleanplot_poster

set(gcf,'paperSize',[15 15])
saveas(gcf,'../../results/fig03A.pdf')

%% plot bar lengths
% 
% x_labels = {'FG','FE'};
% 
% figure('units','inches','outerposition',[7 2 12 10])
% subplot(1,2,1)
% 
% data_mat = [barLength_perceived_FG, barLength_perceived_FE];
% xs = scatterbar(data_mat);
% plot(xs', data_mat', 'color',.5.*ones(1,3))
% errorbar(1:2, mean(data_mat), SE(data_mat), ...
%     'o','color','k','linewidth',2,'marker','none')
% 
% xticks(1:2)
% xticklabels(x_labels)
% 
% ylabel({'Shape distortion index', '(in direction of motion)'})
% % ylim([-.1 .5])
% % yticks(0:.25:.5)
% yline(0)
% 
% text(1.5, -.05, 'N = 13', 'horizontalalignment','center');
% 
% cleanplot_poster
% 
% 
% subplot(1,2,2)
% data_mat = (barLength_perceived_FG-barLength_perceived_FE)./barLength_perceived_FG*100;
% xs = scatterbar(data_mat);
% errorbar(1, mean(data_mat), SE(data_mat), ...
%     'o','color','k','linewidth',2,'marker','none')
% 
% xticks(1)
% xticklabels({'FG vs FE'})
% 
% ylabel({'Difference (%)'})
% % ylim([-50 100])
% % yticks(-50:50:100)
% yline(0)
% 
% text(1, -35, 'N = 13', 'horizontalalignment','center');
% 
% pbaspect([.3 1 1])
% cleanplot_poster
% 
% % add stats
% 
% [delta, deltap, p, W, z, r] = signrank_full( ...
%     barLength_perceived_FG, ...
%     barLength_perceived_FE);
% fprintf([ ...
%     '\n <Horizontal bar length>' ...
%     '\n -----------' ...
%     '\n mean decrease = %4.1f dva' ...
%     '\n mean decrease = %3.0f %%' ...
%     '\n W = %5.2f' ...
%     '\n z = %5.2f' ...
%     '\n p = %5.3f' ...
%     '\n r = %4.2f \n'], ...
% delta,deltap,W,z,p,r)
% subplot(1,2,1)
% statbar_poster(1,2, .45, p);
% 
% [delta, deltap, p, W, z, r] = signrank_full( ...
%     (barLength_perceived_FG-barLength_perceived_FE) ...
%     ./barLength_perceived_FE*100);
% fprintf([ ...
%     '\n <Horizontal bar length difference>' ...
%     '\n -----------' ...
%     '\n mean decrease = %4.1f pp' ...
%     '\n mean decrease = %3.0f %%' ...
%     '\n W = %5.2f' ...
%     '\n z = %5.2f' ...
%     '\n p = %5.3f' ...
%     '\n r = %4.2f \n'], ...
% delta,deltap,W,z,p,r)
% subplot(1,2,2)
% statbar_poster(1,1, 90, p);
% 
% set(gcf, 'PaperSize',[12 12])

%%

% function xs = scatterbar(A)
% % A: a cell of cetegories
% 
% A = mat2cell(A, size(A,1), ones(1, size(A,2)));
% 
% ncat    = numel(A); % number of categories
% stdx    = .04; % standard deviation of scatters in each category
% mean_line_length  = .4; % line length for mean
% mean_line_width = 5;
% marksz  = 100; % marker size
% alpha = .15;
% 
% hold on
% for icat = 1:ncat    
%     rng default
%     n = numel(A{icat});
%     x = randn(n,1)*stdx + icat;
%     xs(:,icat) = x;
%     
%     scatter(x,A{icat},marksz,'k','o','filled','markerfacealpha',alpha);
%     line([icat-mean_line_length icat+mean_line_length],[mean(A{icat}) mean(A{icat})],...
%         'color','k','linewidth',mean_line_width);
% end
% 
% xlim([0 ncat+1])
% set(gca,'xtick',1:ncat)
% end
