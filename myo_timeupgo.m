function results = myo_timeupgo(maindir, nrep)


% % setenv('MW_MINGW64_LOC','C:\TDM-GCC-64')
% mex -setup:'C:\Program Files\MATLAB\R2016b\bin\win64\mexopts\mingw64.xml' C
% mex -setup:'C:\Program Files\MATLAB\R2016b\bin\win64\mexopts\mingw64.xml' C++

addpath(genpath(fullfile(maindir, 'skripte')))
%% functions needed to start compiling the Myo software and for the videos
myo_path = 'C:\onoff_svm\skripte\myo';                                      % the myo path is needed to read the MYO scripts

%%
sdk_path = 'C:/myo-sdk-win-0.9.0'; % root path to Myo SDK
install_myo_mex;                                                            % adds directories to MATLAB search path
try build_myo_mex sdk_path; catch; build_myo_mex(sdk_path); end            % builds myo_mex; Written this way ('try ... catch'), as if there is a problem, the routine ends itself and may be started again, therefore try-catch argument is included
countMyos   = 2;                                                            % number of MYO devices used for the experiment; more than one device is not advised as, it would not record the EMG
mm          = MyoMex(countMyos);
m1          = mm.myoData(1);                                                % continuos recordngs of MYO device is called m1 (saved later as results.mm)
m2          = mm.myoData(2);

% the next few lines can be used to check whether data has been recorded or
% not; This just plots the entire recordings "as it is"
% figure;
% subplot(4,1,1); plot(m1.timeIMU_log,m1.gyro_log);  title('gyro1');
% subplot(4,1,2); plot(m1.timeIMU_log,m1.accel_log); title('accel1');
% 
% subplot(4,1,3); plot(m2.timeIMU_log,m2.gyro_log);  title('gyro2');
% subplot(4,1,4); plot(m2.timeIMU_log,m2.accel_log); title('accel2');


%% Test the input and intialise the Psychtoolbox
if nargin~=2
    % the next few lines handle the input of the script, taht is the main directory
    maindir = 'C:\onoff_svm\';                                              % in case no main directory is provided, a standard directory is provided
    warning('WARNING! Input must be the "main directory" (maindir), at which subjects'' data will be stored;\n in this case no directory was provided, so data will be stored to %s', maindir)
    msg = '\nDo you want to proceed [y/n]?';
    nrep = 5;
    ytemp = input(msg, 's');
    while ~strcmp(ytemp, 'y') && ~strcmp(ytemp, 'n')
        fprintf('\nanswer MUST be ''y'' or ''n\n');
        ytemp = input(msg, 's');
    end
    
    if strcmp(ytemp, 'n')                                                   % if no is entered, the script is stopped and myo ends recording data
        m1.stopStreaming();
        m2.stopStreaming();

        mm.delete;
        clear mm m1 m2
        return
    end
end

%% General settings (are now saved in the file expSettings)
epar = expSettings(maindir);                                                % adding the maindir option, a pseudonym for the subject is added
filename_final = strcat(epar.session.folder_name, 'recording_tuag_', ...    % filename at which data will be stored at the end
    epar.session.cond, '_M', epar.session.msrmnt, '.mat');

%% Start Psychtoolbox with several different options
AssertOpenGL;
linewidth = 6;                                                              % linewidth for the green and red crosses
mvies = 1;                                                                  % option for switch in case movies can be played (1) or not (0)
% screens = Screen('Screens');                                              % number of screens available, may be interesting when >1 screen is available
olddebuglevel = Screen('Preference', 'VisualDebuglevel', 3);
Screen('Preference', 'SkipSyncTests', 2);
PsychDefaultSetup(1);
KbName('UnifyKeyNames');

try % start the Psychtoolbox experiment in  'try ... catch' expression, so that matlab crashes may be easier to debug
    scr = initialise();                                                     % initialise psychtoolbox, see function for details
    Screen('FillRect',scr.Ptr,scr.BGCLR);                                   % creates a "black screen"
    time_start_IMU1 = length(m1.timeIMU_log);                                % returns the start of the trial in the MYO recordings; needed twice, as EMG
    time_start_IMU2 = length(m2.timeIMU_log);                                % and otherrecordings are sampled at a different frequency (200 vs. 50Hz)
    
    %% Introduction for first recording in PD and for CTRL-subjects
    [~, time_start] = Screen('Flip',scr.Ptr);                               % returns the start of the trial, ,which is important for the events later
    
    marks = {'subject leaves chair', ...                                    % the conditions that will be recorded
        'subject turns around', 'subject sits again on chair'};
    
    tble_temp = cell(numel(epar.trial_order), 4);                           % pre-allocate space to fill later
    for t = 1:nrep % number of repetitions
        tble_temp{t,1} = epar.session.psdnm;                                % Name of the pseudonym
        tble_temp{t,2} = t;                                                 % trial no
        tble_temp{t,3} = epar.session.cond;                                 % condition, that is ON, OFF or CTRL
        tble_temp{t,4} = length(m1.timeIMU_log);
        tble_temp{t,5} = length(m2.timeIMU_log);
        tble_temp{t,6} = (GetSecs() - time_start);
        
        tble_temp{t,7} = time_start;                                        % this only serves to synchronize the recordings
        tble_temp{t,8} = str2double(epar.session.msrmnt);                   % measurement of the data, that is first or second
        
        for k = 1:numel(marks)
            text_display = sprintf('Please press the "P" button, when %s', marks{k});
            start_trial = draw_text(scr, 45, scr.FontName, ...    % "core paradigm" with a red cross, a green cross and a red cross again
                text_display, 'center', 'center', [255 255 255], ...
                'forever', time_start); %#ok<*NASGU>
            
            rpt = 0;
            while rpt == 0 % waits until P is pressed as indicated on the screen
                [~,~,keyCode] = KbCheck(-1);
                if keyCode(KbName('p')); break; end
                WaitSecs(.001);
            end
            KbReleaseWait (-1); Screen(scr.Ptr, 'Flip');
            tmps = draw_cross(scr, 60, linewidth, [0 0 0 ], ...
                0.2, time_start);
            tble_temp{t,k+8} = tmps - tble_temp{t,6};
            Screen(scr.Ptr, 'Flip');
        end
    end
    
    results.t = cell2table(tble_temp);
    results.t.Properties.VariableNames = {'subj', 'trial', 'condition', 'time_IMU1_start_trial', 'time_IMU2_start_trial', 'start_trial', 'start_exp', 'measurement', 'go', 'turn', 'sit'};
    results.m1 = m1;
    results.m2 = m2;
    results.mm = mm;
    
    %%
    results.IMU1start = time_start_IMU1;
    results.IMU2start = time_start_IMU2;
    results.epar = epar;
    
    save(filename_final, 'results', '-v7.3');                    % saves the merged EEG and acc data -to one file
    close all; sca; ShowCursor
    Screen('Preference', 'VisualDebuglevel', olddebuglevel);
    FlushEvents();
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
end