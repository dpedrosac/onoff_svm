
% Analysis of the collected data


%%
wdir = 'C:\Users\David\Jottacloud\onoff_svm\';
if ~exist([wdir 'auswertungen'], 'dir')                                     % this command creates the directory - if not existent - where all results
    mkdir([wdir 'auswertungen\'])                                           % will be saved;
end

%%
adap = 3;
patdat = pat_list(wdir, 0);
fprintf('\na total of %d patients and %d control-subjects is analysed...\n', sum(double(patdat.group) == 1), sum(double(patdat.group) == 2))

%% Start with analyses
for n = 1:numel(adap)
    switch adap(n)
        case (1)
            data_read_pd(wdir, patdat)
            
        case (2)
            data_read_tug(wdir, patdat)
            
        case (3)
            preprocess_data(fullfile(wdir, 'analyses', 'raw_data\'), wdir, patdat, 'offset_detect')
            
        case (4)
            preprocess_data(fullfile(wdir, 'analyses', 'preprocessed\'), wdir, 'emg')
            
        case (5)
            plot_epoches(fullfile(wdir, 'analyses', 'epoched\'), wdir, 'all', 'all', 0)
            
    end
end