
if exist('C:\Users\david\', 'dir'); usr = 'david'; else usr = 'dpedr'; end
wdir = strcat('C:\Users\', usr, '\Jottacloud\onoff_svm\');
patdat = pat_list(wdir);
loaddir = fullfile(wdir, 'analyses', 'raw_data\');

%%
data = [];
iter = 0;
k = [1:17, 27:44]

for k = k
    iter = iter +1;
    filename = ...
        fullfile(loaddir, ...
        strcat('data', char(patdat.pseud(k)), '.mat'));             % specifies the filename for the subject
    pat = char(patdat.pseud(k));                                    % extracts the pseudonym which is processed
    load(filename)
    
    for rec = 1:4
        try
            data(iter, rec) = s{rec}.rateIMU;
            name{k} = pat;
        catch
            fprintf('\nsubject %s not found, continuing with next subject ...\n', patdat.pseud(k))
            continue
        end
    end
end