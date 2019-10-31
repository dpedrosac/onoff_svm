function results = myo_onoff(maindir)

% % setenv('MW_MINGW64_LOC','C:\TDM-GCC-64')
% mex -setup:'C:\Program Files\MATLAB\R2016b\bin\win64\mexopts\mingw64.xml' C
% mex -setup:'C:\Program Files\MATLAB\R2016b\bin\win64\mexopts\mingw64.xml' C++

addpath(genpath(fullfile(maindir, 'skripte')))
%% functions needed to start compiling the Myo software and for the videos
myo_path = 'C:\onoff_svm\skripte\myo';                                      % the myo path is needed to read the MYO scripts
WindowAPI;                                                                  % to plot the windows in the foreground, this is needed

%%
sdk_path = 'C:/myo-sdk-win-0.9.0'; % root path to Myo SDK
install_myo_mex;                                                            % adds directories to MATLAB search path
try build_myo_mex sdk_path; catch; build_myo_mex(sdk_path); end            % builds myo_mex; Written this way ('try ... catch'), as if there is a problem, the routine ends itself and may be started again, therefore try-catch argument is included
countMyos   = 1;                                                            % number of MYO devices used for the experiment; more than one device is not advised as, it would not record the EMG
mm          = MyoMex(countMyos);
m1          = mm.myoData(1);                                                % continuos recordngs of MYO device is called m1 (saved later as results.mm)

% the next few lines can be used to check whether data has been recorded or
% not; This just plots the entire recordings "as it is"
% figure;
% subplot(3,1,1); plot(m1.timeIMU_log,m1.gyro_log);  title('gyro');
% subplot(3,1,2); plot(m1.timeIMU_log,m1.accel_log); title('accel');
% subplot(3,1,3); plot(m1.timeEMG_log,m1.emg_log);   title('emg');

%% Test the input and intialise the Psychtoolbox
if nargin~=1                                                                % the next few lines handle the input of the script, taht is the main directory
    maindir = 'C:\onoff_svm\';                                              % in case no main directory is provided, a standard directory is provided
    warning('WARNING! Input must be the "main directory" (maindir), at which subjects'' data will be stored;\n in this case no directory was provided, so data will be stored to %s', maindir)
    msg = '\nDo you want to proceed [y/n]?';
    ytemp = input(msg, 's');
    while ~strcmp(ytemp, 'y') && ~strcmp(ytemp, 'n')
        fprintf('\nanswer MUST be ''y'' or ''n\n');
        ytemp = input(msg, 's');
    end
    
    if strcmp(ytemp, 'n')                                                   % if no is entered, the script is stopped and myo ends recording data
        m1.stopStreaming();
        mm.delete;
        clear mm m1
        return
    end
end

movie_names = {'posture_short.v1.4.mov', 'tapping_short.v1.4.mov', ...      % name of the (short) videos that intend to explain what subjects need to do
    'diadochokinesia_short.v1.4.mov', 'rest_short.v1.4.mov'};

%% General settings (are now saved in the file expSettings)
epar = expSettings(maindir);                                                % adding the maindir option, a pseudonym for the subject is added
filename_final = strcat(epar.session.folder_name, 'recording_total_', ...   % filename at which data will be stored at the end
    epar.session.cond, '_M', epar.session.msrmnt, '.mat');

%% Start Psychtoolbox with several different options
AssertOpenGL;
linewidth = 6;                                                              % linewidth for the green and red crosses
mvies = 0;                                                                  % option for switch in case movies can be played (1) or not (0)
% screens = Screen('Screens');                                              % number of screens available, may be interesting when >1 screen is available
olddebuglevel = Screen('Preference', 'VisualDebuglevel', 3);
Screen('Preference', 'SkipSyncTests', 2);
PsychDefaultSetup(1);
KbName('UnifyKeyNames');

