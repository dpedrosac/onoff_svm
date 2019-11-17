% Analysis of the collected data
if exist('C:\Users\david\', 'dir'); usr = 'david'; else usr = 'dpedr'; end
addpath(strcat('C:\Users\', usr, '\Jottacloud\onoff_svm\fieldtrip')); 
ft_defaults

%%
%wdir = 'C:\Users\david\Jottacloud\onoff_svm\';
wdir = strcat('C:\Users\', usr, '\Jottacloud\onoff_svm\');

%%
adap = 4;
patdat = pat_list(wdir);
fprintf('\na total of %d patients and %d control-subjects is analysed...\n', sum(double(patdat.group) == 1), sum(double(patdat.group) == 2))

%% Start with analyses
for n = 1:numel(adap)
    switch adap(n)
        case (1)
            data_read_pd(wdir, patdat)
            
        case (2)
            data_read_tug(wdir, patdat)
            
        case (3)
            preprocess_data(fullfile(wdir, 'analyses', 'raw_data\'), ...
                wdir, patdat, 'offset_detect')
            
        case (4)
            preprocess_data(fullfile(wdir, 'analyses', 'raw_data\'), ...
                wdir, patdat, 'cut')
            
        case (99)
            general_data(patdat)
    end
end