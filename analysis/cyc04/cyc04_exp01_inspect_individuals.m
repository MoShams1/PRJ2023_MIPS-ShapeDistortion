clc
clear
close all

isubj = 13;

all_files = dir('../../data/cyc04/*exp01*');
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
pse_nrm = cell2mat(struct2cell(jsonData.pse_normalized));
loop_cnt = cell2mat(struct2cell(jsonData.loop_count));

pse_dva(dir<0) = -pse_dva(dir<0);
pse_nrm(dir<0) = -pse_nrm(dir<0);

pse_dva_FG = pse_dva(strcmp(typ, 'FG'));
pse_dva_FE = pse_dva(strcmp(typ, 'FE'));

pse_nrm_FG = pse_nrm(strcmp(typ, 'FG'));
pse_nrm_FE = pse_nrm(strcmp(typ, 'FE'));

%% plot

x_labels = {'FG','FE'};
% data_cell = {pse_nrm_FG, pse_nrm_FE};
data_cell = {pse_dva_FG, pse_dva_FE};

figure('units','inches','outerposition',[1 1 4 4])
scatterbar(data_cell, 200)
yline(0)

xticks(1:2)
xticklabels(x_labels)

title(all_files(isubj).name(7:8))

cleanplot
