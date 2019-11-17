function preprocess_data(loaddir, wdir, patdat, option, k, cl_opt)

%   This function offers different options of how data may be preprocessed.
%   Depending upon the (option), different processing steps may be
%   undertaken; The function is built in a way, that multiple runs are
%   possible, e.g. running first hpf and consequently lpf, and, can
%   additionally be used for the entire list or for a spedicif subject

%   inputs:
%       loaddir = directory in which data to be processed is saved
%       wdir    - working directory data will be read from
%       patdat  - list of subjects available
%       option  = different possibilities such as 'offset_detect' or 'epoch'
%       k       = pseudonym of subject to preprocess, or, 'all'
%       cl_opt  = clear option, i.e. only valid with 'offset_detect' option
%       and if k is a specific participant

%   Copyright (C) November 2018, modified May 2019
%   David Pedrosa, Max Wullstein, University Hospital of Gieﬂen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

if nargin < 5 || strcmp(k, 'all')                                           % argument which ensures that all data is inserted correctly
    %k = 1:size(patdat,1);
    k = find(patdat.group == '1').';                                        % select only patients from the list of interest
    cl_opt = 0;
elseif nargin < 6
    cl_opt = 0;                                                             % (cl_opt) is only possible if one subject is analysed)
end

bt = bad_trials(wdir);                                                      % extracts the trials that should be used for every subject

