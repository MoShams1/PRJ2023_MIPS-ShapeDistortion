clc
clear
close all

isubj = 2;

all_files = dir('../../data/cyc04/*exp04*');
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
pse_dva = cell2mat(struct2cell(jsonData.pse_dva));
pse_nrm = cell2mat(struct2cell(jsonData.pse_normalized));
loop_cnt = cell2mat(struct2cell(jsonData.loop_count));

% pse_dva(dir<0) = -pse_dva(dir<0);
pse_dva_LF_LD = pse_dva(typ<0 & dir<0);
pse_dva_LF_RD = pse_dva(typ<0 & dir>0);
pse_dva_RF_LD = pse_dva(typ>0 & dir<0);
pse_dva_RF_RD = pse_dva(typ>0 & dir>0);

%% plot

x_labels = {'LF-LD','LF-RD','RF-LD','RF-RD'};
data_cell = {
    pse_dva_LF_LD, ...
    pse_dva_LF_RD, ...
    pse_dva_RF_LD, ...
    pse_dva_RF_RD
    };

figure('units','inches','outerposition',[1 1 4 4])
scatterbar(data_cell, 200)
yline(0)

xticks(1:4)
xticklabels(x_labels)

title(all_files(isubj).name(7:8))

cleanplot
