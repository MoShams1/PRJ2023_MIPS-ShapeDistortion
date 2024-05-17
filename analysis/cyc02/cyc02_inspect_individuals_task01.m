clc
clear
% close all

% ### How to read the data:
% direction 90 means: cw-flash-ccw
% direction -90 means: ccw-flash-cw
% PSE ranges from -1 (hline far left) to 1 (hline far right)


% Specify the path to the JSON file

% jsonFilePath = '../../data/cyc02/MS01_task01_20230915_194642.json';
% jsonFilePath = '../../data/cyc02/MS01_vert_task01_20230921_121207.json';
% jsonFilePath = '../../data/cyc02/MS02_vert_left_task01_20230921_125404.json';
% jsonFilePath = '../../data/cyc02/MS01_14rep_task01_20230921_162801.json';


% jsonFilePath = '../../data/cyc02/JC01_task01_20230921_120414.json';
% jsonFilePath = '../../data/cyc02/JC01_vert_task01_20230921_121802.json';
% jsonFilePath = '../../data/cyc02/JC02_vert_left_task01_20230921_130040.json';

% jsonFilePath = '../../data/cyc02/SA01_task01_20230922_114340.json';

% jsonFilePath = '../../data/cyc02/AS01_task01_20230922_122048.json';





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
pse_corr(direction==90) = -pse_corr(direction==90);

nrep = length(contrast) / 6;

% create plot matrix
x = 1:6;
for icnt = x
    mean90(icnt) = -mean(pse(direction==90 & contrast==icnt));
    err90(icnt) = std(pse(direction==90 & contrast==icnt))/sqrt(nrep/2);

    meanN90(icnt) = mean(pse(direction==-90 & contrast==icnt));
    errN90(icnt) = std(pse(direction==-90 & contrast==icnt))/sqrt(nrep/2);
    
    mean2(icnt) = mean(pse_corr(contrast==icnt));
    err2(icnt) = std(pse_corr(contrast==icnt))/sqrt(nrep);
end

% for icnt = x
%     mean90(icnt) = -median(pse(direction==90 & contrast==icnt));
%     err90(icnt) = std(pse(direction==90 & contrast==icnt))/sqrt(nrep/2);
% 
%     meanN90(icnt) = median(pse(direction==-90 & contrast==icnt));
%     errN90(icnt) = std(pse(direction==-90 & contrast==icnt))/sqrt(nrep/2);
%     
%     mean2(icnt) = median(pse_corr(contrast==icnt));
%     err2(icnt) = std(pse_corr(contrast==icnt))/sqrt(nrep);
% end

% plot
figure
hold on
errorbar(x,mean90,err90,'-ob','linewidth',1)
errorbar(x,meanN90,errN90,'-or','linewidth',1)
errorbar(x,mean2,err2,'-ok','linewidth',1.5)

xlim([.5 6.5])
xticklabels({'0','5','10','20','40','80'})
xlabel 'Contrasts (%)'
yline(0)
ylabel 'Point of subjective equality'

legend ccw-flash-cw cw-flash-ccw avg location northwest
cleanplot