switch option % these are the options available: (1) offset_detection via an interactive figure and (2) cut via a plotting routine for all available trials
    case 'offset_detect'
        fprintf('\nall data is being preprocessed and offsets are determined\n')
        foldername = strcat(wdir, 'analyses\preprocessed\');                % name of the folder to be created
        
    case 'cut'
        fprintf('\ndata is epoched into chunks and preprocessed\n')
        foldername = strcat(wdir, 'analyses\epoched\');                     % name of the folder to be created
        fx_all = @(x) x(:);                                                 % function to transpose all data and create a vector
        
    otherwise
        fprintf('The choice does not exist. Please use either ''offset_detect'' or ''epoch''\n');
        return                                                              % stops the script in case no valid option is provided
end

if ~exist(foldername); mkdir(foldername); end                               %#ok<EXIST> % the next lines create the folder in case not available already

for k = k % loop through all available subjects/ all subjects in the list
    fprintf('Analysing subj: %s\n', char(patdat.pseud(k)));
    switch option
        case 'offset_detect'    % first option is needed to manually detect the offset so that cutting data is precise; data will be saved in the available structire {s} as offset value
            filename = ...
                fullfile(loaddir, strcat('data', ...
                char(patdat.pseud(k)), '.mat'));                            % specifies the filename for the subject
            done = 0; close all;                                            % will be needed later, for a while argument to run until data is completed
            pat = char(patdat.pseud(k));
            
            try load(filename);                                             %#ok<*LOAD> % loads data into workspace to work with it
            catch
                fprintf('\nsubj %s not found, please specify pseudonym correctly/n', pat);
                continue
            end
            
            if cl_opt == 1; s{1} = rmfield(s{1}, 'offset'); end             % this option can be set at the beginning of the function to erase the offset in a specific participant (k)
            if isfield(s{1}, 'offset'); continue; end                       % ensures that only data of subjects is plotted who have not been analysed before
            
            savename = filename;                                            % this step is intended to get the individual offset values for every recording
            offset = zeros(1,size(s,2));                                    % start without any offset and plot data to see if an offset is needed
            offset_plots(s, offset, char(patdat.pseud(k)));                 % plotting routine with one plot showing IMU at the left and EMG data on the right side
            keyboard;
            
            while done == 0 % run until (done) is set to 1;
                for kpr = 1:size(s,2) % no. of recordings (PD: 4 (2xOFF, 2xON), CTRL: 2)
                    prompt{kpr} = ...
                        sprintf('Please insert the offset in secs. for rec. %s:', num2str(kpr)); %#ok<AGROW>
                end
                
                dlg_title = 'Input offsets manually (as per figure 101-104)';
                num_lines = 1;
                try defaultans = {asw{1}, asw{2}, asw{3}, asw{4}}; catch
                    defaultans = {'', '', '', ''}; end
                asw = inputdlg(prompt,dlg_title,num_lines,defaultans);      % (asw) is the answer that is provided for the question of the offset
                
                if any(cell2mat(cellfun(@numel, cellfun(@str2num, asw, ...
                        'Un', 0),'Un', 0)) >1) || ...
                        any(cell2mat(cellfun(@isempty, asw, 'Un', 0)))      % is any of the answers is empty, or a comma is included the script will drop a warning message and ask for new data
                    msg = ['Please enter correct values for offset,', ...
                        'i.e. enter a value for every recording and', ...
                        'ensure that data is separated by dot instead of comma'];
                    f = warndlg(msg,'Wrong offset input');
                    waitfor(f); done = 0;                                   % the scxript continues whenever something was selected from the GUI
                    
                else
                    done = 1; close all;
                    offset = cell2mat(cellfun(@str2num, asw, 'Un', 0));     % transform (offset) from structure to array
                    offset_plots(s, offset, char(patdat.pseud(k)));         % plot the offsets
                    keyboard;
                    
                    prompt = sprintf('Is the offset now precise?');
                    cond = questdlg(prompt, ...
                        'Which condition ', 'YES','NO','YES');
                    waitfor(cond)
                    if strcmp(cond, 'NO'); done = 0;
                        offset_plots(s, offset, char(patdat.pseud(k)));
                        clear kpr prompt
                    else
                        for och = 1:size(s,2)
                            s{och}.offset = ...
                                str2double(asw{och}); %#ok<AGROW>           % the offset is saved in the available structure {s] as offset.
                        end
                    end
                end
            end
            save(savename, 's', '-v7.3');                                   % save data to HDD
            
        case 'cut'
            filename = ...
                fullfile(loaddir, ...
                strcat('data', char(patdat.pseud(k)), '.mat'));             % specifies the filename for the subject
            pat = char(patdat.pseud(k));                                    % extracts the pseudonym which is processed
            
            %% Settings for cutting data
            dur     =   10;                                                 % total duration of data (in secs.)
            srEMG   =   200;                                                % sampling rate EMG
            srIMU   =   50;                                                 % sampling rate IMU
            bpf     =   [1 15];                                             % bandpass filters for IMU preprocessing
            
            try load(filename);                                             % loads data into workspace to work with it
            catch
                fprintf('\nsubj %s not found, please specify pseudonym correctly/n', pat);
                continue
            end
            
            savefile = ...
                strcat('data_epoched', char(patdat.pseud(k)), '.mat');      % filename under which data will be saved at the end
            savename = fullfile(wdir, 'analyses', 'epoched', savefile);     % entire filename including folders
            
            if (exist(savename, 'file') && cl_opt == 0)                     % checks if data is already present and if the clearing option is inactive and continues if so in order to avoid redundancy
                continue;
            else
                %% Pre-allocate space to fill later with data
                imu_acc = cell(4,2);
                imu_gyro = cell(4,2);
                emg = cell(4,2);
                for recs = 1:size(s,2) % loop through available recordings
                    if strcmp(s{recs}.tble(1,5), 'OFF') || ...              % finds out whether condition is 'OFF' for PD-patients or CTRL-subjects, otherwise (c) = 2;
                            strcmp(s{recs}.tble(1,5), 'CTRL')
                        c = 1;
                    else
                        c = 2;
                    end
                    idx = find(cell2mat(s{recs}.tble(:,7)));                % index of available recordings according to s{x}.tble
                    idx = idx(1:end-1);                                     % skip last recording to avoid problem with cutting data
                    trldat = {nan(size(idx,1), dur*srIMU), ...              % preallocates space to fill later with indices of data to be cut
                        nan(size(idx,1), dur*srEMG)};
                    
                    %% switch that enables skipping offset correction
                    offset_on = 1;
                    switch (offset_on)
                        case (0)
                            s{recs}.offset = 0;
                    end
                    
                    beg_trls = ...
                        cell2mat(s{recs}.tble(idx,8))-s{recs}.offset*s{recs}.rateIMU;
                    trldat{1} = ceil(repmat(beg_trls,[1,dur*srIMU]) + ...   % (trldat{1}) = start index for all trials in continuous recording for IMU
                        repmat([0:srIMU*dur-1], [size(beg_trls,1), 1]));
                    
                    beg_trls = ...
                        cell2mat(s{recs}.tble(idx,7))-s{recs}.offset*s{recs}.rateEMG;
                    trldat{2} = ceil(repmat(beg_trls,[1,dur*srEMG]) + ...   % (trldat{2}) = start index for all trials in continuous recording for EMG
                        repmat([0:srEMG*dur-1], [size(beg_trls,1), 1]));
                    clear beg_trls;
                    par = unique(s{recs}.tble(idx,3));                      % all available motor/rest paradigms in the dataset
                    
                    for p = 1:size(par,1) % loop through all available conditions and extract available data
                        clear idx_conds dattemp*;
                        idx_cond = find(strcmp(s{recs}.tble(idx,3), par{p}));  % idx of the condition to be extracted
                        
                        for tr = 1:size(idx_cond,1) % loop though all trials to obtain data per trial
                            if isempty(imu_acc{p,c})
                                imu_acc{p,c}(:,:,1) = ...
                                    s{recs}.accel(trldat{1}(idx_cond(tr),:).',:);
                                imu_gyro{p,c}(:,:,1) = ...
                                    s{recs}.gyro(trldat{1}(idx_cond(tr),:).',:);
                                emg{p,c}(:,:,1) = ...
                                    s{recs}.emg(trldat{2}(idx_cond(tr),:).',:);
                            else
                                imu_acc{p,c}(:,:,end+1) = ...
                                    s{recs}.accel(trldat{1}(idx_cond(tr),:).',:);
                                imu_gyro{p,c}(:,:,end+1) = ...
                                    s{recs}.gyro(trldat{1}(idx_cond(tr),:).',:);
                                emg{p,c}(:,:,end+1) = ...
                                    s{recs}.emg(trldat{2}(idx_cond(tr),:).',:);
                            end
                        end
                    end
                end
                
                if isempty(bt{k}) || any(isnan(bt{k})) % if bt is neither empty nor NaN; otherwise, error is provided
                    %% Plot data in order so the the results of cutting data into chunks;
                    nums = {[1:4;5:8], [9:12;13:16], [17:20;21:24]} ;
                    for c = 1:2 % loop through conditions
                        if c == 1; cond = 'OFF'; else; cond = 'ON'; end
                        yls = [min(fx_all(cat(3,imu_acc{:}))), ...
                            max(fx_all(cat(3,imu_acc{:})))];
                        arrayfun(@(q) plot_epoched_data(imu_acc{q,c}, pat, ...
                            par{q}, cond, nums{1}(c,q), srIMU, 'ACC', yls), 1:size(imu_acc,1), 'Un', 0)
                        
                        yls = [min(fx_all(cat(3,imu_gyro{:}))), ...
                            max(fx_all(cat(3,imu_gyro{:})))];
                        arrayfun(@(q) plot_epoched_data(imu_gyro{q,c}, pat, ...
                            par{q}, cond, nums{2}(c,q), srIMU, 'GYRO', yls), 1:size(imu_gyro,1), 'Un', 0)
                    end
                    fprintf('\nPlease extract bad trials for all conditions and motor tasks for subj: %s \nfrom the figures and save them. Press Continue (or F5 BTW!) to continue with script\n', pat);
                    keyboard;
                
                else
                    clear idx; idx = 1:8;
                    if strcmp(s{1}.tble(1,5), 'CTRL'); idx = 1:4; end       % this line ensures, that CTRL subjects are treated differently
                    [dat_preproc_acc_nopca, dat_preproc_acc_pca] = ...
                        preproc_imu(imu_acc, {bt{k,idx}}, 2, bpf, srIMU, 0);% band pass filter data between [1 20] Hz amd usinf a 2nd Order Butterworth filter
                    [dat_preproc_gyro_nopca, dat_preproc_gyro_pca] = ...
                        preproc_imu(imu_gyro, {bt{k,idx}}, 2, bpf, srIMU, 0);
                    
                    dat_preproc_emg = ...
                        preproc_emg(emg, {bt{k,idx}}, 2, 20, 35, srEMG, 0); % Filter EMG data High- and lowpass filter and rectify in between
                    
                    savedata2csv(dat_preproc_acc_nopca, wdir, ...
                        char(patdat.pseud(k)), 'ACC', 'nopca')
                    savedata2csv(dat_preproc_acc_pca, wdir, ...
                        char(patdat.pseud(k)), 'ACC', 'pca')
                    
                    savedata2csv(dat_preproc_gyro_nopca, wdir, ...
                        char(patdat.pseud(k)), 'GYRO', 'nopca')
                    savedata2csv(dat_preproc_gyro_pca, wdir, ...
                        char(patdat.pseud(k)), 'GYRO', 'pca')
                    
                    savedata2csv(dat_preproc_emg, wdir, ...
                        char(patdat.pseud(k)), 'EMG', 'nopca')
                end
                close all;
                
                s = {dat_preproc_acc_nopca, dat_preproc_acc_pca, ...
                    dat_preproc_gyro_nopca, dat_preproc_gyro_pca, ...
                    dat_preproc_emg};
                save(savename, 's', '-v7.3');                                   % save data to HDD
            end
    end
end