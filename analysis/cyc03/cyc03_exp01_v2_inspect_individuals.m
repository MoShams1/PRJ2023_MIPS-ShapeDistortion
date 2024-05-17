clc
clear
close all

% Specify the path to the JSON file

jsonFilePath = '../../data/cyc03/MS01_task01_v2_20231023_122943.json';


% Open the JSON file and read its content
fileID = fopen(jsonFilePath);
jsonContent = fread(fileID, '*char')';
fclose(fileID);

% Parse the JSON content
jsonData = jsondecode(jsonContent);

% convert structure to arrays
typ = struct2cell(jsonData.stimulus_type);
dir = cell2mat(struct2cell(jsonData.postflash_dir));
pse = cell2mat(struct2cell(jsonData.pse_x));

% rectify pse direction
% pse(dir>0) = -pse(dir>0);

% create data cell
typ_list = {'FG', 'GF', 'FE'};
dir_list = [-1, 1];

col_cntr = 0;
for ityp = 1:numel(typ_list)
    col_cntr = col_cntr+1;
    ind_typ = strcmp(typ, typ_list{ityp});    
    pse_cell{col_cntr} = pse(ind_typ & dir<0);
    pse_cell{col_cntr+3} = pse(ind_typ & dir>0);
end

pse_mat = cell2mat(pse_cell);

%% plot

figure('units','normalized','outerposition',[.2 .3 .2 .5])
hold on

scatterbar(pse_cell(1:3), 30, 'r');
scatterbar(pse_cell(4:6), 30, 'b');

xticklabels(typ_list)
xlim([.5 3.5])
xticks(1:3)
xlabel 'Annulus types'

ylim([-1.1 1.1] * 1.2)
yticks(-1:.25:1)
yline(0)
ylabel 'Point of subjective equality'

title 'Raw data'

text(1,1.2,'Post-Flash Rightward Motion','color','b')
text(1,1.1,'Post-Flash Leftward Motion','color','r')
cleanplot

%%
function scatterbar(A,marksz,color)
% A: a cell of cetegories

ncat    = numel(A); % number of categories
stdx    = .05; % standard deviation of scatters in each category
linelm  = .3; % line length for median
alpha = .3;

hold on
for icat = 1:ncat    
    rng default
    n = numel(A{icat});
    x = randn(n,1)*stdx + icat;
    
    scatter(x,A{icat},marksz,color,'o','fill','markerfacealpha',alpha);
    line([icat-linelm icat+linelm],[nanmedian(A{icat}) nanmedian(A{icat})],...
        'color',color,'linewidth',2);
end

xlim([0 ncat+1])
set(gca,'xtick',1:ncat)
end
