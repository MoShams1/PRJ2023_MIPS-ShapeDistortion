
clear

all_files = dir('../../data/cyc04/*exp02_v2*');

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
    click_err = click_x - probe_x;

    click_err(dir<0) = -click_err(dir<0);
    probe_lead = probe_x;
    probe_lead(dir<0) = -probe_lead(dir<0);

    click_err_FG(isubj,:) = mean([
        click_err(strcmp(typ,'FG') & probe_lead<0), ...
        click_err(strcmp(typ,'FG') & probe_lead==0), ...
        click_err(strcmp(typ,'FG') & probe_lead>0) ...
        ],1);

    click_err_FE(isubj,:) = mean([
        click_err(strcmp(typ,'FE') & probe_lead<0), ...
        click_err(strcmp(typ,'FE') & probe_lead==0), ...
        click_err(strcmp(typ,'FE') & probe_lead>0) ...
        ],1);
end

%% plot (errorbar)

x_labels = {'backProbe','edgeProbe','frontProbe'};

hold on

x = 1:3;
cmap = lines(7);
lw = 2;
lwe = 1;
marksz = 6;

y_FG = mean(click_err_FG);
e_FG = SE(click_err_FG);
plot(x,y_FG,'linewidth',lw,'color','k')
errorbar(x,y_FG,e_FG,'o','linewidth',lwe,'color','k','linestyle','none', ...
    'markerfacecolor','k','markersize',marksz);

y_FE = mean(click_err_FE);
e_FE = SE(click_err_FE);
plot(x,y_FE,'linewidth',lw,'color',cmap(2,:))
errorbar(x,y_FE,e_FE, ...
    'o','linewidth',lwe,'color',cmap(2,:),'linestyle','none', ...
    'markerfacecolor',cmap(2,:),'markersize',marksz);

xticks(1:3)
xticklabels(x_labels)
xlim([.5 3.5])

ylim([0 3])
yticks(0:3)
yline(0)

title 'w/ fixation mark'

text(2, .2, ['N = ', num2str(numel(all_files))])

cleanplot