try % start the Psychtoolbox experiment in  'try ... catch' expression, so that matlab crashes may be easier to debug
    scr = initialise();                                                     % initialise psychtoolbox, see function for details
    Screen('FillRect',scr.Ptr,scr.BGCLR);                                   % creates a "black screen"
    time_start_EMG = length(m1.timeEMG_log);                                % returns the start of the trial in the MYO recordings; needed twice, as EMG
    time_start_IMU = length(m1.timeIMU_log);                                % and otherrecordings are sampled at a different frequency (200 vs. 50Hz)
    
    %% Introduction for first recording in PD and for CTRL-subjects
    [~, time_start] = Screen('Flip',scr.Ptr);                               % returns the start of the trial, ,which is important for the events later
    
    if str2double(epar.session.msrmnt) == 1                                 % There are two parts of the introduction, first is only shown when PD-patients are tested for the first time
        % The first set of screens are intended to welcome the subject, give
        % instructions on the trials and start with the tests before the
        % experiments
        image_files = {strcat(maindir, 'graphiken\introduction1.png'), ...
            strcat(maindir, 'graphiken\introduction2.png'), ...
            strcat(maindir, 'graphiken\introduction3.png'), ...
            strcat(maindir, 'graphiken\introduction4.png')};                % name of the files for the different introduction screens
        
        for imgs_no = 1:numel(image_files) % loop through the different screens
            Screen('Flip', scr.Ptr);
            imdata = imread(image_files{imgs_no});                          % reads the image that will be displayed
            [ix,iy,~] = size(imdata);                                       % needed to resize image to size of screen
            imagetex = Screen('MakeTexture', scr.Ptr, imdata);              % this line sets up the texture and "rects"
            Screen('DrawTexture', scr.Ptr, imagetex, [0 0 iy ix], ...       % draws the image into workspace and plots it on the screen
                [5, 0, scr.Width, scr.Height]); Screen(scr.Ptr, 'Flip');
            rpt = 0;                                                        % rpt is needed to decide whether more repetitions of the test trials are needed (1) or not (0); set to zero at beginning
            
            %   in this case, the code stops until the participant presses
            %   the "r" button
            if imgs_no <3 % all images except for third one (see 'introduction3.png', for details)
                while rpt == 0 % waits until R is pressed as indicated on the screen
                    [~,~,keyCode] = KbCheck(-1);
                    if (keyCode(KbName('r')) && imgs_no == 1); break; end
                    WaitSecs(.001);
                    
                    if (keyCode(KbName('r')) && imgs_no == 2)
                        Screen(scr.Ptr, 'Flip');
                        if mvies == 1
                            mviname = strcat(maindir, 'videos\allconds.v1.7.mov');
                            video_display(scr, mviname, time_start); rpt = 1;
                            break;
                        else
                            videos_matlab(strcat(maindir, 'videos\allconds.v1.8.mov'))
                            rpt = 1;
                        end
                        WaitSecs(.001);
                    end
                end
                KbReleaseWait(-1); Screen(scr.Ptr, 'Flip');
                
                %   in this case, only a screen is displayed advising that code
                %   will continue soon; then test trials are displayed
            elseif imgs_no == 3 % if 'introduction3.png' is shown, there is no button to press but just wait some seconds
                WaitSecs(6); % wait for 6 seconds in order to proceed
                test_trial_order = random_generator(0, epar.ntasks, ...
                    epar.dur_tr(2), epar.dur_tr(end), 2, 1, 1);             % create a random order of test-trials
                
                for test = 1:numel(test_trial_order) % loop through random order of test trials
                    if mvies == 1
                        mviname = strcat(maindir, 'videos\', ...            % name of the movie in this condition
                            movie_names{test_trial_order(test)});
                        video_display(scr, mviname, time_start);
                    else
                        mviname = strcat(maindir, 'videos\', ...            % name of the movie in this condition
                            movie_names{test_trial_order(test)});
                        videos_matlab(mviname)
                        rpt = 1;
                        
                        %                         text_display = sprintf('%s video (TEST)', ...
                        %                             epar.tasks{test_trial_order(test)});
                        %                         test_time = draw_text(scr, 45, scr.FontName, ...    % "core paradigm" with a red cross, a green cross and a red cross again
                        %                             text_display, 'center', 'center', [255 255 255], ...
                        %                             1.5, time_start); %#ok<*NASGU>
                    end
                    
                    Screen('Flip', scr.Ptr);
                    draw_text(scr, 60, scr.FontName, ...                countdown ... 3 ...
                        '3', 'center', 'center', [255 255 255], ...
                        1, time_start); %#ok<*NASGU>
                    draw_text(scr, 60, scr.FontName, ...                countdown ... 2 ...
                        '2', 'center', 'center', [255 255 255], ...
                        1, time_start); %#ok<*NASGU>
                    draw_text(scr, 60, scr.FontName, ...    % "core paradigm" with a red cross, a green cross and a red cross again
                        '1', 'center', 'center', [255 255 255], ...
                        1, time_start); %#ok<*NASGU>
                    
                    %                     test_time = draw_cross(scr, 60, linewidth, [255 0 0], ...
                    %                         epar.fx_rand(epar.r_int), time_start);
                    test_time = draw_cross(scr, 60, linewidth, [0 255 0 ], ...
                        epar.dur_tr(test_trial_order(test)),time_start);
                    test_time = draw_cross(scr, 60, linewidth, [255 0 0], ...
                        1.0, time_start); Screen(scr.Ptr, 'Flip');
                end
            end
            
            % introduction4.png is displayed after the test trials and
            % provides the option of further tests or start the recordings
            if imgs_no == 4 % special case of introduction4.png
                while (1) % waits until "r" or "q" is pressed as indicated on the screen
                    [~,~,keyCode] = KbCheck(-1);
                    if keyCode(KbName('r'))
                        rpt = 0;
                        break;
                    end
                    
                    if keyCode(KbName('q'))
                        rpt = 1;
                        break;
                    end
                    WaitSecs(.001);
                end
                KbReleaseWait(-1); Screen(scr.Ptr, 'Flip'); %plot on screen
                
                while rpt >0 % if rpt = 1, do another set of repetitions of the test trials (n = 4)
                    test_trial_order = randperm(4);
                    Screen(scr.Ptr, 'Flip'); %plot on screen
                    for test = 1:numel(test_trial_order) % loop through random order of test trials
                        if mvies == 1
                            mviname = strcat(maindir, 'videos\', movie_names{test_trial_order(test)});
                            video_display(scr, mviname, time_start);
                        else
                            mviname = strcat(maindir, 'videos\', movie_names{test_trial_order(test)});
                            videos_matlab(mviname);
                            %                             text_display = sprintf('%s video (TEST)', ...
                            %                                 epar.tasks{test_trial_order(test)});                %% SHOULD BE REPLACED WITH VIDEO!!
                            %                             test_time = draw_text(scr, 45, scr.FontName, ...        % "core paradigm" with a red cross, a green cross and a red cross again
                            %                                 text_display, 'center', 'center', [255 255 255], ...
                            %                                 1.5, time_start);
                        end
                        draw_text(scr, 60, scr.FontName, ...                countdown ... 3 ...
                            '3', 'center', 'center', [255 255 255], ...
                            1, time_start); %#ok<*NASGU>
                        draw_text(scr, 60, scr.FontName, ...                countdown ... 2 ...
                            '2', 'center', 'center', [255 255 255], ...
                            1, time_start); %#ok<*NASGU>
                        draw_text(scr, 60, scr.FontName, ...    % "core paradigm" with a red cross, a green cross and a red cross again
                            '1', 'center', 'center', [255 255 255], ...
                            1, time_start); %#ok<*NASGU>
                        
                        
                        %                         test_time = draw_cross(scr, 60, linewidth, [255 0 0], ...
                        %                             epar.fx_rand(epar.r_int), time_start);
                        test_time = draw_cross(scr, 60, linewidth, [0 255 0 ], ...
                            epar.dur_tr(test_trial_order(test)),time_start);
                        test_time = draw_cross(scr, 60, linewidth, [255 0 0], ...
                            1.5, time_start); Screen(scr.Ptr, 'Flip');
                    end
                    
                    imdata = imread(image_files{imgs_no});                  % reads the image that will be displayed
                    [ix,iy,~] = size(imdata);                               % needed to resize image to size of screen
                    imagetex = Screen('MakeTexture', scr.Ptr, imdata);      % this line sets up the texture and "rects"
                    Screen('DrawTexture', scr.Ptr, imagetex, [0 0 iy ix], ...           % draws the image into workspace and plots it on the screen
                        [5, 0, scr.Width, scr.Height]);
                    Screen(scr.Ptr, 'Flip');
                    
                    while (1) % waits until R is pressed as indicated on the screen
                        [~,~,keyCode] = KbCheck(-1);
                        if keyCode(KbName('r'))
                            rpt = 0; break;
                        end
                        if keyCode(KbName('q'))
                            rpt = 1; break;
                        end
                        WaitSecs(.001);
                    end
                    KbReleaseWait(-1);
                    Screen(scr.Ptr, 'Flip'); %plot on screen
                    
                    if rpt == 0, break, end                                 % if "r" is pressed, start the real testing
                end
                Screen(scr.Ptr, 'Flip'); %plot on screen
            end
        end
        
        %% Introduction for second recording in PD; n.a. for CTRL-subjects
    else % in case this is the second recording in the PD-patients, the welcome and instructions screen must not be shown again, instead a short welcome screen is displayed
        % Start displaying the instructions
        imdata = imread(strcat(maindir, 'graphiken\introduction5.png'));    % reads the image that will be displayed
        [ix,iy,~] = size(imdata);                                           % needed to resize image to size of screen
        imagetex = Screen('MakeTexture', scr.Ptr, imdata);                  % this line sets up the texture and "rects"
        Screen(scr.Ptr, 'Flip'); %plot on screen
        Screen('DrawTexture', scr.Ptr, imagetex, [0 0 iy ix], ...           % draws the image into workspace and plots it on the screen
            [5, 0, scr.Width, scr.Height]); Screen(scr.Ptr, 'Flip');
        
        while (1) % waits until "r" is pressed as indicated on the screen
            [~,~,keyCode] = KbCheck(-1);
            if keyCode(KbName('r')); break; end
            WaitSecs(.001);
        end
        KbReleaseWait (-1); Screen(scr.Ptr, 'Flip'); %plot on screen
    end
    Screen('FillRect',scr.Ptr,scr.BGCLR); WaitSecs(5);                      % creates a "black screen" and waits a few seconds until the real recordings are started
    
    %% Start the "real" testing which will be logged, using a table called
    % tble_temp (later converted to results.t)
    
    tble_temp = cell(numel(epar.trial_order), 15);                                      % pre-allocate space to fill later
    blksize = 4;                                                            % blocks are used to save data not only at the end but before, to ensure no data is lost
    blcks = ceil([1:(blksize*numel(epar.trial_order)/blksize)]./ ...
        blksize);                                               %#ok<NBRAK> % somehow bulky piece of code intended to provide different blocks and assign the trial to a block
    
    %%
    for i = 1:numel(epar.trial_order) % loop through all trials
        tble_temp{i,1} = epar.session.psdnm;                                % Name of the pseudonym
        tble_temp{i,2} = i;                                                 % trial no
        tble_temp{i,3} = epar.tasks{epar.trial_order(i)};                   % task, that is either 'hold', 'tapping', 'diadochokinesia' or 'rest'
        tble_temp{i,4} = blcks(i);                                          % block number
        tble_temp{i,5} = epar.session.cond;                                 % condition, that is ON, OFF or CTRL
        
        % check for keyboard press
        [~,~,keyCode] = KbCheck(-1);
        if keyCode(KbName('space')); break; end
        if mvies == 1
            mviname = strcat(maindir, 'videos\', movie_names{epar.trial_order(i)});
            tble_temp{i,6} = video_display(scr, mviname, time_start);
        else
            mviname = strcat(maindir, 'videos\', movie_names{epar.trial_order(i)});
            tble_temp{i,6} = GetSecs();
            videos_matlab(mviname)
            %             text_display = sprintf('%s video ', epar.tasks{epar.trial_order(i)});
            %             tble_temp{i,6} = draw_text(scr, 45, scr.FontName, text_display, 'center', 'center', [255 255 255], 1.5, time_start);
        end
        
        %%
        tble_temp{i,7} = length(m1.timeEMG_log);
        tble_temp{i,8} = length(m1.timeIMU_log);
        
        %%
        tble_temp{i,7} = 1;
        tble_temp{i,8} = 1;
        tble_temp{i,9} = (GetSecs() - time_start);
        draw_text(scr, 60, scr.FontName, ...                countdown ... 3 ...
            '3', 'center', 'center', [255 255 255], ...
            1, time_start); %#ok<*NASGU>
        draw_text(scr, 60, scr.FontName, ...                countdown ... 2 ...
            '2', 'center', 'center', [255 255 255], ...
            1, time_start); %#ok<*NASGU>
        draw_text(scr, 60, scr.FontName, ...    % "core paradigm" with a red cross, a green cross and a red cross again
            '1', 'center', 'center', [255 255 255], ...
            1, time_start); %#ok<*NASGU>
        
        %         tble_temp{i,9} = draw_cross(scr, 60, linewidth, [255 0 0], epar.fx_rand(epar.r_int), time_start);
        tble_temp{i,10} = draw_cross(scr, 60, linewidth, [0 255 0 ], epar.dur_tr(epar.trial_order(i)),time_start);
        tble_temp{i,11} = draw_cross(scr, 60, linewidth, [255 0 0], 1.5, time_start);
        tble_temp{i,12} = (GetSecs() - [tble_temp{i,6} + time_start]); %#ok<NBRAK>
        
        tble_temp{i,13} = time_start;                                       % this only serves to synchronize the recordings
        tble_temp{i,14} = 0;                                                % here a second display is needed in which the person in charge of the experiment could add problems and in which a while loop causes that there is no repetition, or similar
        tble_temp{i,15} = str2double(epar.session.msrmnt);                  % measurement of the data, that is first or second
        filename_temp = ...
            strcat(epar.session.folder_name, 'recording_block_', ...
            num2str(blcks(i)) ,'_', epar.session.cond, '_M', ...
            epar.session.msrmnt, '.mat');
        
        save(filename_temp, 'tble_temp', 'm1', 'epar', 'time_start_EMG', 'time_start_IMU', '-v7.3');                    % saves the merged EEG and acc data -to one file
    end
    
    results.t = cell2table(tble_temp);
    results.t.Properties.VariableNames = {'subj', 'trial', 'task', 'block', 'condition', 'start_trial', 'time_emg_start_trial', 'time_myo_start_trial', 'time_rc1', 'time_gc1', 'time_rc2', 'trial_duration', 'start_time', 'problem', 'measurement'};
    
    %%
    results.m1 = 3;
    results.mm = 4;
    results.IMUstart = 5;
    results.EMGstart = 6;
    results.m1 = m1;
    results.mm = mm;
    
    %%
    results.IMUstart = time_start_IMU;
    results.EMGstart = time_start_EMG;
    results.epar = epar;
    
    save(filename_final, 'results', '-v7.3');                    % saves the merged EEG and acc data -to one file
    close all; sca; ShowCursor
    Screen('Preference', 'VisualDebuglevel', olddebuglevel);
    FlushEvents();
    set(0,'DefaultFigureMenu','figure');
    %     psychrethrow(psychlasterror);
catch
    % This section is executed only in case an error happens in the
    % experiment code implemented between try and catch...
    results = [];
    ShowCursor;
    sca; %or sca
    ListenChar(0);
    FlushEvents();
    Screen('Preference', 'VisualDebuglevel', olddebuglevel);
    set(0,'DefaultFigureMenu','figure');
end