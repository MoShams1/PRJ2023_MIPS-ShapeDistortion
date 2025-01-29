clc
clear
close all

all_files = dir('../data/cyc04/*exp03*');

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
    pse_nrm = cell2mat(struct2cell(jsonData.pse_normalized));
    loop_cnt = cell2mat(struct2cell(jsonData.loop_count));

    pse_nrm(dir<0) = -pse_nrm(dir<0);

    pse_FG_maskFG(isubj,1) = mean(pse_nrm(strcmp(typ, 'FG_maskFG')));
    pse_FG_maskFE(isubj,1) = mean(pse_nrm(strcmp(typ, 'FG_maskFE')));
    pse_FE_maskFG(isubj,1) = mean(pse_nrm(strcmp(typ, 'FE_maskFG')));
    pse_FE_maskFE(isubj,1) = mean(pse_nrm(strcmp(typ, 'FE_maskFE')));

end

figure('units','inches','outerposition',[1 1 6 5])

%% plot scatterbar
x_labels = {'FG-maskFG','FG-maskFE','FE-maskFG','FE-maskFE'};
data_mat_scatterbar = [
    pse_FG_maskFG,...
    pse_FG_maskFE,...
    pse_FE_maskFG,...
    pse_FE_maskFE
    ];

scatterbar_median(data_mat_scatterbar);
errorbar(1:4, median(data_mat_scatterbar), MAD(data_mat_scatterbar), ...
    'o','color','k','linewidth',2,'marker','none')

xticks(1:4)
xticklabels(x_labels)

ylabel 'Distortion'
yline(0)
yticks(-.5:.1:.5)
ylim([-.05 .45])

text(4.5, -.03, ['N = ',num2str(numel(all_files))])

cleanplot

% statistics
data_mat_anova2 = [ ...
    pse_FG_maskFG, pse_FE_maskFG;
    pse_FG_maskFE, pse_FE_maskFE];
[p, table, stats] = anova2(data_mat_anova2, 13, 'on');

disp('---MOTION---')
fprintf('F(%d,%d)=%4.2f; p=%5.3f; eta2=%4.2f\n', ...
    table{2,3}, table{5,3}, ...
    table{2,5}, ...
    table{2,6}, ...
    table{2,2}/(table{2,2}+table{5,2}))
disp('---CONTOUR---')
fprintf('F(%d,%d)=%4.2f; p=%5.3f; eta2=%4.2f\n', ...
    table{3,3}, table{5,3}, ...
    table{3,5}, ...
    table{3,6}, ...
    table{3,2}/(table{3,2}+table{5,2}))
disp('---INTERACTION---')
fprintf('F(%d,%d)=%4.2f; p=%5.3f; eta2=%4.2f\n', ...
    table{4,3}, table{5,3}, ...
    table{4,5}, ...
    table{4,6}, ...
    table{4,2}/(table{4,2}+table{5,2}))

% multcomp = multcompare(stats)

[delta1, ~, pval(1), W1, z1, r1] = signrank_full(pse_FG_maskFG, pse_FG_maskFE);
[delta2, ~, pval(2), W2, z2, r2] = signrank_full(pse_FG_maskFG, pse_FE_maskFG);
[delta3, ~, pval(3), W3, z3, r3] = signrank_full(pse_FG_maskFG, pse_FE_maskFE);

[delta4, ~, pval(4), W4, z4, r4] = signrank_full(pse_FG_maskFE, pse_FE_maskFG);
[delta5, ~, pval(5), W5, z5, r5] = signrank_full(pse_FE_maskFG, pse_FE_maskFE);
[delta6, ~, pval(6), W6, z6, r6] = signrank_full(pse_FG_maskFE, pse_FE_maskFE);

% multiple comparison test
[~, ~, pval_adjusted] = BH_correct(pval,.05,2);

fprintf([ ...
    '\n <FG-FG vs. FG-FE>' ...
    '\n -----------------------' ...
    '\n median difference = %4.2f' ...
    '\n W = %5.2f' ...
    '\n z = %5.2f' ...
    '\n p = %5.3f' ...
    '\n r = %4.2f \n'], ...
delta1,W1,z1,pval_adjusted(1),r1)

fprintf([ ...
    '\n <FG-FG vs. FE-FG>' ...
    '\n -----------------------' ...
    '\n median difference = %4.2f' ...
    '\n W = %5.2f' ...
    '\n z = %5.2f' ...
    '\n p = %5.3f' ...
    '\n r = %4.2f \n'], ...
delta2,W2,z2,pval_adjusted(2),r2)

fprintf([ ...
    '\n <FG-FG vs. FE-FE>' ...
    '\n -----------------------' ...
    '\n median difference = %4.2f' ...
    '\n W = %5.2f' ...
    '\n z = %5.2f' ...
    '\n p = %5.3f' ...
    '\n r = %4.2f \n'], ...
delta3,W3,z3,pval_adjusted(3),r3)

figure(1)
hold on
statbar(1,2,.39,pval_adjusted(1))
statbar(1,3,.42,pval_adjusted(2))
statbar(1,4,.45,pval_adjusted(3))

statbar(2,2.95,.25,pval_adjusted(4))
statbar(3.05,4,.25,pval_adjusted(5))
statbar(2,4,.28,pval_adjusted(6))


%% save figure
set(gcf,'papersize',[8.3 11.7])
saveas(gcf,'../results/fig06.pdf')


