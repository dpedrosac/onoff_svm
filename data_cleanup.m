function data_cleanup(wdir, patdat)

%   This function ...

%   Copyright (C) November 2018
%   Max Wullstein, University Hospital of Gieﬂen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

%% An dieser Stelle if statement falls Daten noch nicht vorhanden
if ~exist('patdat'); pat_list(wdir, 0); end                                 % loads data without output of not already in workspace
conds = {'OFF', 'ON'};                                                      % different recorded conditions

% %% Dateien auslesen aus Myo-Daten
% for k = 1:size(patdat,1) % loop through all available subjects
%     psdnym = patdat.pseud(k);                                               % load the pseudonym for recordings
%     dirs = dir(fullfile(strcat(wdir, 'recordings\', char(psdnym), '*')));   % check for directories resulting from this subject
%     
%     if numel(dirs) == 0                                                     % if no data was recorded for the subject, an error is produced and the for-loop continues
%         fprintf('\nno data available for subject %s, skipping subject\n', psdnym)
%         continue
%     else
%         foldername = strcat(wdir, 'analyses\', char(psdnym), '\');          % name of the folder to be created in the analyses folder
%         if ~exist(strcat(wdir, 'analyses\', psdnym, '\'))                   % the next three lines create a folder in case data is available
%             mkdir(foldername);
%         end
%     end
%     
%     for c = 1:2 % loop through different conditions, i.e. OFF and ON
%         s = {};                                                             % pre-allocates space to be filled later
%         savename = ...
%             strcat(foldername, 'data', char(psdnym),'_', conds{c}, '.mat'); % filename that will be saved later
%         if exist(fullfile(foldername, savename))
%             fprintf('\nskipping condition %s for %s, as data already present', conds{c}, psdnym)
%             continue
%         else
%             for sess = 1:2 % loop though different sessions
%                 % provide the names of the folders and recordings in order
%                 % to load the data later
%                 recname = strcat(psdnym, '_', conds{c}, '_', num2str(sess)); % name of the raw data file under "normal conditions"; this is chedked in the newt few lines and may be chaged manually
%                 err = 0;                                                        % error is needed whenever only one session was used
%                 while ~exist(fullfile(wdir, 'recordings', char(recname)), 'dir')
%                     fprintf('filename for %s for condition %s is apparently inexistent please provide the correct name\n', psdnym, conds{c})
%                     prompt = 'What is the correct filename (type ''n/a'' if not available)?\n';
%                     recname = input(prompt);
%                     if strcmp(recname, 'n/a'); err = 1;                      % skips this while loop and continues in the script
%                         break
%                     end
%                 end
%                 
%                 if err == 0                                                 % (err = 0) indicates that no problem was present
%                     [openname, idx] = ...
%                         list_recordings(wdir, recname, sess, 0);            % if folder available, this checks for the name of the dataset in the folder
%                 else
%                     break                                                   % in cases where no data is available for a condition, the script stops at this point
%                 end
%                 
%                 % Start loading data by first defining required information
%                 try
%                     res = ...
%                         load(fullfile(wdir, 'recordings\', char(recname), openname)); % loads data into temporary file
%                 catch
%                     openname = ...
%                         list_recordings(wdir, recname, sess, 1, idx-1);     % whenever first attempt fails, it means that data saved before should be used, which is facilitated here
%                     try
%                         res = load(fullfile(wdir, 'recordings\', char(recname), openname)); % loads data into temporary file
%                     catch
%                         fprintf('filename still not found, please provide the name\n')
%                         prompt = 'What is the correct filename (e.g., ''recording_block_9_OFF_M1.mat'')?\n';
%                         openname = input(prompt);
%                         res = load(fullfile(wdir, 'recordings\', char(recname), openname)); % loads data into temporary file
%                     end
%                 end
%                 
%                 if contains (openname, 'block' )
%                     % introduce data into structure and save as file
%                     s{sess}.accel   = res.m1.accel_log;
%                     s{sess}.emg     = res.m1.emg_log;
%                     s{sess}.gyro    = res.m1.gyro_log;
%                     s{sess}.timeIMU = res.m1.timeIMU_log;
%                     s{sess}.timeEMG = res.m1.timeEMG_log;
%                     s{sess}.tble    = res.tble_temp;
%                     s{sess}.IMUstart= res.time_start_IMU;
%                     s{sess}.EMGstart= res.time_start_EMG;                   
%                 else
%                     s{sess}.accel   = res.results.m1.accel_log;
%                     s{sess}.emg     = res.results.m1.emg_log;
%                     s{sess}.gyro    = res.results.m1.gyro_log;
%                     s{sess}.timeIMU = res.results.m1.timeIMU_log;
%                     s{sess}.timeEMG = res.results.m1.timeEMG_log;
%                     s{sess}.tble    = res.results.t;
%                     s{sess}.IMUstart= res.results.IMUstart;
%                     s{sess}.EMGstart= res.results.EMGstart;                                        
%                 end
%                 
%             end
%             save(savename, 's', '-v7.3');
%         end
%     end
% end
% 
%
% %% Schneiden
%
% preprocess_data()
%
%
% %% Filtern
%
% preprocess_data()
%
% %% Speichern
%
% save_data()
%
