clc
clear
close all


all_files = dir('../../data/cyc05/*exp03*');
nsubjects = numel(all_files);

ind_exclude = 5;

for isubj = 1:nsubjects

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
    distortion_observed_frame(isubj,1)  = mean(pse_norm(strcmp(typ, 'frame')));
    distortion_observed_frame_disc(isubj,1)  = mean(pse_norm(strcmp(typ, 'frame_disc')));
    distortion_observed_frame_frame(isubj,1)  = mean(pse_norm(strcmp(typ, 'frame_frame')));
    distortion_observed_cross_disc(isubj,1)  = mean(pse_norm(strcmp(typ, 'cross_disc')));
    distortion_observed_cross_frame(isubj,1)  = mean(pse_norm(strcmp(typ, 'cross_frame')));

end

%% apply exclusion
distortion_observed_frame(ind_exclude,:) = [];
distortion_observed_frame_disc(ind_exclude,:) = [];
distortion_observed_frame_frame(ind_exclude,:) = [];
distortion_observed_cross_disc(ind_exclude,:) = [];
distortion_observed_cross_frame(ind_exclude,:) = [];

%% plot scatter

figure

data_mat = [
    distortion_observed_cross_disc,...
    distortion_observed_cross_frame,...
    distortion_observed_frame_disc,...
    distortion_observed_frame_frame,...
    distortion_observed_frame];

xs = scatterbar_median(data_mat);
errorbar(1:5, median(data_mat), MAD(data_mat), ...
    'o','color','k','linewidth',2,'marker','none')

plot(xs', data_mat', 'color', .5 * ones(1,3))

xticks(1:5)
xticklabels({'cd', 'cf', 'fd', 'ff', 'f'})

ylabel 'Distortion'
yline(0,'-')
ylim([-.2 1])

cleanplot

%% save figure
% set(gcf,'papersize',[8.3 11.7])
% saveas(gcf,'../results/fig02.pdf')


