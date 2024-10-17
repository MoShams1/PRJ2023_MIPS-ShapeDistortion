clc
clear
close all

all_files = dir('../../data/cyc04/*exp03*');

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
    pse_nrm = cell2mat(struct2cell(jsonData.pse_normalized));
    loop_cnt = cell2mat(struct2cell(jsonData.loop_count));

    pse_nrm(dir<0) = -pse_nrm(dir<0);

    pse_FG_maskFG(isubj,1) = mean(pse_nrm(strcmp(typ, 'FG_maskFG')));
    pse_FG_maskFE(isubj,1) = mean(pse_nrm(strcmp(typ, 'FG_maskFE')));
    pse_FE_maskFG(isubj,1) = mean(pse_nrm(strcmp(typ, 'FE_maskFG')));
    pse_FE_maskFE(isubj,1) = mean(pse_nrm(strcmp(typ, 'FE_maskFE')));

end

figure('units','inches','outerposition',[1 1 12 6])



%% plot scatterbar

subplot(1,3,[1 2])

x_labels = {'FG-maskFG','FG-maskFE','FE-maskFG','FE-maskFE'};
data_mat_scatterbar = [
    pse_FG_maskFG,...
    pse_FG_maskFE,...
    pse_FE_maskFG,...
    pse_FE_maskFE
    ];

scatterbar(data_mat_scatterbar);
errorbar(1:4, mean(data_mat_scatterbar), SE(data_mat_scatterbar), ...
    'o','color','k','linewidth',2,'marker','none')

xticks(1:4)
xticklabels(x_labels)

ylabel 'Distortion'
yline(0)
yticks(-.5:.25:.5)
ylim([-.1 .5])

pbaspect([1 1 1])
cleanplot



%% plot heatmap

subplot(1,3,3)

data_mat_heatmap = [ ...
    mean(pse_FG_maskFG), mean(pse_FE_maskFG); ...
    mean(pse_FG_maskFE), mean(pse_FE_maskFE)];
data_mat_heatmap = round(data_mat_heatmap,2);

h = heatmap(data_mat_heatmap);
% set(gcf,'InvertHardcopy','off')
set(gca, 'units','inches','Position',[7.5 1 3 3], ...
    'colormap',flipud(gray),'colorbarvisible','on', ...
    'xLabel','Motion', ...
    'xDisplayLabels',{'FG','FE'}, ...
    'yLabel','Mask', ...
    'yDisplayLabels',{'mFG','mFE'})
axs = struct(h);
cb = axs.Colorbar();
cb.Ticks = [0.07, 0.115, 0.16];
% set(gca,'TitleFontWeight','bold','TitleFontSizeMultiplier',1)
% set(gca,'LabelFontSizeMultiplier',1.2)
fontsize(gca,scale=1.5)

% statistics
data_mat_anova2 = [ ...
    pse_FG_maskFG, pse_FE_maskFG;
    pse_FG_maskFE, pse_FE_maskFE];
anova2(data_mat_anova2, 13, 'off')



%% save figure
set(gcf,'papersize',[10 10])
saveas(gcf,'../../results/ecvp24_fig06.pdf')


