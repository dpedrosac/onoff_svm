function results = myo_onoff_noPTB(maindir)

% % setenv('MW_MINGW64_LOC','C:\TDM-GCC-64')
% mex -setup:'C:\Program Files\MATLAB\R2016b\bin\win64\mexopts\mingw64.xml' C
% mex -setup:'C:\Program Files\MATLAB\R2016b\bin\win64\mexopts\mingw64.xml' C++

addpath(genpath(fullfile(maindir, 'skripte')))
%% functions needed to start compiling the Myo software and for the videos
myo_path = 'C:\onoff_svm\myo';                       % the myo path is needed to read the MYO scripts
WindowAPI;                                                                  % to plot the windows in the foreground, this is needed

%%
sdk_path = 'C:/myo-sdk-win-0.9.0'; % root path to Myo SDK
install_myo_mex;                                                            % adds directories to MATLAB search path
try build_myo_mex sdk_path; catch; build_myo_mex(sdk_path); end            % builds myo_mex; Written this way ('try ... catch'), as if there is a problem, the routine ends itself and may be started again, therefore try-catch argument is included
countMyos   = 1;                                                            % number of MYO devices used for the experiment; more than one device is not advised as, it would not record the EMG
mm          = MyoMex(countMyos);
m1          = mm.myoData(1);                                                % continuos recordngs of MYO device is called m1 (saved later as results.mm)
% mm = {}; m1 = {}; m1.timeEMG_log = ones(1,2); m1.timeIMU_log = ones(1,2);

% the next few lines can be used to check whether data has been recorded or
% not; This just plots the entire recordings "as it is"
% figure;
% subplot(3,1,1); plot(m1.timeIMU_log,m1.gyro_log);  title('gyro');
% subplot(3,1,2); plot(m1.timeIMU_log,m1.accel_log); title('accel');
% subplot(3,1,3); plot(m1.timeEMG_log,m1.emg_log);   title('emg');

%% Test the input
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

%% Start the recordings
time_start_EMG = length(m1.timeEMG_log);                                    % returns the start of the trial in the MYO recordings; needed twice, as EMG
time_start_IMU = length(m1.timeIMU_log);                                    % and otherrecordings are sampled at a different frequency (200 vs. 50Hz)

%% Introduction for first recording in PD and for CTRL-subjects
tic;                                                                   % starts measuring the time of the recording
if str2double(epar.session.msrmnt) == 1                                     % There are two parts of the introduction, first is only shown when PD-patients are tested for the first time
    % The first set of screens are intended to welcome the subject, give
    % instructions on the trials and start with the tests before the
    % experiments
    image_files = {strcat(maindir, 'graphiken\introduction1.png'), ...
        strcat(maindir, 'graphiken\introduction2.png'), ...
        strcat(maindir, 'graphiken\introduction3.png'), ...
        strcat(maindir, 'graphiken\introduction4.png')};                    % name of the files for the different introduction screens
    
    cntdwn_files = {strcat(maindir, 'graphiken\3.png'), ...
        strcat(maindir, 'graphiken\2.png'), ...
        strcat(maindir, 'graphiken\1.png'), ...
        strcat(maindir, 'graphiken\green_cross.png'), ...
        strcat(maindir, 'graphiken\red_cross.png')};                                % name of the files for the countdown for the conditions
    for cd = 1:numel(cntdwn_files); imfiles{cd} = imread(cntdwn_files{cd}); end

%     matlab.video.read.UseHardwareAcceleration('On');
    set(0,'DefaultFigureMenu','none');
    iptsetpref('ImshowBorder','tight');
    bFig = figure('Color', zeros(1,3), 'Renderer', 'Painters');
    WindowAPI(bFig, 'topmost');
    WindowAPI(bFig, 'maximize');
    WindowAPI(bFig, 'Button', true);
    WindowAPI(bFig, 'Enable', 1);
    image(imread(strcat(maindir, 'graphiken\black.png'))); axis off;
    
    % Loop through the different introduction screens for first trial
    for imgs_no = 1:numel(image_files) % loop through the different screens
        imdata = imread(image_files{imgs_no});                              % reads the image that will be displayed
        nrep = 1;
        while nrep ~= 0
            if imgs_no == 1
                [r,~,~] = images_matlab(imdata); nrep = 0;                    % displays the image loaded before until a button is pressed
            elseif imgs_no == 2
                [r,~,~] = images_matlab(imdata); nrep = 0;                    % displays the image loaded before until a button is pressed
                videos_matlab(strcat(maindir, 'videos\allconds.v1.8.mov'))
            elseif imgs_no == 3
                [r,~,~] = images_matlab(imdata,6); nrep = 0;                  % wait for 6 seconds in order to proceed
                test_trial_order = random_generator(0, epar.ntasks, ...
                    epar.dur_tr(2), epar.dur_tr(end), 2, 1, 1);             % create a random order of test-trials
                test_sequence(maindir, test_trial_order, movie_names, imfiles)
            elseif imgs_no == 4
                [r,~,~] = images_matlab(imdata);                              % displays the image loaded before until a button is pressed
                if strcmp(r, 'q')
                    test_trial_order = random_generator(0, epar.ntasks, ...
                        epar.dur_tr(2), epar.dur_tr(end), 1, 1, 1);             % create a random order of test-trials
                    test_sequence(maindir, test_trial_order, movie_names, cntdwn_files, epar)
                else
                    nrep = 0;
                end         % in order to repeat the testing if q os pressed, this line is introduced
            end
        end
    end
    
    %% Introduction for second recording in PD; n.a. for CTRL-subjects
