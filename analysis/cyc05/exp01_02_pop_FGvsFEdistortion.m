clc
clear
close all

all_files = dir('../../data/cyc05/archive/*exp01*');
nsubjects = numel(all_files);

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
    distortion_observed_FG(isubj,1)  = mean(pse_norm(strcmp(typ, 'FG')));
    distortion_observed_FE(isubj,1)  = mean(pse_norm(strcmp(typ, 'FE')));

end

%% save distortion magnitudes of each individual in FG and FE

save distortion_observed.mat ...
    distortion_observed_FG ...
    distortion_observed_FE

%% plot scatter: FG distortion vs. FE distortion

figure('units','inches','outerposition',[0 0 4 4])
hold on

data_mat = [distortion_observed_FG, distortion_observed_FE];
xs = scatterbar_median(data_mat);
errorbar(1:2, median(data_mat), MAD(data_mat), ...
    'o','color','k','linewidth',2,'marker','none')

plot(xs', data_mat', 'color', .5 * ones(1,3))

xticks(1:2)
xticklabels({'FG', 'FE'})

ylabel 'Distortion'
yline(0,'-')

text(2.2, -.15, ['N = ',num2str(nsubjects)])
pbaspect([1,2,1])

cleanplot

%% stat
[delta, ~, p, W, z, r] = signrank_full(distortion_observed_FG, distortion_observed_FE);
fprintf([ ...
    '\n <Distortion difference>' ...
    '\n -----------------------' ...
    '\n median difference = %4.1f'...
    '\n W = %5.2f' ...
    '\n z = %5.2f' ...
    '\n p = %5.3f' ...
    '\n r = %4.2f \n'], ...
delta,W,z,p,r)
statbar(1,2, .9, p);



%% save figure
% set(gcf,'papersize',[8.3 11.7])
% saveas(gcf,'../results/fig02.pdf')


