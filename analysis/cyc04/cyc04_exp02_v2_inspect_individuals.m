clc
clear
close all

isubj = 8;

all_files = dir('../../data/cyc04/*exp02_v2*');
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
click_x = cell2mat(struct2cell(jsonData.click_x));
probe_x = cell2mat(struct2cell(jsonData.probe_x));
click_err = click_x - probe_x;

click_err(dir<0) = -click_err(dir<0);
probe_lead = probe_x;
probe_lead(dir<0) = -probe_lead(dir<0);

click_err_FG = [
    click_err(strcmp(typ,'FG') & probe_lead<0), ...
    click_err(strcmp(typ,'FG') & probe_lead==0), ...
    click_err(strcmp(typ,'FG') & probe_lead>0) ...
    ];

click_err_FE = [
    click_err(strcmp(typ,'FE') & probe_lead<0), ...
    click_err(strcmp(typ,'FE') & probe_lead==0), ...
    click_err(strcmp(typ,'FE') & probe_lead>0) ...
    ];

%% plot (scatterbar - FG)

x_labels = {'backProbe','edgeProbe','frontProbe'};

figure('units','inches','outerposition',[1 1 4 4])
hold on

x = 1:3;
y_FG_cell = mat2cell(click_err_FG,10,[1 1 1]);
scatterbar(y_FG_cell, 200);

yline(0)

xticks(1:3)
xticklabels(x_labels)
xlim([.5 3.5])

ylim([-1 4])

cleanplot

%% plot (scatterbar - FE)

x_labels = {'backProbe','edgeProbe','frontProbe'};

figure('units','inches','outerposition',[1 1 4 4])
hold on

x = 1:3;
y_FE_cell = mat2cell(click_err_FE,10,[1 1 1]);
scatterbar(y_FE_cell, 200);

yline(0)

xticks(1:3)
xticklabels(x_labels)
xlim([.5 3.5])

ylim([-1 4])

cleanplot

%% plot (errorbar)

x_labels = {'backProbe','edgeProbe','frontProbe'};

figure('units','inches','outerposition',[1 1 4 4])
hold on

x = 1:3;

y_FG = median(click_err_FG);
e_FG = SE(click_err_FG);
errorbar(x,y_FG,e_FG,'linewidth',2);

y_FE = median(click_err_FE);
e_FE = SE(click_err_FE);
errorbar(x,y_FE,e_FE,'linewidth',2);

yline(0)

xticks(1:3)
xticklabels(x_labels)
xlim([.5 3.5])

title(all_files(isubj).name(10:11))

cleanplot