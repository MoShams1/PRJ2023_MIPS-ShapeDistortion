clc
clear
% close all

% ### How to read the data:
% direction 90 means: cw-flash-ccw
% direction -90 means: ccw-flash-cw
% PSE ranges from -1 (hline far left) to 1 (hline far right)


% Specify the path to the JSON file
% jsonFilePath = '../data/cyc01/JC01_task01_20230915_115110.json';
% jsonFilePath = '../data/cyc01/JC01_right_eye_task01_20230915_125042.json';
% jsonFilePath = '../data/cyc01/JC01_left_eye_task01_20230915_125616.json';

% jsonFilePath = '../data/cyc01/MS01_task01_20230915_122121.json';
% jsonFilePath = '../data/cyc01/MS01_right_eye_task01_20230915_170536.json';
% jsonFilePath = '../data/cyc01/MS01_left_eye_task01_20230915_165745.json';
% jsonFilePath = '../data/cyc01/MS01_only90_task01_20230915_173402.json';
jsonFilePath = '../data/cyc01/MS01_onlyN90_task01_20230915_174024.json';



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


% create plot matrix
x = 1:6;
for icnt = x
    mean90(icnt) = -mean(pse(direction==90 & contrast==icnt));
    err90(icnt) = std(pse(direction==90 & contrast==icnt))/sqrt(5);
    meanN90(icnt) = mean(pse(direction==-90 & contrast==icnt));
    errN90(icnt) = std(pse(direction==-90 & contrast==icnt))/sqrt(5);
    mean2(icnt) = mean(pse_corr(contrast==icnt));
    err2(icnt) = std(pse_corr(contrast==icnt))/sqrt(10);
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

legend ccw-flash-cw cw-flash-ccw avg location northwest
cleanplot
