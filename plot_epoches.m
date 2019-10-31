function plot_epoches(loaddir, wdir, patno, trlno, inspection)

%   This function illustrates the different conditions and offers the
%   to automatically discard trials that look wrong or are contaminated by
%   artefacts

%   Copyright (C) December 2018
%   Max Wullstein, University Hospital of Gieﬂen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

patdat  = pat_list(wdir, 0);                                    %#ok<*EXIST> % loads data without output of not already in workspace
par = figure_params_gen;                                                    % load general parameters for plotting (see function for details)
sr1 = 50; sr2 =200;
thresh = 'hilb';
hpf = 10;
iter = 0;

% Formulae needed throughout this script
fx_conv = @(x) x;
fx_conc = @(x) x(:);                                                        % formula to concatenate all data
fx_trls = @(x) size(x,2);                                               % formula to obtain all trials
fx_demean = @(x) x-nanmean(x);

lab = {'ACC', 'GYR', 'EMG'};
idx_fig = {100:200; 200:300};
if nargin == 3
    inspection = 0;
    trlno = [];
elseif nargin == 2
    patno = 'all';                                                          % if not stated otherwise, all subjects are used
    inspection = 0;
    trlno = [];
end

if strcmp(patno, 'all')
    patno = table2array({patdat.no}).';
else
    patno = find(strcmp(table2array({patdat.pseud}), patno));
    clear xtemp
end

