clc
clear
% close all

% ### How to read the data:
% direction 90 means: cw-flash-ccw (i.e., flash-left)
% direction -90 means: ccw-flash-cw (i.e., flash-right)
% PSE ranges from -1 (hline far left) to 1 (hline far right)


% Specify the path to the JSON file

% jsonFilePath = '../../data/cyc02/test_with_empty_mohammad_task01_20231005_184804.json';
% jsonFilePath = '../../data/cyc02/test_with_empty_shenoa_task01_20231005_182109.json';
% jsonFilePath = '../../data/cyc02/test_with_empty_amanda_task01_20231006_125224.json';

% jsonFilePath = '../../data/cyc02/MS01_full_task01_20231010_113227.json';

% jsonFilePath = '../../data/cyc02/MS01_7cnd_dark_task01_20231010_125408.json';
% jsonFilePath = '../../data/cyc02/MS01_7cnd_dark2_task01_20231010_131102.json';
% jsonFilePath = '../../data/cyc02/MS01_first_three_task01_20231010_133224.json';
% jsonFilePath = '../../data/cyc02/MS01_first_three_30cndRep_3frameRep_task01_20231010_140736.json';
% jsonFilePath = '../../data/cyc02/MS01_lowCnt_task01_20231010_151124.json';
jsonFilePath = '../../data/cyc02/MS01_task01_20231010_161055.json'; % only 2 per cnd (4 per cnt)

% jsonFilePath = '../../data/cyc02/MM01_first_three_30cndRep_3frameRep_task01_20231010_143036.json';


% Open the JSON file and read its content
fileID = fopen(jsonFilePath);
jsonContent = fread(fileID, '*char')';
fclose(fileID);

% Parse the JSON content
jsonData = jsondecode(jsonContent);

% Display the parsed JSON data
disp(jsonData);

% convert structure to arrays
contrast = struct2cell(jsonData.contrast);
direction = cell2mat(struct2cell(jsonData.direction));
pse = cell2mat(struct2cell(jsonData.pse_x));

% create plot matrix
cnt_list = {'empty','static','bbww','bb','ww','b','w'};
x = 1:numel(cnt_list);

nrep = numel(contrast) / length(x);

for icnt = x
    ind_cnt = strcmp(contrast, cnt_list{icnt});

    mean90(icnt) = median(pse(direction==90 & ind_cnt));
    err90(icnt) = std(pse(direction==90 & ind_cnt))/sqrt(nrep/2);

    meanN90(icnt) = median(pse(direction==-90 & ind_cnt));
    errN90(icnt) = std(pse(direction==-90 & ind_cnt))/sqrt(nrep/2);
    
end

% plot

figure('units','normalized','outerposition',[.2 .2 .3 .5])

% offset correction
% offset_stim = 1;
% offset = mean([mean90(offset_stim),meanN90(offset_stim)]);
% mean90 = mean90 - offset;
% meanN90 = meanN90 - offset;

hold on
errorbar(x,mean90,err90,'--ob','linewidth',1)
errorbar(x,meanN90,errN90,'--or','linewidth',1)

xlim([.5 length(x)+.5])
xticks(1:length(x))
xticklabels({'none','static','bbww','bb','ww','b','w'})
xlabel 'Annulus types'

% ylim([-.3 0])
yticks(-1:.1:1) 
yline(0)
ylabel 'Point of subjective equality'

legend flash-left flash-right location best
cleanplot
