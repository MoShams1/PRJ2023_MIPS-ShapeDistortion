clc
clear
close all

% Specify the path to the JSON file
jsonFilePath = '../../data/cyc04/exp04_AI_20240527_122003.json';
% jsonFilePath = '../../data/cyc04/exp04_MS_20240527_134206.json';

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
pse_dva = cell2mat(struct2cell(jsonData.pse_dva));
pse_nrm = cell2mat(struct2cell(jsonData.pse_normalized));
loop_cnt = cell2mat(struct2cell(jsonData.loop_count));

% pse_dva(dir<0) = -pse_dva(dir<0);

pse_dva_close = pse_dva( ...
    (typ>0 & dir>0) | ...
    (typ<0 & dir<0) ...
    );

pse_dva_far = pse_dva( ...
    (typ>0 & dir<0) | ...
    (typ<0 & dir>0) ...
    );

%% plot

x_labels = {'Close','Far'};
data_cell = {pse_dva_close, pse_dva_far};

figure('units','inches','outerposition',[1 1 4 4])
scatterbar(data_cell, 200)
yline(0)
cleanplot

xticks(1:2)
xticklabels(x_labels)
