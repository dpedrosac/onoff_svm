function [hFig, hAxes] = createFigureAndAxes()

hFig = figure('numbertitle', 'off', 'name', 'SVM_ONOFF_videos', ...
    'menubar', 'none', 'toolbar', 'none', 'resize', 'on', ...
    'renderer', 'painters', 'position', [0 0 960 480], ...
    'HandleVisibility', 'callback', 'tag', 'videoSVM');
hAxes = createPanelAxisTitle(hFig, [.1 .1 .36 .6], 'Video');

end