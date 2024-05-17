clc
clear
close all

% ### How to read the data:
% direction > 0 means: right-flash-left
% direction < 0 means: left-flash-right
% PSE ranges from -1 (hline far left) to 1 (hline far right)

% Specify the path to the JSON file
jsonFilePath = '../data/cyc01/MS01_task02_20230915_122706.json';
% jsonFilePath = '../data/cyc01/JC01_task02_20230915_115940.json';

% Open the JSON file and read its content
fileID = fopen(jsonFilePath);
jsonContent = fread(fileID, '*char')';
fclose(fileID);

% Parse the JSON content
jsonData = jsondecode(jsonContent);

% Display the parsed JSON data
disp(jsonData);

% convert structure to arrays
contrast = cell2mat(struct2cell(jsonData.contrast));
direction = cell2mat(struct2cell(jsonData.direction));
pse = cell2mat(struct2cell(jsonData.pse_x));
% rectify signs of the opposite rotation direction
pse_corr = pse;
pse_corr(direction>0) = -pse_corr(direction>0);

cnt_rep = length(contrast) / 6;

% create plot matrix
x = 1:6;
for icnt = x
    mean90(icnt) = -mean(pse(direction>0 & contrast==icnt));
    err90(icnt) = std(pse(direction>0 & contrast==icnt))/sqrt(cnt_rep/2);

    meanN90(icnt) = mean(pse(direction<0 & contrast==icnt));
    errN90(icnt) = std(pse(direction<0 & contrast==icnt))/sqrt(cnt_rep/2);

    mean2(icnt) = mean(pse_corr(contrast==icnt));
    err2(icnt) = std(pse_corr(contrast==icnt))/sqrt(cnt_rep);
end

% plot
figure
hold on
errorbar(x,mean90,err90,'-ob')
errorbar(x,meanN90,errN90,'-or')
errorbar(x,mean2,err2,'-ok','linewidth',1.5)

xlim([.5 6.5])
xticklabels({'0','5','10','20','40','80'})
xlabel 'Contrasts (%)'
yline(0)
ylabel 'Point of subjective equality'
cleanplot