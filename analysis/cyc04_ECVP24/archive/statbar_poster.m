% statbar_poster
% Mohammad Shams <m.shamsahmar@gmail.com>
% June 2024

function statbar_poster(x1, x2, y, p)
ylimits = ylim(gca);
ylength = ylimits(2)-ylimits(1);
lw = 1;
whisker_length = .01 * ylength;
fontsz = 35;
text_offset = .01 * ylength;

if p <= .001
    text_message = '***';
elseif p <= .01
    text_message = '**';
elseif p <= .05
    text_message = '*';
else
    text_message = '';
end
if x1 ~= x2
    line([x1 x2], [y y], 'linewidth', lw,'color','k')
    line([x1 x1], [y y-whisker_length], 'linewidth', lw,'color','k')
    line([x2 x2], [y y-whisker_length], 'linewidth', lw,'color','k')
end
text(mean([x1,x2]),y+text_offset,text_message,'horiz','center','fontsize',fontsz)