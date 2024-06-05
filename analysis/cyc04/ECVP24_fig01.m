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
    pse_norm = cell2mat(struct2cell(jsonData.pse_normalized));
    loop_cnt = cell2mat(struct2cell(jsonData.loop_count));

    pse_norm(dir<0) = -pse_norm(dir<0);

    pse_FG(isubj,1)  = mean(pse_norm(strcmp(typ, 'FG')));
    pse_FE(isubj,1)  = mean(pse_norm(strcmp(typ, 'FE')));

end


%% plot (directions pooled)

x_labels = {'FG','FE'};
data_cell = {pse_FG, pse_FE};

figure('units','inches','outerposition',[7 2 5 7])
xs = scatterbar(data_cell);
data_mat = [pse_FG, pse_FE];
plot(xs', data_mat', 'color',.5.*ones(1,3))
errorbar(1:2, mean(data_mat), SE(data_mat), ...
    'o','color','k','linewidth',2,'marker','none')

xticks(1:2)
xticklabels(x_labels)

ylabel({'Shape distortion index', 'in direction of motion'})
ylim([-.1 .5])
yticks(0:.25:.5)
yline(0)

cleanplot_poster

%% add stats

[delta, deltap, p, W, z, r] = signrank_full(pse_FG, pse_FE);
fprintf([ ...
    '\n <FG vs FE>' ...
    '\n -----------' ...
    '\n median decrease = %5.2f dva' ...
    '\n median decrease = %3.0f %%' ...
    '\n W = %5.2f' ...
    '\n z = %5.2f' ...
    '\n p = %5.3f' ...
    '\n r = %4.2f \n'], ...
delta,deltap,W,z,p,r)

statbar_poster(1,2, .45, p);

%%
function xs = scatterbar(A)
% A: a cell of cetegories

ncat    = numel(A); % number of categories
stdx    = .04; % standard deviation of scatters in each category
mean_line_length  = .4; % line length for mean
mean_line_width = 5;
marksz  = 100; % marker size
alpha = .1;

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
