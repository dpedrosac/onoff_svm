function savedata2csv(dat, wdir, psdnym, type, option)

%   This script saves all available data to csv files, in order to do the
%   analyses later in different programs, if needed

% inputs:
%   (1) data as structure with time x channel x trial matrix
%   (2) working directory from which the saving folder is derived
%   (3) name of the subject as pseudonym
%   (4) type of data, i.e. ACC, GYRO or EMG data
%   (5) option, that is whether pca or nopca data

%   Copyright (C) Mai 2019, D. Pedrosa, University Hospital of Gießen and
%   Marburg
%
%   This software may be used, copied, or redistributed as long as it is not
%   sold and this copyright notice is reproduced on each copy made. This
%   routine is provided as is without any express or implied warranties
%   whatsoever.

%% Formulae needed
idx = [1:4; 5:8];
dim_dat = size(dat);                                                        % save dimensions to later reshape data back if needed
if size(dat,2) > 1  % concatenate data to single dimension in order to make data work
    dat = cat(1, dat(:));                                                    % concatenate data to single column
end
conds =  repmat({'dd', 'hld', 'rst', 'tap'},[dim_dat(2),1]);
if strcmp(option, 'pca'); dims = 2; else; dims = 3; end 

%% create the folder in case not present
foldername = fullfile(wdir, 'analyses', 'csvdata', option);                 % define the folder in which data will be saved
foldername_subj = ...
    fullfile(wdir, 'analyses', 'csvdata', 'subj', psdnym, option);

if ~exist(foldername, 'dir'); mkdir(foldername); end                        % create the folder, inf inexistant
if ~exist(foldername_subj, 'dir'); mkdir(foldername_subj); end              % create the folder, inf inexistant

p = progressbar(nansum(cell2mat(cellfun(@(x) size(x,dims), dat, 'Un', 0))), ...
    'percent' );                                                            % JSB routine for progress bars
iter = 0;
for k = 1:size(dat,1) % loop through available conditions
    for m = 1:size(dat{k},dims)
        iter = iter+1;                                                      % (iter) is needed to get make the progressbar work correctly
        p.update( iter );                                                   % progress bar for all recordins
        [c,f] = find(idx==k);                                               % find index in order to determine the condition (see {conds} above)
        
        if dim_dat(2) == 1                                                  % when there is just one condition, a CTRL subject is expected; otherwise
            cond = 'CTRL';                                                  % two different possiblities emerge: (a) OFF or (b) ON condition
        elseif dim_dat(2) > 1 && c == 1
            cond = 'OFF';
        else
            cond = 'ON';
        end
        
        filename = ...                                                      % defines the filename that is saved later into th HDD
            fullfile(foldername, strcat(psdnym, '_', conds{c,f}, '_', ...
            cond, '_', type, '_trial',  num2str(m), '_', option, '.txt'));

        filename2 = ...                                                      % defines the filename that is saved later into th HDD
            fullfile(foldername_subj, strcat(psdnym, '_', conds{c,f}, '_', ...
            cond, '_', type, '_trial',  num2str(m), '_', option, '.txt'));

        if strcmp(option, 'nopca')
            fid = fopen(filename, 'w');
            formatSpec = strcat(repmat('%.16f\t', [1, size(dat{k},2)-1]), '.16f\n');
            fprintf(fid,formatSpec,squeeze(dat{k}(:,:,m)));            
            fclose(fid);

            fid = fopen(filename2, 'w');
            fprintf(fid,formatSpec,squeeze(dat{k}(:,:,m)));            
            fclose(fid);

        else
            
            fid = fopen(filename, 'w');
            formatSpec = '%0.16f\n';
            fprintf(fid,formatSpec,squeeze(dat{k}(:,m)));            
            fclose(fid);
            
        end
    end
end

fprintf('\nSaving csv file for %s, using %s and with %s condition, done!\n', psdnym, type, option)
