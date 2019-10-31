function results = myo_timeupgo_noPSB(maindir, nrep)


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
% 

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

%% Start the recordings
time_start_IMU1 = length(m1.timeIMU_log);                                % returns the start of the trial in the MYO recordings; needed twice, as EMG
time_start_IMU2 = length(m2.timeIMU_log);                                % and otherrecordings are sampled at a different frequency (200 vs. 50Hz)

%% Introduction for first recording in PD and for CTRL-subjects
tic;
marks = {'subject leaves chair', ...                                    % the conditions that will be recorded
    'subject turns around', 'subject sits again on chair'};
image_files = {strcat(maindir, 'graphiken\leaves_chair.png'), ...
        strcat(maindir, 'graphiken\turns_around.png'), ...
        strcat(maindir, 'graphiken\sits_down_again.png')};                    % name of the files for the different introduction screens


matlab.video.read.UseHardwareAcceleration('On');
set(0,'DefaultFigureMenu','none');
iptsetpref('ImshowBorder','tight');
bFig = figure('Color', zeros(1,3), 'Renderer', 'Painters');
WindowAPI(bFig, 'topmost');
WindowAPI(bFig, 'maximize');
WindowAPI(bFig, 'Button', true);
WindowAPI(bFig, 'Enable', 1);
image(imread(strcat(maindir, 'graphiken\black.png'))); axis off;

tble_temp = cell(numel(epar.trial_order), 4);                           % pre-allocate space to fill later
for t = 1:nrep % number of repetitions
    tble_temp{t,1} = epar.session.psdnm;                                % Name of the pseudonym
    tble_temp{t,2} = t;                                                 % trial no
    tble_temp{t,3} = epar.session.cond;                                 % condition, that is ON, OFF or CTRL
    tble_temp{t,4} = length(m1.timeIMU_log);
    tble_temp{t,5} = length(m2.timeIMU_log);
    tble_temp{t,6} = toc;
    
    tble_temp{t,7} = 1;% tic;                                        % this only serves to synchronize the recordings
    tble_temp{t,8} = str2double(epar.session.msrmnt);                   % measurement of the data, that is first or second
    
    for k = 1:numel(marks)
        imdata = imread(image_files{k});                              % reads the image that will be displayed
        [~,~,tpress] = images_matlab(imdata); % displays the image loaded before until a button is pressed
        tble_temp{t,k+8} = tpress;
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
