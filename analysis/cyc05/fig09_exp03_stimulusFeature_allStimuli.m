clc
clear
close all


all_files = dir('../../data/cyc05/*exp03*');
nsubjects = numel(all_files);

ind_exclude = 6;

for isubj = 1:nsubjects

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
    pse_norm = cell2mat(struct2cell(jsonData.pse_normalized));
    loop_cnt = cell2mat(struct2cell(jsonData.loop_count));

    pse_norm(dir>0) = -pse_norm(dir>0);
    distortion_observed_frame(isubj,1)  = mean(pse_norm(strcmp(typ, 'frame')));
    distortion_observed_frame_disc(isubj,1)  = mean(pse_norm(strcmp(typ, 'frame_disc')));
    distortion_observed_frame_frame(isubj,1)  = mean(pse_norm(strcmp(typ, 'frame_frame')));
    distortion_observed_cross_disc(isubj,1)  = mean(pse_norm(strcmp(typ, 'cross_disc')));
    distortion_observed_cross_frame(isubj,1)  = mean(pse_norm(strcmp(typ, 'cross_frame')));

end

%% apply exclusion
distortion_observed_frame(ind_exclude,:) = [];
distortion_observed_frame_disc(ind_exclude,:) = [];
distortion_observed_frame_frame(ind_exclude,:) = [];
distortion_observed_cross_disc(ind_exclude,:) = [];
distortion_observed_cross_frame(ind_exclude,:) = [];

nsubjects = length(distortion_observed_frame);

%% scatterbar all five conditions

figure('units','inches','outerposition',[1 1 7 5.5])
hold on

data_mat = [
    distortion_observed_cross_disc,...
    distortion_observed_cross_frame,...
    distortion_observed_frame_disc,...
    distortion_observed_frame_frame, ...
    distortion_observed_frame];

xs = scatterbar_median(data_mat,.25,4,50,0.1,.03);
errorbar(1:5, median(data_mat), MAD(data_mat), ...
    'o','color','k','linewidth',2,'marker','none')

plot(xs', data_mat', 'color', .7 * ones(1,3))

xticks(1:5)
xticklabels({ ...
    'rot+cur', ...
    'rot+str', ...
    'tra+cur', ...
    'tra+str', ...
    'frame'})
xlim([.5 5.5])

ylabel 'Shape distortion'
yline(0,'-')
yticks(-.2:.2:.8)
ylim([-.1 .65])

text(4.5, .6, ['N = ',num2str(nsubjects)])

cleanplot

round(median(data_mat)*100)/100

%% save figure
set(gcf,'papersize',[8.3 11.7])
saveas(gcf,'../../results/fig09.pdf')

%%
[p, tbl, stats] = friedman(data_mat, 1);

% fprintf([ ...    
%     '\n <Friedman Test>' ...
%     '\n -----------------------' ...
%     '\n median difference = %4.2f'...
%     '\n W = %5.2f' ...
%     '\n z = %5.2f' ...
%     '\n p = %5.3f' ...
%     '\n r = %4.2f \n'], ...
% delta,W,z,p,r)

%% paired tests

% figure(1)
% hold on
% 
% p12 = signrank(data_mat(:,1),data_mat(:,2));
% statbar(1,2,.7,p12)
% 
% p13 = signrank(data_mat(:,1),data_mat(:,3));
% statbar(1,3,.76,p13)
% 
% p14 = signrank(data_mat(:,1),data_mat(:,4));
% statbar(1,4,.82,p14)
% 
% p15 = signrank(data_mat(:,1),data_mat(:,5));zxr
% statbar(1,5,.88,p15)
% 
% p35 = signrank(data_mat(:,3),data_mat(:,5));
% statbar(3,5,.71,p35)
% 
% p45 = signrank(data_mat(:,4),data_mat(:,5));
% statbar(4,5,.64,p45)



