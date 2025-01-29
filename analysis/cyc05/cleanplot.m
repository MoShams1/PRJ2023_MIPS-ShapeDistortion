% cleanplot
% Mohammad Shams
% m.shamsahmar@gmail.com

function cleanplot
set(gca,'tickdir','out','color','none')
box off
ax = gca;

if ~isempty(ax.Legend)
    legend boxoff
end

set(gca,'TitleFontWeight','bold','TitleFontSizeMultiplier',1)
set(gca,'LabelFontSizeMultiplier',1.2)
fontsize(gca,scale=1)
