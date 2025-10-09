clc
clear
close all

all_files = dir('../../data/cyc05/*exp02*');

ind_exclude = 6;

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
    click_x = cell2mat(struct2cell(jsonData.click_x));
    probe_x = cell2mat(struct2cell(jsonData.probe_x));
    click_err_x = click_x - probe_x;
    click_y = cell2mat(struct2cell(jsonData.click_y));
    probe_y = cell2mat(struct2cell(jsonData.probe_y));
    click_err_y = click_y - probe_y;


    click_err_x(dir<0) = -click_err_x(dir<0);
    probe_lead = probe_x;
    probe_lead(dir<0) = -probe_lead(dir<0);

    click_err_x_FG(isubj,:) = mean([
        click_err_x(strcmp(typ,'FG') & probe_lead<0 ), ...
        click_err_x(strcmp(typ,'FG') & probe_lead==0), ...
        click_err_x(strcmp(typ,'FG') & probe_lead>0 ) ...
        ],1);

    click_err_x_FE(isubj,:) = mean([
        click_err_x(strcmp(typ,'FE') & probe_lead<0 ), ...
        click_err_x(strcmp(typ,'FE') & probe_lead==0), ...
        click_err_x(strcmp(typ,'FE') & probe_lead>0 ) ...
        ],1);

    click_err_y_FG(isubj,:) = mean([
        click_err_y(strcmp(typ,'FG') & probe_lead<0), ...
        click_err_y(strcmp(typ,'FG') & probe_lead==0), ...
        click_err_y(strcmp(typ,'FG') & probe_lead>0) ...
        ],1);

    click_err_y_FE(isubj,:) = mean([
        click_err_y(strcmp(typ,'FE') & probe_lead<0), ...
        click_err_y(strcmp(typ,'FE') & probe_lead==0), ...
        click_err_y(strcmp(typ,'FE') & probe_lead>0) ...
        ],1);

end

%% apply exclusion
click_err_x_FG(ind_exclude,:) = [];
click_err_x_FE(ind_exclude,:) = [];
click_err_y_FG(ind_exclude,:) = [];
click_err_y_FE(ind_exclude,:) = [];
nsubjects = size(click_err_x_FG,1);

%% retrieve actual click locations

probeOffset_x = max(probe_x);
% probeOffset_y = max(probe_y);
probeOffset_y = 5;

% FG
backDotX_FG = click_err_x_FG(:,1) - probeOffset_x;
centerDotX_FG = click_err_x_FG(:,2);
frontDotX_FG = click_err_x_FG(:,3) + probeOffset_x;

backDotY_FG = click_err_y_FG(:,1) + probeOffset_y;
centerDotY_FG = click_err_y_FG(:,2) + probeOffset_y;
frontDotY_FG = click_err_y_FG(:,3) + probeOffset_y;

% FE
backDotX_FE = click_err_x_FE(:,1) - probeOffset_x;
centerDotX_FE = click_err_x_FE(:,2);
frontDotX_FE = click_err_x_FE(:,3) + probeOffset_x;

backDotY_FE = click_err_y_FE(:,1) + probeOffset_y;
centerDotY_FE = click_err_y_FE(:,2) + probeOffset_y;
frontDotY_FE = click_err_y_FE(:,3) + probeOffset_y;



%% save data
save click_positions.mat ...
    backDotX_FG centerDotX_FG frontDotX_FG ...
    backDotX_FE centerDotX_FE frontDotX_FE


%% 2D plot of the click positions

figure('units','inches','outerposition',[5, 3, 7, 4])

c = lines(7);
cBack = c(2,:);
cCenter = zeros(1,3);
cFront = c(5,:);
% cBG = .95;
szMarker_click = 50;
szMarker_probe = 10;
szMarker_median = 6;
lwMarker = 2;
alphaMarker = .2;
alphaEllipse = .3;
lwErrorBar = 1;

axis_limits = [-3 3 1.5 7.5];
ticks = -10:1:10;

% axis_limits = [-6 6 -6 6];
% ticks = -10:2:10;



% FG
subplot(1,2,1)
hold on

plot(-probeOffset_x, probeOffset_y, ...
    'o', 'markersize',szMarker_probe, 'linewidth',lwMarker, ...
    'markeredgecolor',cBack,'markerfacecolor','none')
plot(0, probeOffset_y, ...
    'o', 'markersize',szMarker_probe,  'linewidth',lwMarker, ...
    'markeredgecolor',cCenter,'markerfacecolor','none')
plot(probeOffset_x, probeOffset_y, ...
    'o', 'markersize',szMarker_probe,  'linewidth',lwMarker, ...
    'markeredgecolor',cFront,'markerfacecolor','none')

