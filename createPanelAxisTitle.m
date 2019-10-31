
function hAxis = createPanelAxisTitle(hFig, pos, axisTitle)

hPanel = uipanel('parent', hFig, 'Position', pos, 'Units', 'Normalized');

hAxis = axes('position', [0 0 1 1], 'Parent', hPanel);
hAxis.XTick = [];
hAxis.YTick = [];

end
