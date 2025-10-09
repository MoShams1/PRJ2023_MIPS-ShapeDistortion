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

data_mat = [
    distortion_observed_cross_disc,...
    distortion_observed_cross_frame,...
    distortion_observed_frame_disc,...
    distortion_observed_frame_frame];


% %% rotation vs. translation
% 
% % plot scatter
% 
% figure('units','inches','outerposition',[1 1 7.5 8])
% subplot(2,3,[1 2])
% hold on
% 
% szMarker = 100;
% alphaMarker = .4;
% c = 'k';
% ticks = -1:.25:1;
% lims_scatter = [-.2 1];
% lims_diff = [-.1 .4];
% 
% data_mat_rotation = mean(data_mat(:,1:2),2);
% data_mat_translation = mean(data_mat(:,3:4),2);
% 
% scatter(data_mat_translation, data_mat_rotation, ...
%       szMarker, c, 'fill', ...
%       'markerfacealpha',alphaMarker);
% 
% 
% xlabel 'Shape distortion (Rotation)'
% xline(0,'-')
% xticks(ticks)
% xlim(lims_scatter)
% 
% ylabel 'Shape distortion (Translation)'
% yline(0,'-')
% yticks(ticks)
% ylim(lims_scatter)
% 
% text(.75, -.1, ['N = ',num2str(nsubjects)])
% 
% axis square
% addUnityLine
% 
% cleanplot
% 
% 
% % plot difference
% 
% subplot(2,3,3)
% hold on
% 
% data_mat_trajectory_diff = data_mat_rotation - data_mat_translation;
% xs = scatterbar_median(data_mat_trajectory_diff);
% errorbar(1, median(data_mat_trajectory_diff), MAD(data_mat_trajectory_diff), ...
%     'o','color','k','linewidth',2,'marker','none')
% 
% set(gca,'xcolor','none')
% 
% ylabel({'Shape distortion difference', '(Translation – Rotation)'})
% yline(0,'-')
% ylim(lims_diff)
% 
% [delta, ~, p, W, z, r] = signrank_full(data_mat_rotation, data_mat_translation);
% fprintf([ ...
%     '\n <Rotation vs. Translation>' ...
%     '\n -----------------------' ...
%     '\n median difference = %4.2f'...
%     '\n W = %5.2f' ...
%     '\n z = %5.2f' ...
%     '\n p = %5.3f' ...
%     '\n r = %4.2f \n'], ...
% delta,W,z,p,r)
% statbar(1, 1, .4, p);
% 
% pbaspect([1,2,1])
% 
% cleanplot
% 
% 
% 
% %% curved vs. straight
% 
% % plot scatter
% 
% subplot(2,3,[4 5])
% hold on
% 
% data_mat_curved = mean(data_mat(:,[1,3]),2);
% data_mat_straight = mean(data_mat(:,[2, 4]),2);
% 
% scatter(data_mat_straight, data_mat_curved, ...
%       szMarker, c, 'fill', ...
%       'markerfacealpha',alphaMarker);
% 
% 
% xlabel 'Shape distortion (Straight)'
% xline(0,'-')
% xticks(ticks)
% xlim(lims_scatter)
% 
% ylabel 'Shape distortion (Curved)'
% yline(0,'-')
% yticks(ticks)
% ylim(lims_scatter)
% 
% text(.75, -.1, ['N = ',num2str(nsubjects)])
% 
% axis square
% addUnityLine
% 
% cleanplot
% 
% 
% % plot difference
% 
% subplot(2,3,6)
% hold on
% 
% data_mat_contour_diff = data_mat_curved - data_mat_straight;
% xs = scatterbar_median(data_mat_contour_diff);
% errorbar(1, median(data_mat_contour_diff), MAD(data_mat_contour_diff), ...
%     'o','color','k','linewidth',2,'marker','none')
% 
% set(gca,'xcolor','none')
% 
% ylabel({'Shape distortion difference', '(Curved – Straight)'})
% yline(0,'-')
% ylim(lims_diff)
% 
% [delta, ~, p, W, z, r] = signrank_full(data_mat_curved, data_mat_straight);
% fprintf([ ...
%     '\n <Curved vs. Straight>' ...
%     '\n -----------------------' ...
%     '\n median difference = %4.2f'...
%     '\n W = %5.2f' ...
%     '\n z = %5.2f' ...
%     '\n p = %5.3f' ...
%     '\n r = %4.2f \n'], ...
% delta,W,z,p,r)
% statbar(1, 1, .4, p);
% 
% pbaspect([1,2,1])
% 
% cleanplot
% 
% %% save figure
% set(gcf,'papersize',[8.3 11.7])
% saveas(gcf,'../../results/fig10.pdf')

%%
figure('units','inches','outerposition',[0 0 6 4])

subplot(1,2,1)
hold on
errorbar(1:2, ...
    [median(data_mat(:,4)), median(data_mat(:,2))], ...
    [MAD(data_mat(:,4)), MAD(data_mat(:,2))], ...
    'o-', 'markerfacecolor',.7*ones(1,3),'color',.7*ones(1,3),'linewidth',1)
errorbar(1:2, ...
    [median(data_mat(:,3)), median(data_mat(:,1))], ...
    [MAD(data_mat(:,3)), MAD(data_mat(:,1))], ...
    'o-', 'markerfacecolor','k','color','k','linewidth',1)

