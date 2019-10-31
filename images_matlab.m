function [ret, times, times_press] = images_matlab(imdat,n)

%   This function displays the image which is saved in the input (imdat)
%   and displays it for (n) seconds. In case there is only one input, the
%   script waits for input. In both cases the ime according to the CPU
%   clock is returned as time the script started (times), time the button
%   was pressed (times_press) an the button which was pressed (ret)

%   Copyright (C) February 2018, modified July and September 2018
%   D. Pedrosa, U. Kleinholdermann, M. Wullstein, University Hospital of Gieﬂen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

set(0,'DefaultFigureMenu','none');
iptsetpref('ImshowBorder','tight');
hFig = figure('Color', zeros(1,3), 'Renderer', 'Painters');
WindowAPI(hFig, 'topmost');
WindowAPI(hFig, 'maximize');
WindowAPI(hFig, 'Button', true);
WindowAPI(hFig, 'Enable', 1);
times= toc; image(imdat); axis off;

if nargin == 1                                                              % if there is only one input, wait until button is pressed
    bp = [];
    while isempty(bp)
        waitforbuttonpress
        ky = get(hFig,'CurrentKey');
        if strcmp(ky, 'r') % 114 is the 'r' key
            ret = []; bp = 1; times_press = toc;
        elseif strcmp(ky, 'q')  % 113 is the 'q' key
            ret = 'q'; bp = 1; times_press = toc;
        else
            bp = []; times_press = toc;                                     % if the 'wrong' button was pressed, the loop continues
        end
    end
else                                                                        % if there are two inputs (n) is te time until the figure is closed (see below)
    ret = []; times_press = toc;
    pause(n)
end
close(hFig)                                                                 % close the figure