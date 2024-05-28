clc
clear
close all

% Specify the path to the JSON file
% jsonFilePath = '../../data/cyc04/exp03_AI_20240527_120843.json';
% jsonFilePath = '../../data/cyc04/exp03_MS_20240527_132558.json';
jsonFilePath = '../../data/cyc04/exp03_AM_20240528_111757.json';


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
loop_cnt = cell2mat(struct2cell(jsonData.loop_count));

%% preparer data

pse_dva(dir<0) = -pse_dva(dir<0);

pse_dva_FG_maskFG_neg = pse_dva(strcmp(typ, 'FG_maskFG') & dir<0);
pse_dva_FG_maskFE_neg = pse_dva(strcmp(typ, 'FG_maskFE') & dir<0);
pse_dva_FE_maskFG_neg = pse_dva(strcmp(typ, 'FE_maskFG') & dir<0);
pse_dva_FE_maskFE_neg = pse_dva(strcmp(typ, 'FE_maskFE') & dir<0);

pse_dva_FG_maskFG_pos = pse_dva(strcmp(typ, 'FG_maskFG') & dir>0);
pse_dva_FG_maskFE_pos = pse_dva(strcmp(typ, 'FG_maskFE') & dir>0);
pse_dva_FE_maskFG_pos = pse_dva(strcmp(typ, 'FE_maskFG') & dir>0);
pse_dva_FE_maskFE_pos = pse_dva(strcmp(typ, 'FE_maskFE') & dir>0);

%% plot (leftward motion)

x_labels = {
    'FG-maskFG', ...
    'FG-maskFE', ...
    'FE-maskFG', ...
    'FE-maskFE'
    };

data_cell = {
    pse_dva_FG_maskFG_neg,...
    pse_dva_FG_maskFE_neg,...
    pse_dva_FE_maskFG_neg,...
    pse_dva_FE_maskFE_neg
    };

figure('units','inches','outerposition',[1 1 6 4])
scatterbar(data_cell, 200)
yline(0)

xticks(1:4)
xticklabels(x_labels)

ylim([-.7 .7])
ylabel({'PSE (dva)', 'in direction of motion'})

title('leftward motion')
cleanplot

%% plot (rightward motion)

x_labels = {
    'FG-maskFG', ...
    'FG-maskFE', ...
    'FE-maskFG', ...
    'FE-maskFE'
    };

data_cell = {
    pse_dva_FG_maskFG_pos,...
    pse_dva_FG_maskFE_pos,...
    pse_dva_FE_maskFG_pos,...
    pse_dva_FE_maskFE_pos
    };

figure('units','inches','outerposition',[1 1 6 4])
scatterbar(data_cell, 200)
yline(0)

xticks(1:4)
xticklabels(x_labels)

ylim([-.7 .7])
ylabel({'PSE (dva)', 'in direction of motion'})

title('rightward motion')
cleanplot