xticks(1:2)
xticklabels({'Translation','Rotation'})
xlim([.5 2.5])

ylabel('Shape distortion')
yline(0)
ylim([-.05 .45])

legend Straight Curved location northwest

cleanplot

%% non-parametric interaction:
% (curved_rotation - straight_rotation) - 
% (curved_translation - straight_translation)

contour_rotation = data_mat(:,1)-data_mat(:,2);
contour_translation = data_mat(:,3)-data_mat(:,4);

data_mat_diff = contour_rotation - contour_translation;

subplot(1,2,2)
xs = scatterbar_median(data_mat_diff);
errorbar(1, median(data_mat_diff), MAD(data_mat_diff), ...
    'o','color','k','linewidth',2,'marker','none')

set(gca,'xcolor','none')

ylabel({'(Rot. Curved – Rot. Straight) minus'; '(Trans. Curved – Trans. Straight)'})
yline(0,'-')
ylim([-.31 .31])

[delta, ~, p, W, z, r] = signrank_full(data_mat_diff);
fprintf([ ...
    '\n <Motion vs. Contour Interaction>' ...
    '\n -----------------------' ...
    '\n median difference = %4.2f'...
    '\n W = %5.2f' ...
    '\n z = %5.2f' ...
    '\n p = %5.3f' ...
    '\n r = %4.2f \n'], ...
delta,W,z,p,r)
statbar(1, 1, .32, p);

pbaspect([1,2,1])

cleanplot

%% repeated measure anova stat

T = array2table(data_mat, ...
    'VariableNames', {'Rot_Curved', 'Rot_Straight', 'Trans_Curved', 'Trans_Straight'});

within = table(...
    categorical({'Rotation'; 'Rotation'; 'Translation'; 'Translation'}), ...
    categorical({'Curved'; 'Straight'; 'Curved'; 'Straight'}), ...
    'VariableNames', {'Motion', 'Contour'});

rm = fitrm(T, 'Rot_Curved-Trans_Straight ~ 1', 'WithinDesign', within);
ranovatbl = ranova(rm, 'WithinModel', 'Motion*Contour');

% Motion
ss_motion = ranovatbl.SumSq('(Intercept):Motion');
ss_motion_error = ranovatbl.SumSq('Error(Motion)');
eta_p2_motion = ss_motion / (ss_motion + ss_motion_error);

fprintf([ ...
    '\n <Motion>' ...
    '\n -----------------------' ...
    '\n F = %5.2f'...
    '\n p = %5.3f' ...
    '\n etap2 = %4.2f\n'], ...
    ranovatbl.F('(Intercept):Motion'), ...
    ranovatbl.pValue('(Intercept):Motion'), ...
    eta_p2_motion)

% Contour
ss_contour = ranovatbl.SumSq('(Intercept):Contour');
ss_contour_error = ranovatbl.SumSq('Error(Contour)');
eta_p2_contour = ss_contour / (ss_contour + ss_contour_error);

fprintf([ ...
    '\n <Contour>' ...
    '\n -----------------------' ...
    '\n F = %5.2f'...
    '\n p = %5.3f' ...
    '\n etap2 = %4.2f\n'], ...
    ranovatbl.F('(Intercept):Contour'), ...
    ranovatbl.pValue('(Intercept):Contour'), ...
    eta_p2_contour)

% Interaction
ss_interaction = ranovatbl.SumSq('(Intercept):Motion:Contour');
ss_interaction_error = ranovatbl.SumSq('Error(Motion:Contour)');
eta_p2_interaction = ss_interaction / (ss_interaction + ss_interaction_error);

fprintf([ ...
    '\n <Interaction>' ...
    '\n -----------------------' ...
    '\n F = %5.2f'...
    '\n p = %5.3f' ...
    '\n etap2 = %4.2f\n'], ...
    ranovatbl.F('(Intercept):Motion:Contour'), ...
    ranovatbl.pValue('(Intercept):Motion:Contour'), ...
    eta_p2_interaction)

%% normality test for ANOVA
% 
% % Compute the mean for each participant across all conditions
% participantMeans = mean(data_mat, 2);
% 
% % Compute the condition means (across participants)
% conditionMeans = mean(data_mat, 1);
% 
% % Compute the grand mean
% grandMean = mean(conditionMeans);
% 
% 
% residuals = zeros(size(data_mat));
% 
% for i = 1:size(data_mat, 1)  % each participant
%     for j = 1:size(data_mat, 2)  % each condition
%         predicted = participantMeans(i) + conditionMeans(j) - grandMean;
%         residuals(i,j) = data_mat(i,j) - predicted;
%     end
% end
% 
% for j = 1:4
%     figure;
%     qqplot(residuals(:,j));
%     title(['Q-Q plot of residuals for Condition ' num2str(j)]);
% end
% 
% for j = 1:4
%     [~,p] = kstest(residuals(:,j));
%     fprintf('Condition %d: K-S test p = %.3f\n', j, p);
% end
% 
% for j = 1:4
%     figure;
%     histogram(residuals(:,j));
%     title(['Histogram of residuals for Condition ' num2str(j)]);
% end

%% save figure
set(gcf,'papersize',[8.3 11.7])
saveas(gcf,'../../results/fig11.pdf')