% ellipse(median(backDotX_FG), median(backDotY_FG), ...
%     MAD(backDotX_FG), MAD(backDotY_FG),...
%     cBack,alphaEllipse);
% ellipse(median(centerDotX_FG), median(centerDotY_FG), ...
%     MAD(centerDotX_FG), MAD(centerDotY_FG),...
%     cCenter,alphaEllipse);
% ellipse(median(frontDotX_FG), median(frontDotY_FG), ...
%     MAD(frontDotX_FG), MAD(frontDotY_FG),...
%     cFront,alphaEllipse);

errorbar(median(backDotX_FG),median(backDotY_FG), ...
    -MAD(backDotY_FG), +MAD(backDotY_FG), ...
    -MAD(backDotX_FG), +MAD(backDotX_FG), ...
    'o','color',cBack,'markerfacecolor',cBack, 'markeredgecolor','none', ...
    'markersize',szMarker_median,'linewidth',lwErrorBar);
errorbar(median(centerDotX_FG),median(centerDotY_FG), ...
    -MAD(centerDotY_FG), +MAD(centerDotY_FG), ...
    -MAD(centerDotX_FG), +MAD(centerDotX_FG), ...
    'o','color',cCenter,'markerfacecolor',cCenter, 'markeredgecolor','none', ...
    'markersize',szMarker_median,'linewidth',lwErrorBar);
errorbar(median(frontDotX_FG),median(frontDotY_FG), ...
    -MAD(frontDotY_FG), +MAD(frontDotY_FG), ...
    -MAD(frontDotX_FG), +MAD(frontDotX_FG), ...
    'o','color',cFront,'markerfacecolor',cFront, 'markeredgecolor','none', ...
    'markersize',szMarker_median,'linewidth',lwErrorBar);


title Flash-Grab
xlabel 'Horizontal position (dva)'
xticks(ticks)
ylabel 'Vertical position (dva)'
yticks(ticks)
axis(axis_limits)
axis square
cleanplot
% set(gca,'color',cBG.*ones(1,3))
box on
grid on



% FE
subplot(1,2,2)
hold on

plot(-probeOffset_x, probeOffset_y, ...
    'o', 'markersize',szMarker_probe, 'linewidth',lwMarker, ...
    'markeredgecolor',cBack,'markerfacecolor','none')
plot(0, probeOffset_y, ...
    'o', 'markersize',szMarker_probe, 'linewidth',lwMarker, ...
    'markeredgecolor',cCenter,'markerfacecolor','none')
plot(probeOffset_x, probeOffset_y, ...
    'o', 'markersize',szMarker_probe, 'linewidth',lwMarker, ...
    'markeredgecolor',cFront,'markerfacecolor','none')

% ellipse(median(backDotX_FE), median(backDotY_FE), ...
%     MAD(backDotX_FE), MAD(backDotY_FE),...
%     cBack,alphaEllipse);
% ellipse(median(centerDotX_FE), median(centerDotY_FE), ...
%     MAD(centerDotX_FE), MAD(centerDotY_FE),...
%     cCenter,alphaEllipse);
% ellipse(median(frontDotX_FE), median(frontDotY_FE), ...
%     MAD(frontDotX_FE), MAD(frontDotY_FE),...
%     cFront,alphaEllipse);

errorbar(median(backDotX_FE),median(backDotY_FE), ...
    -MAD(backDotY_FE), +MAD(backDotY_FE), ...
    -MAD(backDotX_FE), +MAD(backDotX_FE), ...
    'o','color',cBack,'markerfacecolor',cBack, 'markeredgecolor','none', ...
    'markersize',szMarker_median,'linewidth',lwErrorBar);
errorbar(median(centerDotX_FE),median(centerDotY_FE), ...
    -MAD(centerDotY_FE), +MAD(centerDotY_FE), ...
    -MAD(centerDotX_FE), +MAD(centerDotX_FE), ...
    'o','color',cCenter,'markerfacecolor',cCenter, 'markeredgecolor','none', ...
    'markersize',szMarker_median,'linewidth',lwErrorBar);
errorbar(median(frontDotX_FE),median(frontDotY_FE), ...
    -MAD(frontDotY_FE), +MAD(frontDotY_FE), ...
    -MAD(frontDotX_FE), +MAD(frontDotX_FE), ...
    'o','color',cFront,'markerfacecolor',cFront, 'markeredgecolor','none', ...
    'markersize',szMarker_median,'linewidth',lwErrorBar);


title Frame
xlabel 'Horizontal position (dva)'
xticks(ticks)
ylabel 'Vertical position (dva)'
% yticks([])

axis(axis_limits)
axis square

text(1.75, 2, ['N = ',num2str(nsubjects)])

cleanplot

% set(gca,'color',cBG.*ones(1,3))
% set(gcf,'InvertHardcopy','off')
box on
grid on


%% save figure
% set(gcf,'papersize',[8.3 11.7])
% saveas(gcf,'../results/fig03_wFixDot.pdf')


