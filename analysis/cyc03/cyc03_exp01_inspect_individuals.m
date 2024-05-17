clc
clear
% close all

% Specify the path to the JSON file
% jsonFilePath = '../../data/cyc03/trash/MS01_task01_20231012_174825.json';

jsonFilePath = '../../data/cyc03/MS01_task01_20231019_154026.json';
% jsonFilePath = '../../data/cyc03/JC01_task01_20231019_141104.json';
% jsonFilePath = '../../data/cyc03/NM01_task01_20231020_111013.json';
% jsonFilePath = '../../data/cyc03/SA01_task01_20231020_112728.json';
% jsonFilePath = '../../data/cyc03/JK01_task01_20231020_114622.json';

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

% offset correction
offset_FG = median([data_raw{1};data_raw{2}]);
offset_FE = median([data_raw{3};data_raw{4}]);
data_offset{1} = data_raw{5}-offset_FG;
data_offset{2} = data_raw{6}-offset_FG;
data_offset{3} = data_raw{7}-offset_FE;
data_offset{4} = data_raw{8}-offset_FE;
x_offset = x_raw(5:8);

%% plot

figure('units','normalized','outerposition',[.2 .3 .5 .5])

subplot(1,2,1)
scatterbar(data_raw, 200)
xticklabels(x_raw)
xlim([.5 8.5])
xticks(1:8)
title 'Raw data'

subplot(1,2,2)
pbaspect([.5,1,1])
scatterbar(data_offset, 200)
xticklabels(x_offset)
xlim([.5 4.5])
xticks(1:4)
title 'Offset removed'

for isubplt = 1:2
    subplot(1,2,isubplt)
    xlabel 'Annulus types'

    ylim([-1.1 1.1] * 1.2)
    yticks(-1:.25:1)
    yline(0)
    ylabel 'Point of subjective equality'

    cleanplot
end
