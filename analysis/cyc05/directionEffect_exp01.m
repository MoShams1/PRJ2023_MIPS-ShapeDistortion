clc
clear
close all

all_files = dir('../../data/cyc05/*exp01*');

ind_exclude = 6;

for isubj = 1:numel(all_files)

    jsonFilePath = fullfile( ...
        all_files(isubj).folder, ...
        all_files(isubj).name);

    % Open the JSON file and read its content
    fileID = fopen(jsonFilePath);
    jsonContent = fread(fileID, '*char')';
    fclose(fileID);

    % Parse the JSON content
    jsonData = jsondecode(jsonContent);

    clear jsonFilePath jsonContent fileID

    % convert structure to arrays
    typ = struct2cell(jsonData.stimulus_type);
    dir = cell2mat(struct2cell(jsonData.postflash_direction));
    pse_dva = cell2mat(struct2cell(jsonData.pse_dva));
    pse_norm = cell2mat(struct2cell(jsonData.pse_normalized));
    loop_cnt = cell2mat(struct2cell(jsonData.loop_count));

    pse_norm(dir>0) = -pse_norm(dir>0);
    distortion_observed_FG_R(isubj,1)  = mean(pse_norm(strcmp(typ, 'FG') & dir>0));
    distortion_observed_FE_R(isubj,1)  = mean(pse_norm(strcmp(typ, 'FE') & dir>0));
    distortion_observed_FG_L(isubj,1)  = mean(pse_norm(strcmp(typ, 'FG') & dir<0));
    distortion_observed_FE_L(isubj,1)  = mean(pse_norm(strcmp(typ, 'FE') & dir<0));

end

%% apply exclusion
distortion_observed_FG_R(ind_exclude) = [];
distortion_observed_FG_L(ind_exclude) = [];
distortion_observed_FE_R(ind_exclude) = [];
distortion_observed_FE_L(ind_exclude) = [];
nsubjects = numel(distortion_observed_FG_R);

%% save distortion magnitudes of each individual in FG and FE
% 
% save distortion_observed.mat ...
%     distortion_observed_FG ...
%     distortion_observed_FE

%% plot bar: FG distortion vs. FE distortion

% figure('units','inches','outerposition',[0 0 4 4])
% hold on
% 
% data_mat = [distortion_observed_FG, distortion_observed_FE];
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
% ylabel 'Distortion'
% yline(0,'-')
% ylim([-.2 1])
% 
% text(2.2, -.15, ['N = ',num2str(nsubjects)])
% pbaspect([1,2,1])
% 
% cleanplot

%% stat
[delta, ~, p, W, z, r] = signrank_full(distortion_observed_FG_R, distortion_observed_FG_L);
fprintf([ ...
    '\n <Distortion difference across directions in FG>' ...
    '\n -----------------------' ...
    '\n median difference = %4.2f'...
    '\n W = %5.2f' ...
    '\n z = %5.2f' ...
    '\n p = %5.3f' ...
    '\n r = %4.2f \n'], ...
delta,W,z,p,r)

[delta, ~, p, W, z, r] = signrank_full(distortion_observed_FE_R, distortion_observed_FE_L);
fprintf([ ...
    '\n <Distortion difference across directions in FE>' ...
    '\n -----------------------' ...
    '\n median difference = %4.2f'...
    '\n W = %5.2f' ...
    '\n z = %5.2f' ...
    '\n p = %5.3f' ...
    '\n r = %4.2f \n'], ...
delta,W,z,p,r)


%% FG

figure('units','inches','outerposition',[0 0 7.5 4])

% plot scatter

subplot(1,3,[1 2])
hold on

szMarker = 100;
alphaMarker = .4;
c = 'k';
ticks = -1:.25:1;
lims = [-.2 1];

scatter(distortion_observed_FG_R, distortion_observed_FG_L, ...
      szMarker, c, 'fill', ...
      'markerfacealpha',alphaMarker);

% title 'Shape distortion'

xlabel 'Distortion (Flash-Grab Right)'
xline(0,'-')
xticks(ticks)
xlim(lims)

ylabel 'Distortion (Flash-Grab Left)'
yline(0,'-')
yticks(ticks)
ylim(lims)

text(.05, .9, ['N = ',num2str(nsubjects)])

axis square
addUnityLine

cleanplot


%% FE

figure('units','inches','outerposition',[0 0 7.5 4])

% plot scatter

subplot(1,3,[1 2])
hold on

szMarker = 100;
alphaMarker = .4;
c = 'k';
ticks = -1:.25:1;
lims = [-.2 1];

scatter(distortion_observed_FE_R, distortion_observed_FE_L, ...
      szMarker, c, 'fill', ...
      'markerfacealpha',alphaMarker);

% title 'Shape distortion'

xlabel 'Distortion (Frame Effect Right)'
xline(0,'-')
xticks(ticks)
xlim(lims)

ylabel 'Distortion (Frame Effect Left)'
yline(0,'-')
yticks(ticks)
ylim(lims)

text(.05, .9, ['N = ',num2str(nsubjects)])

axis square
addUnityLine

cleanplot

%% plot bar: FG distortion vs. FE distortion

% subplot(1,3,3)
% hold on
% 
% data_mat = distortion_observed_FE - distortion_observed_FG;
% xs = scatterbar_median(data_mat);
% errorbar(1, median(data_mat), MAD(data_mat), ...
%     'o','color','k','linewidth',2,'marker','none')
% 
% set(gca,'xcolor','none')
% 
% ylabel({'Distortion difference', '(Frame – Flash-Grab)'})
% yline(0,'-')
% ylim([-.8 .2])
% 
% statbar(1, 1, -.85, p);
% 
% pbaspect([1,2,1])
% 
% cleanplot

%% report
fprintf([ ...
    '\n -----------------------' ...
    '\n FG-R median distortion = %4.2f'...
    '\n FG-L median distortion = %4.2f' ...
    '\n FE-R median distortion = %4.2f'...
    '\n FE-L median distortion = %4.2f\n'], ...
    median(distortion_observed_FG_R), ...
    median(distortion_observed_FG_L), ...
    median(distortion_observed_FE_R), ...
    median(distortion_observed_FE_L));

%% save figure
% set(gcf,'papersize',[8.3 11.7])
% saveas(gcf,'../../results/fig02.pdf')


