%% test script to see whether preprocessing was done correctly

pars = {'dd', 'hld', 'rst', 'tap'};
savedir = 'C:\Users\dpedr\Jottacloud\onoff_svm\analyses\csvdata';
subj = '77_WPD_2607';
close all;
lims = [0, 4];
meds = {'OFF', 'ON'};

mods = 1;
switch mods
    case(0)
        modname = '_nopca';
    case(1)
        modname = '_pca';
end
for m = 1:numel(meds)
    for c = 4;%1:numel(pars) % loop through conditions
        figure(lims(m)+c); hold on;
        filename1 = strcat(subj, '_', pars{c}, '_', meds{m}, '_ACC_trial');
        for t = 1:50 % loop through trials
            filename = strcat(filename1, num2str(t), modname, '.txt');
            try
                dattemp = load(fullfile(savedir, filename));
            catch
                continue
            end
            subplot(5,5,t); plot(dattemp);
            ylim([-.2 .2]);
            xlim([200 400])
        end
    end
end