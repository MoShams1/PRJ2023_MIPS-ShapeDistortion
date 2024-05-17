clc
clear
close all

% ### How to read the data:
% direction 90 means: cw-flash-ccw (i.e., flash-left)
% direction -90 means: ccw-flash-cw (i.e., flash-right)
% PSE ranges from -1 (hline far left) to 1 (hline far right)


% Specify the path to the JSON file
jsonFilePath = '../../data/cyc02/MS01_v01_task01_20231011_135318.json';


% Open the JSON file and read its content
fileID = fopen(jsonFilePath);
jsonContent = fread(fileID, '*char')';
fclose(fileID);

% Parse the JSON content
jsonData = jsondecode(jsonContent);

% Display the parsed JSON data
disp(jsonData);

% convert structure to arrays
condition = struct2cell(jsonData.condition);
direction = cell2mat(struct2cell(jsonData.direction));
pse = cell2mat(struct2cell(jsonData.pse_x));

% create plot matrix
cnt_list = {'static','dynamic'};
x = 1:numel(cnt_list);

nrep = numel(condition) / length(x);

for icnd = x
    ind_cnt = strcmp(condition, cnt_list{icnd});

    mean90(icnd) = median(pse(direction==90 & ind_cnt));
    err90(icnd) = std(pse(direction==90 & ind_cnt))/sqrt(nrep/2);

    meanN90(icnd) = median(pse(direction==-90 & ind_cnt));
    errN90(icnd) = std(pse(direction==-90 & ind_cnt))/sqrt(nrep/2);
    
end

%% errorbar plot

figure('units','normalized','outerposition',[.2 .2 .2 .5])

% offset correction
% offset = 0;
offset_stim = 1;
offset = mean([mean90(offset_stim),meanN90(offset_stim)]);
mean90 = mean90 - offset;
meanN90 = meanN90 - offset;

hold on
errorbar(x,mean90,err90,'--ob','linewidth',1)
errorbar(x,meanN90,errN90,'--or','linewidth',1)

xlim([.5 length(x)+.5])
xticks(1:length(x))
xticklabels({'static', 'dynamic'})
xlabel 'Annulus types'

ylim([-.7 .7])
yticks(-1:.25:1)
yline(0)
ylabel 'Point of subjective equality'

legend flash-left flash-right location best
cleanplot

%% scatterbar plot
figure('units','normalized','outerposition',[.4 .2 .2 .5])

cnd1 = pse(direction==90 & strcmp(condition, 'static')) - offset;
cnd2 = pse(direction==-90 & strcmp(condition, 'static')) - offset;
cnd3 = pse(direction==90 & strcmp(condition, 'dynamic')) - offset;
cnd4 = pse(direction==-90 & strcmp(condition, 'dynamic')) - offset;

scatterbar({cnd1; cnd2; []; cnd3; cnd4}, 200)

xlim([.5 5.5])
xticks(1:5)
xticklabels({'static (flash-left)', 'static (flash-right)', [],...
    'dynamic (flash-left)','dynamic (flash-right)'})
xlabel 'Annulus types'

ylim([-.7 .7])
yticks(-1:.25:1)
yline(0)
ylabel 'Point of subjective equality'

cleanplot