p = progressbar( size(patno,1), 'percent' );                               % JSB routine for progress bars
for k = patno % loop through all available subjects
    iter = iter +1;
    p.update( iter );                                                          % progress bar for all subjects
    
    fprintf('\n....... processing %s, .......\n', char(patdat.pseud(k)))
    filename = ...
        fullfile(loaddir, strcat('data_epoched', char(patdat.pseud(k)), '.mat'));% specifies the filename for the subject
    
    try load(filename);                                               % loads data into workspace to work with it
    catch
        fprintf('\nsubj %s not found, please specify pseudonym correctly/n', pat);
        continue
    end
    
    tno = ...
        sum(cell2mat(arrayfun(@(q) size(dat{q},2), 1:size(dat,1), 'Un', 0)));% total number of trials
    fprintf('\nprocessing %s/n', char(patdat.pseud(k)));
    fprintf('\nin total, there are %s trials\n', num2str(tno))
    
    dur = size(dat{1,1}{1,1},1)./sr1;                                       % estimates the duration of the epoched data in secs.
    time_vec1 = [1:dur*sr1]./sr1; time_vec2 = [1:dur*sr2]./sr2;             % creates time_vectors for the IMU and for EMG dataset
    for c = 1:size(dat,1) % loop through available conditions
        cds = unique(cellfun(@unique, dat{c,4}));
        ylims = nan(size(cds,2), 3);                                        % pre-allocate space
        for cond_name = 1:numel(cds) % loop through available condition names
            clear dat_lim*                                                  % clear data to avoid problems
            cat_idx = ...                                                   % find the indices of every condition
                find(cell2mat(cellfun(@(x) strcmp(x, cds{cond_name}), ...
                dat{c,4}, 'Un', 0)));
            dat_lim1 = [fx_conc(cat(1,dat{c,1}{1,cat_idx})), ...            % get the min/max for every sensor (ACC, GYR)
                fx_conc(cat(1,dat{c,2}{1,cat_idx}))];
            dat_lim2 = fx_conc(cat(1,dat{c,3}{1,cat_idx}));                 % get the min/max for EMG recordings
            ylims(cond_name,:) = [max(abs(min(dat_lim1(:,1))), max(dat_lim1(:,1))), ...
                max(abs(min(dat_lim1(:,2))), max(dat_lim1(:,2))), ...
                max(abs(min(dat_lim2(:,1))), max(dat_lim2(:,1)))];
        end
        clear cat_idx dat_lim                                               % clears temporary data for ylim detection
        if isempty(trlno); trlno = 1:fx_trls(dat{c,1}); end
        for trls = trlno % loop through available trials
            %%
            cond_idx = ...
                find(cell2mat(cellfun(@(q) strcmp(q, [dat{c,4}{trls}]), ...
                cds, 'Un', 0)));
            figure(idx_fig{c}(trls)); hold on;                                            % create new figure of sensor activity with information on trial onset and coding
            for dev = 1:3 % loop through different sensors (ACC; GYROSCOPE; EMG)
                clear dattemp
                dattemp = dat{c,dev}{1,trls};                               % for handling reasons, data is saved as own variable
                subplot(3,1,dev); hold on;                                  % three subplots are produced and stacked vertically
                if dev < 3
                    m_imu = plot(time_vec1, fx_demean(fx_conv(dattemp)));
                    for lc = 1:size(dattemp,2)
                        m_imu(lc).Color = [1 1 1].*(.05 + (.55-.05).*rand(1));
                    end
                    set(gca, 'FontName', par.ftname, ...
                        'FontSize', par.ftsize(2), 'XMinorTick', 'on');
                    ylabel(lab{dev}, 'FontName', par.ftname, 'FontSize', par.ftsize(2))
                    grid on; box off; grid minor
                    ylim([-1 1].*ylims(cond_idx, dev));
                    
                    switch thresh
                        case ('sd')
                            idx_bsl = dsearchn(time_vec1.', [2 3.5].');
                            thr = 5*nanstd(dattemp(idx_bsl(1):idx_bsl(2),:));
                            for f = 1:size(dattemp,2)
                                clear idx_all fst_idx
                                idx_all = sort([find(fx_demean(dattemp(:,f))>thr(f)); ...
                                    find(fx_demean(dattemp(:,f))<-thr(f))], 'ascend');
                                idx_range = dsearchn(time_vec1.', [4.5 9].');
                                fst_idx_temp = ...
                                    find(idx_all > idx_range(1) & idx_all < idx_range(2))
                                try fst_idx(f) = idx_all(fst_idx_temp(1))
                                catch fst_idx(f) = NaN
                                end
                            end
                        case ('hilb')
                            clear fst_idx
                            [bhigh, ahigh] = butter(4, hpf/(sr1/2));
                            dattemp = FiltFiltM(bhigh, ahigh, dattemp);
                            dattemp = abs(hilbert(dattemp));
                            dattemp = conv2([1], ones(1,sr1), dattemp, 'same');
                            dattemp = zscore(dattemp);
                            idx_temp= dattemp>0;
                            idx_range = dsearchn(time_vec1.', [2.5 9].');
                            
                            for f = 1:size(dattemp,2)
                                idx_all = find(idx_temp(:,f)==1);
                                fst_idx_temp = ...
                                    idx_all(idx_all >idx_range(1) & ...
                                    idx_all<idx_range(2));
                                try
                                    fst_idx(f) = fst_idx_temp(1);
                                catch
                                    fst_idx(f) = nan;
                                end
                            end
                    end
                    fst_idx(fst_idx==0) = NaN;
                    if any(~isnan(fst_idx)) && any(fst_idx~=226)            % if start of activity could be identified, plot this
                        plot([1 1].*time_vec1(nanmin(fst_idx)), [-.84 .84].*ylims(cond_idx, dev), '--r');
                        str = sprintf('activity onset\nat %0.2f', time_vec1(nanmin(fst_idx)));
                        text(.84*time_vec1(nanmin(fst_idx)), .64*ylims(cond_idx, dev), str, 'FontName', par.ftname, 'FontSize', ...
                            par.ftsize(1), 'HorizontalAlignment', 'center');
                    end
                else
                    m_emg = plot(time_vec2, fx_demean(dat{c,dev}{1,trls}));
                    for lc = 1:size(dattemp,2)
                        m_emg(lc).Color = [1 1 1].*(.05 + (.55-.05).*rand(1));
                    end
                    set(gca, 'FontName', par.ftname, ...
                        'FontSize', par.ftsize(2), 'XMinorTick', 'on');
                    ylabel(lab{dev}, 'FontName', par.ftname, 'FontSize', par.ftsize(2))
                    ylim([-1 1].*ylims(cond_idx, dev));
                    xlabel(sprintf('time [in secs.]'), 'FontName', par.ftname, ...
                        'FontSize', par.ftsize(2));
                    grid on; box off; grid minor
                    
                    switch thresh
                        case ('sd')
                            idx_bsl = dsearchn(time_vec1.', [2 3.5].');
                            thr = 5*nanstd(dattemp(idx_bsl(1):idx_bsl(2),:));
                            for f = 1:size(dattemp,2)
                                clear idx_all fst_idx
                                idx_all = sort([find(fx_demean(dattemp(:,f))>thr(f)); ...
                                    find(fx_demean(dattemp(:,f))<-thr(f))], 'ascend');
                                idx_range = dsearchn(time_vec1.', [4.5 9].');
                                fst_idx_temp = ...
                                    find(idx_all > idx_range(1) & idx_all < idx_range(2));
                                try fst_idx(f) = idx_all(fst_idx_temp(1));
                                catch fst_idx(f) = NaN;
                                end
                            end
                        case ('hilb')
                            clear fst_idx
                            [bhigh, ahigh] = butter(4, hpf/(sr2/2));
                            dattemp = FiltFiltM(bhigh, ahigh, dattemp);
                            dattemp = abs(hilbert(dattemp));
                            dattemp = conv2([1], ones(1,sr2), dattemp, 'same');
                            dattemp = zscore(dattemp);
                            idx_temp= dattemp>0;
                            idx_range = dsearchn(time_vec2.', [3.5 9].');
                            
                            for f = 1:size(dattemp,2)
                                idx_all = find(idx_temp(:,f)==1);
                                fst_idx_temp = idx_all(idx_all >idx_range(1) & idx_all<idx_range(2));
                                try
                                    fst_idx(f) = fst_idx_temp(1);
                                catch
                                    fst_idx(f) = nan;
                                end
                            end
                    end
                    fst_idx(fst_idx==0) = NaN;
                    if any(~isnan(fst_idx)) && any(fst_idx~=901)
                        plot([1 1].*time_vec2(nanmin(fst_idx)), [-.84 .84].*ylims(cond_idx, dev), '--r');
                        str = sprintf('activity onset\nat %0.2f', time_vec2(nanmin(fst_idx)));
                        text(.84*time_vec2(nanmin(fst_idx)), .64*ylims(cond_idx, dev), str, 'FontName', par.ftname, 'FontSize', ...
                            par.ftsize(1), 'HorizontalAlignment', 'center');
                    end
                    
                end
                if dev == 1
                    title(sprintf('%s, trial no. %s', char(dat{c,4}{1,trls}), num2str(trls)));
                end
            end
            keyboard
        end
    end
end
