clc
clear
close all

% Specify the path to the JSON file
jsonFilePath = '../../data/cyc04/exp01_AI_20240527_114550.json';
% jsonFilePath = '../../data/cyc04/exp01_MS_20240527_130953.json';
% jsonFilePath = '../../data/cyc04/exp01_AM_20240528_110528.json';


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

%% prepare data

pse_dva(dir<0) = -pse_dva(dir<0);

pse_dva_FG_neg = pse_dva(strcmp(typ, 'FG') & dir<0);
pse_dva_FG_pos = pse_dva(strcmp(typ, 'FG') & dir>0);
pse_dva_FE_neg = pse_dva(strcmp(typ, 'FE') & dir<0);
pse_dva_FE_pos = pse_dva(strcmp(typ, 'FE') & dir>0);

%% plot

x_labels = {'FG-leftDir','FG-rightDir','FE-leftDir','FE-rightDir'};
data_cell = {
    pse_dva_FG_neg, ...
    pse_dva_FG_pos, ...
    pse_dva_FE_neg, ...
    pse_dva_FE_pos, ...
    };

figure('units','inches','outerposition',[1 1 5 4])
scatterbar(data_cell, 200)
yline(0)

xticks(1:4)
xticklabels(x_labels)

ylabel({'PSE (dva)', 'in direction of motion'})

cleanplot