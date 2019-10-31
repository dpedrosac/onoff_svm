function [times] = seq_matlab(imfiles, n)
%   This function runs a the entire task, that is the countdown, 
%   the green cross and the red cross and provides the timings which 
%   are stored in a separate table; (n) is the time which the tasks 
%   (green cross) lasts

%   Copyright (C) February 2018, modified July 2018
%   D. Pedrosa, U. Kleinholdermann, M. Wullstein, University Hospital of Gieﬂen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

times = nan(1,numel(imfiles));                                              % pre-allocates space
set(0,'DefaultFigureMenu','none');                                          % settings for WindowsAPI
iptsetpref('ImshowBorder','tight');
hFig = figure('Color', zeros(1,3), 'Renderer', 'Painters');
WindowAPI(hFig, 'topmost');
WindowAPI(hFig, 'maximize');
WindowAPI(hFig, 'Button', true);
WindowAPI(hFig, 'Enable', 1);

l = [1,1,1,n,.8];                                                           % times for the different parts of the tasks (countdown,countdown,countdown,gc,rc)
for k = 1:numel(imfiles)
    times(k)= toc; image(imfiles{k}); axis off; pause(l(k));                % loop through files and display the images
end
close(hFig)                                                                 % closes the figure