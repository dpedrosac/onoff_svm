function videos_matlab_final(videoSrc, s)

%   This function displays the video that is currently used, so that
%   participants are instructed which task they are supposed to perform

%   Copyright (C) July 2018
%   D. Pedrosa, U. Kleinholdermann and M. Wullstein, University Hospital of Gieﬂen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

%% Begin with general settings, in order to create a figure without borders, maximum size and a black background
set(0,'DefaultFigureMenu','none');
iptsetpref('ImshowBorder','tight');
hFig = figure('Color', zeros(1,3), 'Renderer', 'OpenGL');
WindowAPI(hFig, 'topmost');
WindowAPI(hFig, 'maximize');
WindowAPI(hFig, 'OuterPosition', 'work')
WindowAPI(hFig, 'Button', false);
WindowAPI(hFig, 'Enable', 0);
axes('Visible', 'off', 'Units', 'normalized');

%% Start displaying the movie saved as {s}
movie(s,1,videoSrc.FrameRate);
close(hFig)                                                                 % closes the figure to avoid too many open figures