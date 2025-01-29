clc
clear
close all

all_files = dir('../../data/cyc04/*exp01*');

for isubj = 1:numel(all_files)

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

    pse_norm(dir<0) = -pse_norm(dir<0);
    pse_norm_FG(isubj,1)  = mean(pse_norm(strcmp(typ, 'FG')));
    pse_norm_FE(isubj,1)  = mean(pse_norm(strcmp(typ, 'FE')));

    pse_dva(dir<0) = -pse_dva(dir<0);
    pse_dva_FG(isubj,1)  = mean(pse_dva(strcmp(typ, 'FG')));
    pse_dva_FE(isubj,1)  = mean(pse_dva(strcmp(typ, 'FE')));

end



%% plot (separate stimuli plus difference)

x_labels = {'FG','FE'};

figure('units','inches','outerposition',[7 2 5.5 6])
subplot(1,2,1)

data_mat = [pse_norm_FG, pse_norm_FE];
xs = scatterbar(data_mat);
plot(xs', data_mat', 'color',.5.*ones(1,3))
errorbar(1:2, mean(data_mat), SE(data_mat), ...
    'o','color','k','linewidth',2,'marker','none')

xticks(1:2)
xticklabels(x_labels)

ylabel({'Shape distortion index', '(in direction of motion)'})
ylim([-.1 .5])
yticks(0:.25:.5)
yline(0,'--')

cleanplot



subplot(1,2,2)
data_mat = (pse_norm_FE-pse_norm_FG)./pse_norm_FG*100;
xs = scatterbar(data_mat);
errorbar(1, mean(data_mat), SE(data_mat), ...
    'o','color','k','linewidth',2,'marker','none')

xticks(1)
set(gca,'xcolor','none')

ylabel({'Difference (%)'})
ylim([-100 50])
yticks(-100:50:100)
yline(0,'--')

pbaspect([.3 1 1])
cleanplot



% add stats

[delta, deltap, p, W, z, r] = signrank_full(pse_norm_FG, pse_norm_FE);
fprintf([ ...
    '\n <Norm. distortion>' ...
    '\n ------------------' ...
    '\n mean decrease = %4.1f dva' ...
    '\n mean decrease = %3.0f %%' ...
    '\n W = %5.2f' ...
    '\n z = %5.2f' ...
    '\n p = %5.3f' ...
    '\n r = %4.2f \n'], ...
delta,deltap,W,z,p,r)
subplot(1,2,1)
statbar(1,2,.5,p)

[delta, deltap, p, W, z, r] = signrank_full(data_mat);
fprintf([ ...
    '\n <Distortion difference>' ...
    '\n -----------------------' ...
    '\n mean decrease = %4.1f pp' ...
    '\n mean decrease = %3.0f %%' ...
    '\n W = %5.2f' ...
    '\n z = %5.2f' ...
    '\n p = %5.3f' ...
    '\n r = %4.2f \n'], ...
delta,deltap,W,z,p,r)
subplot(1,2,2)
statbar(1,1,50,p)


%%
function xs = scatterbar(A)
% A: a cell of cetegories

A = mat2cell(A, size(A,1), ones(1, size(A,2)));

ncat    = numel(A); % number of categories
stdx    = .04; % standard deviation of scatters in each category
mean_line_length  = .4; % line length for mean
mean_line_width = 5;
marksz  = 100; % marker size
alpha = .15;

hold on
for icat = 1:ncat    
    rng default
    n = numel(A{icat});
    x = randn(n,1)*stdx + icat;
    xs(:,icat) = x;
    
    scatter(x,A{icat},marksz,'k','o','filled','markerfacealpha',alpha);
    line([icat-mean_line_length icat+mean_line_length],[mean(A{icat}) mean(A{icat})],...
        'color','k','linewidth',mean_line_width);
end

xlim([0 ncat+1])
set(gca,'xtick',1:ncat)
end
