clc
clear
close all

file_dir = dir('../../data/cyc03/*task01*');

for isub = 1:numel(file_dir)

    % Specify the path to the JSON file
    jsonFilePath = fullfile(file_dir(isub).folder,file_dir(isub).name);

    % Open the JSON file and read its content
    fileID = fopen(jsonFilePath);
    jsonContent = fread(fileID, '*char')';
    fclose(fileID);
    
    % Parse the JSON content
    jsonData = jsondecode(jsonContent);
    
    % convert structure to arrays
    typ = struct2cell(jsonData.stimulus_type);
    dir = cell2mat(struct2cell(jsonData.postflash_dir));
    beh = struct2cell(jsonData.stimulus_behavior);
    pse = cell2mat(struct2cell(jsonData.pse_x));
    
    % create data cell
    beh_list = {'static', 'dynamic'};
    typ_list = {'FG', 'FE'};
    dir_list = [-1, 1];
    
    col_cntr = 0;
    for ibeh = 1:numel(beh_list)
        for ityp = 1:numel(typ_list)
            for idir = 1:numel(dir_list)
    
                col_cntr = col_cntr+1;
    
                ind_beh = strcmp(beh, beh_list{ibeh});
                ind_typ = strcmp(typ, typ_list{ityp});
                ind_dir = dir == dir_list(idir);
    
                x_raw{col_cntr} = [beh_list{ibeh}, typ_list{ityp}, num2str(dir_list(idir))];
                data_raw{col_cntr} = pse(ind_beh & ind_typ & ind_dir);
    
            end
        end
    end
    
    % prepare data cells/matrices    
    
    data{1}(isub,1) = mean(data_raw{5});
    data{2}(isub,1) = mean(data_raw{6});
    data{3}(isub,1) = mean(data_raw{7});
    data{4}(isub,1) = mean(data_raw{8});

    offset_FG = mean([data_raw{1};data_raw{2}]);
    offset_FE = mean([data_raw{3};data_raw{4}]);

    data_offset{1}(isub,1) = mean(data_raw{5})-offset_FG;
    data_offset{2}(isub,1) = mean(data_raw{6})-offset_FG;
    data_offset{3}(isub,1) = mean(data_raw{7})-offset_FE;
    data_offset{4}(isub,1) = mean(data_raw{8})-offset_FE;

    data_pooled{1}(isub,:) = mean([-data_raw{5};data_raw{6}]);
    data_pooled{2}(isub,:) = mean([-data_raw{7}]);

    data_pooled_offset{1}(isub,:) = mean([-data_raw{5};data_raw{6}]) - offset_FG;
    data_pooled_offset{2}(isub,:) = mean([-data_raw{7}]) - offset_FE;
    
end

%% static stimuli (offset)

figure('units','normalized','outerposition',[.0 .3 .2 .5])

offset_FG_cell = {data_raw{1};data_raw{2}};
offset_FE_cell = {data_raw{3};data_raw{4}};

scatterbar(offset_FG_cell, 200)
title 'Static image induced shift'

xlim([.5 2.5])
xticks(1:2)
xlabel 'Annulus types'
xticklabels({'FG', 'FE'})

ylim([-1.1 1.1] * 1.2)
yticks(-1:.25:1)
yline(0)
ylabel 'Point of subjective equality'

cleanplot

%% divided by the direction of motion

figure('units','normalized','outerposition',[.2 .3 .3 .5])

subplot(1,2,1)
scatterbar(data, 200)
title 'Raw data'

subplot(1,2,2)
scatterbar(data_offset, 200)
title 'Offset removed'

for isubplt = 1:2
    subplot(1,2,isubplt)
    xlim([.5 4.5])
    xticks(1:4)
    xlabel 'Annulus types'
    xticklabels({'-FG', '+FG', '-FE', '+FE'})

    ylim([-1.1 1.1] * 1.2)
    yticks(-1:.25:1)
    yline(0)
    ylabel 'Point of subjective equality'

    cleanplot
end

%% pooled over direction of motion

figure('units','normalized','outerposition',[.5 .3 .3 .5])

subplot(1,2,1)
scatterbar(data_pooled, 200)
title 'Raw data'

subplot(1,2,2)
scatterbar(data_pooled_offset, 200)
title 'Offset removed'

for isubplt = 1:2
    subplot(1,2,isubplt)
    xlim([.5 2.5])
    xticks(1:2)
    xlabel 'Annulus types'
    xticklabels({'FG', 'FE'})

    ylim([-.25 1.1] * 1.1)
    yticks(-1:.25:1)
    yline(0)
    ylabel 'Point of subjective equality'

    cleanplot
end
