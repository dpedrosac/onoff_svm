function data_read_tug(wdir, patdat)

%   This function extracts the raw data of the Time up and Go test (TUG)
%   and saves it as mat-fiel in order to proceed with analyses wuthout the need to put on the wearable
%   device.

%   Copyright (C) December 2018
%   Max Wullstein, University Hospital of Gieﬂen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

%% An dieser Stelle if statement falls Daten noch nicht vorhanden
if ~exist('patdat'); patdat= pat_list(wdir, 0); end                    %#ok<*EXIST> % loads data without output of not already in workspace
foldername = strcat(wdir, 'analyses\raw_data\');                                     % name of the folder to be created
if ~exist(foldername)                                                       % the next lines create the folder in case not available already
    mkdir(foldername);
end

%% In order to get data, Myo MUST be loaded into workspace

addpath(genpath(fullfile(wdir, 'skripte')))
% myo_path = 'C:\Users\David\Jottacloud\onoff_svm\myo';                       % the myo path is needed to read the MYO scripts
sdk_path = 'C:\myo-sdk-win-0.9.0'; % root path to Myo SDK
install_myo_mex;                                                            % adds directories to MATLAB search path
try build_myo_mex sdk_path; catch; build_myo_mex(sdk_path); end             % builds myo_mex; Written this way ('try ... catch'), as if there is a problem, the routine ends itself and may be started again, therefore try-catch argument is included
countMyos   = 1;                                                            % number of MYO devices used for the experiment; more than one device is not advised as, it would not record the EMG
mm          = MyoMex(countMyos);
m1          = mm.myoData(1);                                    %#ok<NASGU> % continuos recordngs of MYO device is called m1 (saved later as results.mm)

%% Dateien auslesen aus Myo-Daten
for k = 1:size(patdat,1) % loop through all available subjects
    clear epar res
    psdnym = patdat.pseud(k);                                               % load the pseudonym for recordings
    dirs = dir(fullfile(strcat(wdir, 'recordings\', char(psdnym), '*')));   % check for directories resulting from this subject
    fprintf('\n....... processing %s, .......\n', psdnym)
    switch grp2idx(patdat.group(k))                                         % necessary switch to ensure that both groups may be read out
        case (1)
            conds = {'OFF', 'ON'};
        case (2)
            conds = {'CTRL'};                                          % different recorded conditions for PD-patients
    end
    
    if numel(dirs) == 0                                                     % if no data was recorded for the subject, an error is produced and the for-loop continues
        fprintf('\nno data available for subject %s, skipping subject\n', psdnym)
        continue
    end
    
    s = {}; iter = 0;                                                       % pre-allocates space to be filled later; iter is 0 and makes the adding of data possible
    savename = ...
        strcat(foldername, 'tug', char(psdnym),'.mat');                    % filename that will be saved later
    
    if exist(savename, 'file')                                              % skipping data extraction if already present
        fprintf('\nskipping %s, as data already present', psdnym)
        continue
    else
        for c = 1:numel(conds) % loop through different conditions, i.e. 'OFF and ON' or only 'CTRL'
            iter = iter + 1;
            %% define the filenames and names of folders in order to obtain data
            fprintf('\n processing subj %s in the %s condition\n', psdnym, conds{c})
            prompt = strcat('What is the correct foldername (type ''n/a'' if not available)?\n');
            folname = input(prompt);
            if strcmp(folname, 'n/a')
                continue
            end
            
            prompt = strcat('What is the correct filename(type ''n/a'' if not available)?\n');
            recname = input(prompt);
            
            % Start loading data by first defining required information
            res = ...
                load(fullfile(wdir, 'recordings\', char(folname), recname)); % loads data into temporary file
            
            s{iter}.accel1   = res.results.m1.accel_log;
            s{iter}.accel2   = res.results.m2.accel_log;
            
            s{iter}.gyro1    = res.results.m1.gyro_log;
            s{iter}.gyro2    = res.results.m2.gyro_log;
            
            s{iter}.timeIMU1 = res.results.m1.timeIMU_log;
            s{iter}.timeIMU2 = res.results.m2.timeIMU_log;
            
            s{iter}.tble    = res.results.t;
            s{iter}.IMU1start= res.results.IMU1start;
            s{iter}.IMU2start= res.results.IMU2start;
            s{iter}.rateIMU1 = res.results.m1.rateIMU;
            s{iter}.rateIMU2 = res.results.m2.rateIMU;
            
            s{iter}.psdnym  = psdnym;                                   % pseudonym
            s{iter}.epar    = res.results.epar;
            clear res_temp res
        end
    end
    save(savename, 's', '-v7.3');
end
mm.delete; m1.delete; clear mm m1;