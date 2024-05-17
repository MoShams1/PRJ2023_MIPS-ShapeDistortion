clc
clear
% close all


% Specify the path to the JSON file
jsonFilePath = '../../data/cyc03/MS01_task02_20231019_170346.json';
% jsonFilePath = '../../data/cyc03/JC01_task02_20231019_142425.json';


% Open the JSON file and read its content
fileID = fopen(jsonFilePath);
jsonContent = fread(fileID, '*char')';
fclose(fileID);

% Parse the JSON content
jsonData = jsondecode(jsonContent);

% convert structure to arrays
typ = struct2cell(jsonData.stimulus_type);
phs = cell2mat(struct2cell(jsonData.stimulus_phase));
dir = cell2mat(struct2cell(jsonData.postflash_motiondir));
kin = struct2cell(jsonData.stimulus_kinetic);
pse = cell2mat(struct2cell(jsonData.pse_norm));

% create data cell
kin_list = {'static', 'dynamic'};
typ_list = {'FG', 'FE'};
dir_list = [-1, 1];
phs_list = unique(phs);

x_FG = cosd(90 - phs_list/2) * 3.5;  % dva
x_FE = (phs_list / 90) * 2.7489;  % dva

col_cntr = 0;
for ikin = 1:numel(kin_list)
    for ityp = 1:numel(typ_list)
        for idir = 1:numel(dir_list)

            col_cntr = col_cntr+1;

            for iphs = 1:numel(phs_list)
    
                ind_kin = strcmp(kin, kin_list{ikin});
                ind_typ = strcmp(typ, typ_list{ityp});
                ind_dir = dir == dir_list(idir);
                ind_phs = phs == phs_list(iphs);
    
                x_raw{col_cntr} = ...
                    [kin_list{ikin}, typ_list{ityp},...
                    num2str(dir_list(idir)), num2str(phs_list(iphs))];
                
                data_raw{col_cntr}(:, iphs) = pse(ind_kin & ind_typ & ind_dir & ind_phs);

            end
        end
    end
end

% offset correction
% offset_FG = median([data_raw{1};data_raw{2}]);
% offset_FE = median([data_raw{3};data_raw{4}]);
% data_offset{1} = data_raw{5}-offset_FG;
% data_offset{2} = data_raw{6}-offset_FG;
% data_offset{3} = data_raw{7}-offset_FE;
% data_offset{4} = data_raw{8}-offset_FE;
% x_offset = x_raw(5:8);

%% plot

% figure('units','normalized','outerposition',[.2 .3 .5 .5])

% subplot(1,2,1)

tuning_map = cell2mat(cellfun(@mean, data_raw, 'Uniformoutput', false)');

% figure
% hold on
% plot(tuning_map(1:4,:)','linestyle','--','linewidth',1)
% plot(tuning_map(5:6,:)','marker','o','linewidth',1)
% plot(tuning_map(7:8,:)','marker','s','linewidth',1)
% xlim([.5 7.5])
% xticks(1:7)
% xticklabels(phs_list)
% title 'Raw data'

FG_base = mean([data_raw{1};-data_raw{2}],1);
FE_base = mean([data_raw{3};-data_raw{4}],1);

FG = [data_raw{5};-data_raw{6}];
FE = [data_raw{7};-data_raw{8}];

figure
color = lines(7);
hold on
plot3line(1:length(phs_list), FG-FG_base, color(1,:),0,0,'o');
plot3line(1:length(phs_list), FE-FE_base, color(7,:),0,0,'s');
xlim([.5 7.5])
xticks(1:7)
xticklabels(phs_list)
title 'Raw data'

% subplot(1,2,2)
% pbaspect([.5,1,1])
% scatterbar(data_offset, 200)
% xticklabels(x_offset)
% xlim([.5 4.5])
% xticks(1:4)
% title 'Offset removed'

% for isubplt = 1:2
%     subplot(1,2,isubplt)
    xlabel 'Moving object''s phase (deg)'
    xline(4)
%     ylim([-1.1 1.1] * 20)
%     yticks(-1:.25:1)
    yline(0)
    ylabel 'Point of subjective equality (%)'

    cleanplot
% end
