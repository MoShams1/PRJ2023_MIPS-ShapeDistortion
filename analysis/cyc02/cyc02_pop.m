clc
clear
% close all

dir_list = dir('../../data/cyc02/*task01*');

for isub = 1:numel(dir_list)

    % Specify the path to the JSON file
    jsonFilePath = fullfile(dir_list(isub).folder,dir_list(isub).name);
    
    % Open the JSON file and read its content
    fileID = fopen(jsonFilePath);
    jsonContent = fread(fileID, '*char')';
    fclose(fileID);
    
    % Parse the JSON content
    jsonData = jsondecode(jsonContent);
    
    % convert structure to arrays
    contrast = cell2mat(struct2cell(jsonData.contrast));
    direction = cell2mat(struct2cell(jsonData.direction));    
    pse = cell2mat(struct2cell(jsonData.pse_x));
    
    % create plot matrix
    x = 1:6;
    for icnt = x
        pse_mat1(isub, icnt) = -mean(pse(contrast==icnt & direction==90));
        pse_mat2(isub, icnt) = mean(pse(contrast==icnt & direction==-90));        
    end
    
    % adjust error direction
    pse(direction==90) = -pse(direction==90);
    for icnt = x        
        pse_mat(isub, icnt) = mean(pse(contrast==icnt));
    end
end
    
% plot
x = 1:6;
y1 = mean(pse_mat1);
err1 = SE(pse_mat1);
figure('units','normalized','outerposition',[.2 .3 .4 .45])
sgtitle 'Task01'
subplot(1,2,1)
subtitle('Divided by rotation direction')
hold on
errorbar(x,y1,err1,'-ob','linewidth',1)
y2 = mean(pse_mat2);
err2 = SE(pse_mat2);
errorbar(x,y2,err2,'-or','linewidth',1)
cleanplot
xlim([.5 6.5])
xticklabels({'0','5','10','20','40','80'})
xlabel 'Contrasts (%)'
yline(0)
ylim([-0.35 .35])
yticks(-.3:.15:.3)
ylabel 'Point of subjective equality'
text(1,.33,'cw-flash-ccw','color','b')
text(1,.3,'ccw-flash-cw','color','r')

subplot(1,2,2)
subtitle('Pooled across rotation directions')
hold on
y = mean(pse_mat);
err = SE(pse_mat);
errorbar(x,y,err,'-ok','linewidth',1)
cleanplot
xlim([.5 6.5])
xticklabels({'0','5','10','20','40','80'})
xlabel 'Contrasts (%)'
yline(0)
ylim([-0.05 .35])
yticks(0:.15:.3)
ylabel 'Point of subjective equality'
text(1,-.03,['N = ',num2str(numel(dir_list))])

for icol = 1:6
    pse_cell{icol} = pse_mat(:,icol);
end
figure('units','normalized','outerposition',[.6 .3 .2 .45])
scatterbar(pse_cell,200)
xlim([.5 6.5])
xticklabels({'0','5','10','20','40','80'})
xlabel 'Contrasts (%)'
yline(0)
ylabel 'Point of subjective equality'
cleanplot