wdir        = 'C:\Users\dpedr\Jottacloud\onoff_svm\analyses\raw_data';
cd(wdir)
savefolder  = 'C:\Users\dpedr\Jottacloud\onoff_svm\analyses\tug\csvdata\';
listfiles   = dir("tug*.mat");
conds       = {'OFF', 'ON'};

% start the data extraction and saving into csv-file
for k = 1:numel(listfiles) % loop through all available subjects
    clear s
    load(listfiles(k).name);
    if isempty(s)
        continue
    end
    
    for c = 1:numel(s) % loop through both conditions
        if (isfield(s{c}, 'psdnym') || exist(s{c}))
            try
            savename = strcat(s{c}.psdnym, '_tug', cell2mat(table2array(s{c}.tble(1,3))), 'accel1', '.csv');     % filename under which all data will be saved
            catch
                keyboard
            end
            
            writematrix(s{c}.accel1, fullfile(savefolder, savename),...
                'Delimiter','tab')  % the next few lines write the data to a csv-file
            
            savename = strcat(s{c}.psdnym, '_tug', cell2mat(table2array(s{c}.tble(1,3))), 'accel2', '.csv');     % filename under which all data will be saved
            writematrix(s{c}.accel2, fullfile(savefolder, savename),...
                'Delimiter','tab')  % the next few lines write the data to a csv-file
            
            savename = strcat(s{c}.psdnym, '_tug', cell2mat(table2array(s{c}.tble(1,3))), 'gyro1', '.csv');     % filename under which all data will be saved
            writematrix(s{c}.gyro1, fullfile(savefolder, savename),...
                'Delimiter','tab')  % the next few lines write the data to a csv-file
            
            savename = strcat(s{c}.psdnym, '_tug', cell2mat(table2array(s{c}.tble(1,3))), 'gyro2', '.csv');     % filename under which all data will be saved
            writematrix(s{c}.gyro2, fullfile(savefolder, savename),...
                'Delimiter','tab')  % the next few lines write the data to a csv-file
        else
            continue
        end
    end
end