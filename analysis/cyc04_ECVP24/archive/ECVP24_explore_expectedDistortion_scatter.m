clc
clear
close all

all_files = dir('../../data/cyc04/*exp02_v1*');

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

end

barLength = .95;
probeY = 4.82;

% FG
backDotX_FG = click_err_x_FG(:,1) - barLength;
centerDotX_FG = click_err_x_FG(:,2);
frontDotX_FG = click_err_x_FG(:,3) + barLength;

barLength_FG = abs(frontDotX_FG - backDotX_FG);
leftHand = abs(centerDotX_FG - backDotX_FG);
rightHand = abs(centerDotX_FG - frontDotX_FG);
distortion_FG_expected = (leftHand-rightHand) ./ barLength_FG;

% FE
backDotX_FE = click_err_x_FE(:,1) - barLength;
centerDotX_FE = click_err_x_FE(:,2);
frontDotX_FE = click_err_x_FE(:,3) + barLength;

barLength_FE = abs(frontDotX_FE - backDotX_FE);
leftHand = abs(centerDotX_FE - backDotX_FE);
rightHand = abs(centerDotX_FE - frontDotX_FE);
distortion_FE_expected = (leftHand-rightHand) ./ barLength_FE;



%% save data
save distortion_expected.mat ...
    distortion_FG_expected ...
    distortion_FE_expected



%% compare position shifts of each probe across the two stimuli

figure
scatter(distortion_FG_expected, distortion_FE_expected, 'fill')
addUnityLine
axis square
xlabel FG
ylabel FE
cleanplot