else % in case this is the second recording in the PD-patients, the welcome and instructions screen must not be shown again, instead a short welcome screen is displayed
    % Start displaying the instructions
    
%     matlab.video.read.UseHardwareAcceleration('On');
    set(0,'DefaultFigureMenu','none');
    iptsetpref('ImshowBorder','tight');
    bFig = figure('Color', zeros(1,3), 'Renderer', 'Painters');
    WindowAPI(bFig, 'topmost');
    WindowAPI(bFig, 'maximize');
    WindowAPI(bFig, 'Button', true);
    WindowAPI(bFig, 'Enable', 1);
    % axes('Visible', 'off', 'Units', 'normalized');
    image(imread(strcat(maindir, 'graphiken\black.png'))); axis off;
    
    imdata = imread(strcat(maindir, 'graphiken\introduction5.png'));            % reads the image that will be displayed
    [r,~,~] = images_matlab(imdata);
end
close(bFig);
%% Start the "real" testing which will be logged, using a table called
% tble_temp (later converted to results.t)

% matlab.video.read.UseHardwareAcceleration('On');
set(0,'DefaultFigureMenu','none');
iptsetpref('ImshowBorder','tight');
bFig = figure('Color', zeros(1,3), 'Renderer', 'Painters');
WindowAPI(bFig, 'topmost');
WindowAPI(bFig, 'maximize');
WindowAPI(bFig, 'Button', true);
WindowAPI(bFig, 'Enable', 1);
% axes('Visible', 'off', 'Units', 'normalized');
image(imread(strcat(maindir, 'graphiken\black.png'))); axis off;

tble_temp = cell(numel(epar.trial_order), 15);                              % pre-allocate space to fill later
blksize = 4;                                                                % blocks are used to save data not only at the end but before, to ensure no data is lost
blcks = ceil([1:(blksize*numel(epar.trial_order)/blksize)]./ ...
    blksize);                                                   %#ok<NBRAK> % somehow bulky piece of code intended to provide different blocks and assign the trial to a block

%%
for i = 1:numel(epar.trial_order) % loop through all trials
    tble_temp{i,1} = epar.session.psdnm;                                % Name of the pseudonym
    tble_temp{i,2} = i;                                                 % trial no
    tble_temp{i,3} = epar.tasks{epar.trial_order(i)};                   % task, that is either 'hold', 'tapping', 'diadochokinesia' or 'rest'
    tble_temp{i,4} = blcks(i);                                          % block number
    tble_temp{i,5} = epar.session.cond;                                 % condition, that is ON, OFF or CTRL
    
    mviname = strcat(maindir, 'videos\', movie_names{epar.trial_order(i)});
    tble_temp{i,6} = toc;
    videos_matlab(mviname);
    tble_temp{i,7} = length(m1.timeEMG_log);
    tble_temp{i,8} = length(m1.timeIMU_log);
    
    %%
    %     tble_temp{i,7} = 1;
    %     tble_temp{i,8} = 1;
    tble_temp{i,9} = toc;
    ts = seq_matlab(imfiles, epar.dur_tr(epar.trial_order(i)));
    tble_temp{i,10} = ts(4);
    tble_temp{i,11} = ts(5);
    
%     %% Green cross
%     imdata = imread(strcat(maindir, 'graphiken\green_cross.png'));                          % reads the image that will be displayed
%     [~, tble_temp{i,10}] = images_matlab(imdata, ...
%         epar.dur_tr(epar.trial_order(i)));
%     %% Red cross
%     imdata = imread(strcat(maindir, 'graphiken\red_cross.png'));                          % reads the image that will be displayed
%     [~, tble_temp{i,11}] = images_matlab(imdata, .5);
    
    
    tble_temp{i,12} = (toc - tble_temp{i,6});                               % duration of the trial in secs
    tble_temp{i,13} = 1;%%tic??;                                            % this only serves to synchronize the recordings
    tble_temp{i,14} = 0;                                                    % here a second display is needed in which the person in charge of the experiment could add problems and in which a while loop causes that there is no repetition, or similar
    tble_temp{i,15} = str2double(epar.session.msrmnt);                      % measurement of the data, that is first or second
    filename_temp = ...
        strcat(epar.session.folder_name, 'recording_block_', ...
        num2str(blcks(i)) ,'_', epar.session.cond, '_M', ...
        epar.session.msrmnt, '.mat');
    
    save(filename_temp, 'tble_temp', 'm1', 'epar', 'time_start_EMG', 'time_start_IMU', '-v7.3');                    % saves the merged EEG and acc data -to one file
    results.t = cell2table(tble_temp);
    results.t.Properties.VariableNames = {'subj', 'trial', 'task', 'block', 'condition', 'start_trial', 'time_emg_start_trial', 'time_myo_start_trial', 'time_rc1', 'time_gc1', 'time_rc2', 'trial_duration', 'start_time', 'problem', 'measurement'};
end
%%
results.m1 = m1;
results.mm = mm;
results.IMUstart = time_start_IMU;
results.EMGstart = time_start_EMG;
results.epar = epar;

save(filename_final, 'results', '-v7.3');                    % saves the merged EEG and acc data -to one file
close all; sca; ShowCursor
end