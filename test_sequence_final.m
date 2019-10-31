function [t1, t2] = test_sequence_final(test_trial_order, imfiles, videoSrc, sframes)

%   This function runs a test seuqence. In order to make to script more
%   digestible, this for-loop was incorporated into a separate loop and all
%   needed variables were included as inputs [see also seq_matlab for
%   similar function]

%   Copyright (C) February 2018, modified July and September 2018
%   D. Pedrosa, U. Kleinholdermann, M. Wullstein, University Hospital of Gieﬂen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

for test = 1:numel(test_trial_order) % loop through random order of test trials
    videos_matlab_final(videoSrc{test_trial_order(test)}, ...               % the next two lines read the video in order to display it
    sframes{test_trial_order(test)})
    times = nan(1,numel(imfiles));                                  
    set(0,'DefaultFigureMenu','none');
    iptsetpref('ImshowBorder','tight');
    hFig = figure('Color', zeros(1,3), 'Renderer', 'Painters');
    WindowAPI(hFig, 'topmost');
    WindowAPI(hFig, 'maximize');
    WindowAPI(hFig, 'Button', true);
    WindowAPI(hFig, 'Enable', 1);
    
    l = [1, 1, 1, 4.5, .8];                                                 %
    for k = 1:numel(imfiles)
        times(k)= toc; image(imfiles{k}); axis off; pause(l(k));
    end
    t1 = times(4); t2 = times(5);
    close(hFig)
end
