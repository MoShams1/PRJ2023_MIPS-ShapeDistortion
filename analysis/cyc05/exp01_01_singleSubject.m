clc
clear
close all


all_files = dir('../../data/cyc05/*exp01*');

isubj = 10;

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
distortion_observed_FG  = pse_norm(strcmp(typ, 'FG'));
distortion_observed_FE  = pse_norm(strcmp(typ, 'FE'));

%% plot scatter

figure

data_mat = [distortion_observed_FG, distortion_observed_FE];
scatterbar_median(data_mat);
errorbar(1:2, median(data_mat), MAD(data_mat), ...
    'o','color','k','linewidth',2,'marker','none')

% scatterbar(data_mat);
% errorbar(1:2, mean(data_mat), SE(data_mat), ...
%     'o','color','k','linewidth',2,'marker','none')

xticks(1:2)
xticklabels({'FG', 'FE'})

ylabel 'Distortion'
yline(0,'-')

pbaspect([1,2,1])

cleanplot

% xticks(1)
% set(gca,'xcolor','none')
% 
% ylabel({'Distortion difference (%)'; '(Frame vs. Flash-Grab)'})
% yticks(-100:50:100)
% ylim([-100 50])
% yline(0,'-')
% 
% pbaspect([1,3,1])


% subplot(1,2,1)
% 
% szMarker = 70;
% alphaMarker = .2;
% lwFit = 4;
% lwBound = 2;
% c = 'k';
% ticks = -1:.2:1;
% 
% hold on
% scatter(distortion_observed_FG, distortion_observed_FE, ...
%     szMarker, c, 'fill', ...
%     'markerfacealpha',alphaMarker)
% h = plot(mdl);
% 
% hData = findobj(h,'DisplayName','Data');
% hFit = findobj(h,'DisplayName','Fit');
% hBound = findobj(h,'DisplayName','Confidence bounds');
% hBound = findobj(h,'LineStyle',hBound.LineStyle,'Color',hBound.Color);
% 
% set(hFit,'color',c,'linewidth',lwFit)
% set(hBound,'color',c,'linestyle',':','linewidth',lwBound)
% 
% hData.MarkerFaceColor = 'none';
% hData.MarkerEdgeColor = 'none';
% 
% % axis([-.1 .5 -.1 .5])
% addUnityLine
% % axis square
% 
% xticks(ticks)
% xlabel({'Distortion'; 'Flash-Grab'})
% xline(0)
% 
% yticks(ticks)
% ylabel({'Distortion'; 'Frame'})
% yline(0)
% 
% text(.4, -.05, ['N = ',num2str(numel(all_files))])
% 
% title ''
% legend off
% cleanplot
% 
% fprintf('\n*** FG median observed distortion: %4.2f', median(distortion_observed_FG))
% fprintf('\n*** FE median observed distortion: %4.2f\n', median(distortion_observed_FE))

%% plot difference

% figure
% 
% data_mat = (distortion_observed_FE-distortion_observed_FG)./distortion_observed_FG*100;
% scatterbar_median(data_mat);
% errorbar(1, median(data_mat), MAD(data_mat), ...
%     'o','color','k','linewidth',2,'marker','none')
% 


%% add statistics

% % scatterbar plot
% subplot(1,2,2)
% [delta, ~, p, W, z, r] = signrank_full(data_mat);
% fprintf([ ...
%     '\n <Distortion difference>' ...
%     '\n -----------------------' ...
%     '\n median difference = %4.1f %%'...
%     '\n W = %5.2f' ...
%     '\n z = %5.2f' ...
%     '\n p = %5.3f' ...
%     '\n r = %4.2f \n'], ...
% delta,W,z,p,r)
% statbar(1,1, -110, p);
% cleanplot



%% save figure
% set(gcf,'papersize',[8.3 11.7])
% saveas(gcf,'../results/fig02.pdf')


