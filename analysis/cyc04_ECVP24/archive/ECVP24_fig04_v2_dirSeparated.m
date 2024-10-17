clc
clear
close all

all_files = dir('../../data/cyc04/*exp04*');

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
    typ = cell2mat(struct2cell(jsonData.stimulus_type));
    dir = cell2mat(struct2cell(jsonData.postflash_direction));
    pse_nrm = cell2mat(struct2cell(jsonData.pse_normalized));
    loop_cnt = cell2mat(struct2cell(jsonData.loop_count));

    pse_nrm(dir<0) = -pse_nrm(dir<0);

    pse_LF_LD(isubj,1) = mean(pse_nrm(typ<0 & dir<0));
    pse_LF_RD(isubj,1) = mean(pse_nrm(typ<0 & dir>0));
    pse_RF_LD(isubj,1) = mean(pse_nrm(typ>0 & dir<0));
    pse_RF_RD(isubj,1) = mean(pse_nrm(typ>0 & dir>0));

end

%% plot

x_labels = {'LeftFix <', 'LeftFix >', 'RightFix <', 'RightFix >'};

data_mat = [
    pse_LF_LD, ...
    pse_LF_RD, ...
    pse_RF_LD, ...
    pse_RF_RD
    ];

data_cell = mat2cell(data_mat, size(data_mat,1), ones(1,4));

figure('units','inches','outerposition',[1 1 8 7])
xs = scatterbar(data_cell);
plot(xs', data_mat', 'color',.5.*ones(1,3))
errorbar(1:4, mean(data_mat), SE(data_mat), ...
    'o','color','k','linewidth',2,'marker','none')

xticks(1:4)
xticklabels(x_labels)

ylabel({'Shape distortion index', 'in direction of motion'})
yticks(0:.25:.5)
% ylim([-.05 .5])
yline(0)

cleanplot_poster

%% functions

function xs = scatterbar(A)
% A: a cell of cetegories

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
