function [t1, t2] = test_sequence(maindir, test_trial_order, movie_names, imfiles)

%   This function runs a test seuqence. In order to make to script more
%   digestible, this for-loop was incorporated into a separate loop and all
%   needed variables were included as inputs

%   Copyright (C) February 2018
%   D. Pedrosa, University Hospital of Gieﬂen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.


for test = 1:numel(test_trial_order) % loop through random order of test trials
    mviname = strcat(maindir, 'videos\', ...                                % name of the movie in this condition
        movie_names{test_trial_order(test)});
    videos_matlab(mviname)
    times = nan(1,numel(imfiles));
    % movie_names = {'posture_short.v1.4.mov', 'tapping_short.v1.4.mov', ...    % name of the (short) videos that intend to explain what subjects need to do
    %     'diadochokinesia_short.v1.4.mov', 'rest_short.v1.4.mov'};
    matlab.video.read.UseHardwareAcceleration('On');
    set(0,'DefaultFigureMenu','none');
    iptsetpref('ImshowBorder','tight');
    hFig = figure('Color', zeros(1,3), 'Renderer', 'Painters');
    WindowAPI(hFig, 'topmost');
    WindowAPI(hFig, 'maximize');
    WindowAPI(hFig, 'Button', true);
    WindowAPI(hFig, 'Enable', 1);
    % axes('Visible', 'off', 'Units', 'normalized');
    
    l = [1,1,1,4.5,.5];
    for k = 1:numel(imfiles)
        times(k)= toc; image(imfiles{k}); axis off; pause(l(k));
    end
    t1 = times(4); t2 = times(5);
    %     for cd = 1:3                                                            % loop through countdown
    %         imdata = imread(cntdwn_files{cd});                                  % reads the image that will be displayed
    %         images_matlab(imdata, .8);
    %     end
    %
    %     %% Green cross
    %     imdata = imread(strcat(maindir, 'graphiken\green_cross.png'));                          % reads the image that will be displayed
    %     [~, t1] = images_matlab(imdata, ...
    %         epar.dur_tr(test_trial_order(test)));
    %     %% Red cross
    %     imdata = imread(strcat(maindir, 'graphiken\red_cross.png'));                          % reads the image that will be displayed
    %     [~, t2] = images_matlab(imdata, 1.0);
end
