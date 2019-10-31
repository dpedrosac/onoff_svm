function dat_filt = preproc_emg(dat, bttemp, filterOrder, lpf, hpf, sr, flag_check)

%   This script preprocesses a time series. Thereby, first a band-pass
%   filter is applied, a PCA and finally later data is low-pass filtered at f_lpf

%   Copyright (C) October 2019, D. Pedrosa, University Hospital of Cologne
%
%   This software may be used, copied, or redistributed as long as it is not
%   sold and this copyright notice is reproduced on each copy made. This
%   routine is provided as is without any express or implied warranties
%   whatsoever.

%% Formulae needed
fx_demean = @(x) x-mean(x);
fx_transpose = @(x) x.';
fx_abs = @(x) fx_transpose(abs(x));
dim_dat = size(dat);                                                        % save dimensions to later reshape data back if needed
if size(dat,2) > 1  % concatenate data to single dimension in order to make data work
    dat = cat(1, dat(:));                                                    % concatenate data to single column
end

%% Remove bad trials
dat_gt = arrayfun(@(q) dat{q}(:,:, str2num(bttemp{q})), ...               % the next two lines remove the 'bad trials' in order to proceed
    1:size(dat,1), 'Un', 0); %#ok<ST2NM>

%% Concatenate and demean data
for k = 1:size(dat_gt,2)
    clear dattemp; dattemp = dat_gt{k};
    dims{k} = size(dattemp);
    dattemp = reshape(fx_demean(dattemp), [dims{k}(1)*dims{k}(3), dims{k}(2)]);
    dat_conc{k} = dattemp; %clear dat_gt
end

%% Filter data (Highpass filter, rectify, lowpass filter)
[dat_filt, bhigh, ahigh] = ...
    arrayfun(@(q) ft_preproc_highpassfilter(dat_conc{q}.', sr, ...
    hpf, filterOrder, 'but', 'twopass','no'), 1:size(dat_conc,2), 'Un', 0);
dat_filt = arrayfun(@(q) fx_abs(dat_filt{q}), 1:numel(dat_filt), 'Un', 0);

[dat_filt, ~, ~] = ...
    arrayfun(@(q) ft_preproc_lowpassfilter(dat_filt{q}.', sr, ...
    lpf, filterOrder, 'but', 'twopass','no'), 1:size(dat_filt,2), 'Un', 0);
dat_filt = ...
    arrayfun(@(q) fx_transpose(dat_filt{1,q}), 1:size(dat_filt,2), 'Un', 0);

if flag_check == 1
    plot_filter_response(sr, 99, bhigh{1}, ahigh{1}, [0 sr/2+1], 'band');
    % insert code for check of PSD, if toolbox is available
end

dat_filt = arrayfun(@(q) reshape(dat_filt{q}, ...
    [dims{q}(1), dims{q}(2), dims{q}(3)]), 1:size(dat_filt,2), 'Un', 0);    % reshape data back to original format after filtering

%% reshapes data back to original data size in order to return same data structure in function
if dim_dat(2)>1 
    dat_filt = reshape(dat_filt, [dim_dat(1), dim_dat(2)]);
end
