function data_read_pd(wdir, patdat)

%   This function extracts the raw data and saves it as mat-file in order
%   to proceed with analyses without the need to put on the wearable
%   device. Only PD recordings are saved, for Time up and Go test see
%   data_read_tug.m

%   Copyright (C) December 2018, modified May 2019
%   David Pedrosa, Max Wullstein, Urs Kleinholdermann, University Hospital of Gieﬂen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

%% Preliminary scripts to run and variables in order to get script running
if ~exist('patdat'); patdat= pat_list(wdir, 0); end            %#ok<*EXIST> % loads data without output of not already in workspace
foldername = strcat(wdir, 'analyses\raw_data\');                            % name of the folder to be created
if ~exist(foldername)                                                       % the next lines create the folder in case not available already
    mkdir(foldername);
end

%% In order to get data, Myo MUST be loaded into workspace

addpath(genpath(fullfile(wdir, 'skripte')))
% myo_path = 'C:\Users\David\Jottacloud\onoff_svm\myo';                     % the myo path is needed to read the MYO scripts
sdk_path = 'C:\myo-sdk-win-0.9.0'; % root path to Myo SDK
install_myo_mex;                                                            % adds directories to MATLAB search path
try build_myo_mex sdk_path; catch; build_myo_mex(sdk_path); end             % builds myo_mex; Written this way ('try ... catch'), as if there is a problem, the routine ends itself and may be started again, therefore try-catch argument is included
countMyos   = 1;                                                            % number of MYO devices used for the experiment; more than one device is not advised as, it would not record the EMG
mm          = MyoMex(countMyos);
m1          = mm.myoData(1);                                                % continuos recordngs of MYO device is called m1 (saved later as results.mm)

%% Read data from Myo-class
for k = 1:size(patdat,1) % loop through all available subjects
    clear epar resample                                                     % to avoid redundancy, values are cleared so that they may be defined later
    psdnym = patdat.pseud(k);                                               % load the pseudonym for recordings
    dirs = dir(fullfile(strcat(wdir, 'recordings\', char(psdnym), '*')));   % check for directories resulting from this subject
    fprintf('\n....... processing %s, .......\n', psdnym)
    switch grp2idx(patdat.group(k))                                         % necessary switch to ensure that both groups may be read out
        case (1)
            conds = {'OFF', 'ON'};
        case (2)
            conds = {'CTRL'};                                               % different recorded conditions for PD-patients
    end
    
    if numel(dirs) == 0                                                     % if no data was recorded for the subject, an error is produced and the for-loop continues
        fprintf('\nno data available for subject %s, skipping subject\n', psdnym)
        continue
    end

    s = {}; iter = 0;                                                       % pre-allocates space to be filled later; iter is 0 and makes the adding of data possible
    savename = ...
        strcat(foldername, 'data', char(psdnym),'.mat');                    % filename that will be saved later
    
    if exist(savename, 'file')                                              % skipping data extraction if already present
        fprintf('\nskipping %s, as data already present', psdnym)
        continue
    else
        for c = 1:2%numel(conds) % loop through different conditions, i.e. 'OFF and ON' or only 'CTRL'
            %if c == 1; s_opt = 2; else; s_opt = 1; end hacl for 69... as
            %there were only three recordings available.
            for sess = 1:s_opt % loop though different sessions; for stability reasons ad to avoid data losses, two sessions were needed during data recording
                iter = iter + 1;
                %% define the filenames and names of folders in order to obtain data
                recname = strcat(psdnym, '_', conds{c}, '_', num2str(iter)); % name of the raw data file under "normal conditions"; this is chedked in the newt few lines and may be chaged manually
                
                err = 0;                                                    % (err) is needed whenever only one session was used
                while ~exist(fullfile(wdir, 'recordings', char(recname)), 'dir')
                    fprintf('filename for %s for condition %s is apparently inexistent please provide the correct name\n', psdnym, conds{c})
                    prompt = 'What is the correct foldername (type ''n/a'' if not available)?\n';
                    recname = input(prompt);
                    if strcmp(recname, 'n/a'); err = 1; break; end          % skips this while loop and continues in the script
                end
                
                if err == 0                                                 % (err = 0) indicates that no problem was present
                    [openname, idx] = ...
                        list_recordings(wdir, recname,  conds{c}, iter, 0); % if folder available, this checks for the name of the dataset in the folder
                else
                    break                                                   % in cases where no data is available for a condition, the script stops at this point
                end
                
                %% Start loading data by first defining required information
                try
                    res = ...
                        load(fullfile(wdir, 'recordings\', char(recname), openname)); % loads data into temporary file
                catch
                    openname = ...
                        list_recordings(wdir, recname, conds{c}, iter, 1, idx-1);     % whenever first attempt fails, it means that data saved before should be used, which is facilitated here
                    try
                        res = load(fullfile(wdir, 'recordings\', char(recname), openname)); % loads data into temporary file
                    catch
                        fprintf('filename still not found, please provide the name (subj: %s, cond:%s\n', psdnym, conds{c})
                        prompt = 'What is the correct filename(e.g., ''recording_block_9_OFF_M1.mat'')?\n';
                        openname = input(prompt);
                        res = load(fullfile(wdir, 'recordings\', char(recname), openname)); % loads data into temporary file
                    end
                end
                
                %% copy data from recordings
                if contains (openname, 'block' )                            % introduce data into structure and save as file
                    res_temp = res;
                else
                    res_temp = res.results;
                    res_temp.tble_temp = table2cell(res_temp.t);
                    res_temp.time_start_IMU = res_temp.IMUstart;
                    res_temp.time_start_EMG = res_temp.EMGstart;
                end
                
                s{iter}.accel   = res_temp.m1.accel_log; %#ok<*AGROW>       % accelerometer data as N X 3 data matrix
                s{iter}.emg     = res_temp.m1.emg_log;                      % EMG data as N x 8 (?) data matrix
                s{iter}.gyro    = res_temp.m1.gyro_log;                     % gyroscope data as N x 3 data matrix
                s{iter}.timeIMU = res_temp.m1.timeIMU_log;                  % time stamp for IMU recordings
                s{iter}.timeEMG = res_temp.m1.timeEMG_log;                  % time stamp for EMG recordings
                s{iter}.tble    = res_temp.tble_temp;                       % results table
                s{iter}.IMUstart= res_temp.time_start_IMU;                  % index of time at which IMU recording was started (?)
                s{iter}.EMGstart= res_temp.time_start_EMG;                  % index of time at which EMG recording was started (?)
                s{iter}.psdnym  = psdnym;                                   % pseudonym
                s{iter}.epar    = res_temp.epar;
                s{iter}.rateIMU = res_temp.m1.rateIMU;
                s{iter}.rateEMG = res_temp.m1.rateEMG;
                clear res_temp res
            end
            save(savename, 's', '-v7.3');
        end
    end
end
mm.delete; m1.delete; clear mm m1