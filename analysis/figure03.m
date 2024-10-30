clc
clear
close all

all_files = dir('../data/cyc04/*exp02_v1*');

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
        click_err_x(strcmp(typ,'FG') & probe_lead<0), ...
        click_err_x(strcmp(typ,'FG') & probe_lead==0), ...
        click_err_x(strcmp(typ,'FG') & probe_lead>0) ...
        ],1);

    click_err_x_FE(isubj,:) = mean([
        click_err_x(strcmp(typ,'FE') & probe_lead<0), ...
        click_err_x(strcmp(typ,'FE') & probe_lead==0), ...
        click_err_x(strcmp(typ,'FE') & probe_lead>0) ...
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



%% retrieve actual click locations

barLength = .95;
probeY = 4.82;

% FG
backDotX_FG = click_err_x_FG(:,1) - barLength;
centerDotX_FG = click_err_x_FG(:,2);
frontDotX_FG = click_err_x_FG(:,3) + barLength;

backDotY_FG = click_err_y_FG(:,1) + probeY;
centerDotY_FG = click_err_y_FG(:,2) + probeY;
frontDotY_FG = click_err_y_FG(:,3) + probeY;

% FE
backDotX_FE = click_err_x_FE(:,1) - barLength;
centerDotX_FE = click_err_x_FE(:,2);
frontDotX_FE = click_err_x_FE(:,3) + barLength;

backDotY_FE = click_err_y_FE(:,1) + probeY;
centerDotY_FE = click_err_y_FE(:,2) + probeY;
frontDotY_FE = click_err_y_FE(:,3) + probeY;



%% save data
save click_positions.mat ...
    backDotX_FG centerDotX_FG frontDotX_FG ...
    backDotX_FE centerDotX_FE frontDotX_FE


%% 2D plot of the click positions

figure('units','inches','outerposition',[0, 0, 6.5, 4])

c = lines(7);
cBack = c(2,:);
cCenter = zeros(1,3);
cFront = c(5,:);
cBG = .95;
szMarker_click = 50;
szMarker_probe = 10;
szMarker_mean = 6;
lwMarker = 2;
alphaMarker = .2;
lwErrorBar = 2;

probe_x = .95;
probe_y = 4.82;

axis_limits = [-2 4 1 7];
ticks = -10:2:10;



% FG
subplot(1,2,1)
hold on

plot(-probe_x, probe_y, ...
    'o', 'markersize',szMarker_probe, 'linewidth',lwMarker, ...
    'markeredgecolor',cBack,'markerfacecolor','none')
plot(0, probe_y, ...
    'o', 'markersize',szMarker_probe,  'linewidth',lwMarker, ...
    'markeredgecolor',cCenter,'markerfacecolor','none')
plot(probe_x, probe_y, ...
    'o', 'markersize',szMarker_probe,  'linewidth',lwMarker, ...
    'markeredgecolor',cFront,'markerfacecolor','none')

errorbar(mean(backDotX_FG),mean(backDotY_FG), ...
    -SE(backDotY_FG), +SE(backDotY_FG), ...
    -SE(backDotX_FG), +SE(backDotX_FG), ...
    'o','color',cBack,'markerfacecolor',cBack, 'markeredgecolor','none', ...
    'markersize',szMarker_mean,'linewidth',lwErrorBar);
errorbar(mean(centerDotX_FG),mean(centerDotY_FG), ...
    -SE(centerDotY_FG), +SE(centerDotY_FG), ...
    -SE(centerDotX_FG), +SE(centerDotX_FG), ...
    'o','color',cCenter,'markerfacecolor',cCenter, 'markeredgecolor','none', ...
    'markersize',szMarker_mean,'linewidth',lwErrorBar);
errorbar(mean(frontDotX_FG),mean(frontDotY_FG), ...
    -SE(frontDotY_FG), +SE(frontDotY_FG), ...
    -SE(frontDotX_FG), +SE(frontDotX_FG), ...
    'o','color',cFront,'markerfacecolor',cFront, 'markeredgecolor','none', ...
    'markersize',szMarker_mean,'linewidth',lwErrorBar);


title Flash-Grab
xlabel 'Horizontal position (dva)'
xticks(ticks)
ylabel 'Vertical position (dva)'
yticks(ticks)
axis(axis_limits)
axis square
cleanplot
set(gca,'color',cBG.*ones(1,3))
box on
grid on



% FE
subplot(1,2,2)
hold on

plot(-probe_x, probe_y, ...
    'o', 'markersize',szMarker_probe, 'linewidth',lwMarker, ...
    'markeredgecolor',cBack,'markerfacecolor','none')
plot(0, probe_y, ...
    'o', 'markersize',szMarker_probe, 'linewidth',lwMarker, ...
    'markeredgecolor',cCenter,'markerfacecolor','none')
plot(probe_x, probe_y, ...
    'o', 'markersize',szMarker_probe, 'linewidth',lwMarker, ...
    'markeredgecolor',cFront,'markerfacecolor','none')

errorbar(mean(backDotX_FE),mean(backDotY_FE), ...
    -SE(backDotY_FE), +SE(backDotY_FE), ...
    -SE(backDotX_FE), +SE(backDotX_FE), ...
    'o','color',cBack,'markerfacecolor',cBack, 'markeredgecolor','none', ...
    'markersize',szMarker_mean,'linewidth',lwErrorBar);
errorbar(mean(centerDotX_FE),mean(centerDotY_FE), ...
    -SE(centerDotY_FE), +SE(centerDotY_FE), ...
    -SE(centerDotX_FE), +SE(centerDotX_FE), ...
    'o','color',cCenter,'markerfacecolor',cCenter, 'markeredgecolor','none', ...
    'markersize',szMarker_mean,'linewidth',lwErrorBar);
errorbar(mean(frontDotX_FE),mean(frontDotY_FE), ...
    -SE(frontDotY_FE), +SE(frontDotY_FE), ...
    -SE(frontDotX_FE), +SE(frontDotX_FE), ...
    'o','color',cFront,'markerfacecolor',cFront, 'markeredgecolor','none', ...
    'markersize',szMarker_mean,'linewidth',lwErrorBar);


title Frame
xlabel 'Horizontal position (dva)'
xticks(ticks)
ylabel 'Vertical position (dva)'
yticks(ticks)
axis(axis_limits)
axis square
cleanplot
set(gca,'color',cBG.*ones(1,3))
set(gcf,'InvertHardcopy','off')
box on
grid on



%% save figure
set(gcf,'paperSize',[8.3 11.7])
saveas(gcf,'../results/fig03.pdf')


