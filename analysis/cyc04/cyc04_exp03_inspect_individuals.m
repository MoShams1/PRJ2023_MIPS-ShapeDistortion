clc
clear
close all

% Specify the path to the JSON file
jsonFilePath = '../../data/cyc04/exp03_AI_20240527_120843.json';
% jsonFilePath = '../../data/cyc04/exp03_MS_20240527_132558.json';
% jsonFilePath = '../../data/cyc04/exp03_AM_20240528_111757.json';


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
pse_nrm = cell2mat(struct2cell(jsonData.pse_normalized));
loop_cnt = cell2mat(struct2cell(jsonData.loop_count));

pse_dva(dir<0) = -pse_dva(dir<0);
pse_nrm(dir<0) = -pse_nrm(dir<0);

pse_dva_FG_maskFG = pse_dva(strcmp(typ, 'FG_maskFG'));
pse_dva_FG_maskFE = pse_dva(strcmp(typ, 'FG_maskFE'));
pse_dva_FE_maskFG = pse_dva(strcmp(typ, 'FE_maskFG'));
pse_dva_FE_maskFE = pse_dva(strcmp(typ, 'FE_maskFE'));

%% plot

x_labels = {'FG-maskFG','FG-maskFE','FE-maskFG','FE-maskFE'};
data_cell = {
    pse_dva_FG_maskFG,...
    pse_dva_FG_maskFE,...
    pse_dva_FE_maskFG,...
    pse_dva_FE_maskFE
    };

figure('units','inches','outerposition',[1 1 6 4])
scatterbar(data_cell, 200)
yline(0)
cleanplot

xticks(1:4)
xticklabels(x_labels)
