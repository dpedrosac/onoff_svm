function [dat_filt, dat_pca] = preproc_imu(dat, bttemp, filterOrder, bpf, sr, flag_check)

%   This script preprocesses a time series. Thereby, first a band-pass
%   filter is applied, a PCA and finally later data is low-pass filtered at f_lpf

%   Copyright (C) October 2019, D. Pedrosa, University Hospital of Cologne
%
%   This software may be used, copied, or redistributed as long as it is not
%   sold and this copyright notice is reproduced on each copy made. This
%   routine is provided as is without any express or implied warranties
%   whatsoever.

%% Formulae needed
fx_demean = @(x) x-mean(x);                                                 % formula to deman data
fx_transpose = @(x) x.';                                                    % formula to make tranposition easier
dim_dat = size(dat);                                                        % save dimensions to later reshape data back if needed
if size(dat,2) > 1  % concatenate data to single dimension in order to make data work
    dat = cat(1, dat(:));                                                    % concatenate data to single column
end

%% Remove bad trials
try dat_gt = arrayfun(@(q) dat{q}(:,:, str2num(bttemp{q})), ...                 % the next two lines remove the 'bad trials' in order to proceed
    1:size(dat,1), 'Un', 0); %#ok<ST2NM>
catch
    fprintf('\nThe amount of indicated good trials is to large \nfor the available number of trials in some conditions.\nFor details see last column which should be equal or\nsmaller than second last one. Please double check\nand change the list in "patientenliste_onoff.xls"\n\n')
    disp([cell2mat(cellfun(@size, dat, 'Un', 0)), cell2mat(cellfun(@length, cellfun(@str2num, bttemp, 'Un', 0), 'Un', 0)).']);
    keyboard
    return
end
%% Concatenate and demean data
for k = 1:size(dat_gt,2)
    clear dattemp; dattemp = dat_gt{k};
    dims{k} = size(dattemp);                                                % reads out the no. of dimensions (needed in the next line, to concatenate and later to reshape)
    dattemp = ...
        reshape(fx_demean(dattemp), [dims{k}(1)*dims{k}(3), dims{k}(2)]);   % data is transformed to channel*trials x time
    dat_conc{k} = dattemp;                                                  % creates a new variable (dat_conc) to work with
end

%% Filter data (Bandpass filter)
[dat_filt, bband, aband] = ...                                              & band-pass filter according to filter settings using the fielfdtrip routines from aband and bband
    arrayfun(@(q) ft_preproc_bandpassfilter(dat_conc{q}.', sr, ...
    [bpf(1) bpf(2)], filterOrder, 'but', 'twopass','no'), ...
    1:size(dat_conc,2), 'Un', 0);
dat_filt = ...
    arrayfun(@(q) fx_transpose(dat_filt{1,q}), 1:size(dat_filt,2), 'Un', 0);% data is transposed to have it in original 

if flag_check == 1
    plot_filter_response(sr, 99, bband{1}, aband{1}, [0 sr/2+1], 'band')
    % insert code for check of PSD, if toolbox is available
end

dat_filt = arrayfun(@(q) reshape(dat_filt{q}, ...
    [dims{q}(1), dims{q}(2), dims{q}(3)]), 1:size(dat_filt,2), 'Un', 0);    % reshape data back to original format after filtering

dat_pca = ...
        arrayfun(@(q) pca_imudata(dat_filt{q}), 1:numel(dat_filt), 'Un', 0);% estimate sthe PCA of the data in order to reduce complexity

%% reshapes data back to original data size in order to return same data structure in function
if dim_dat(2)>1 
    dat_filt = reshape(dat_filt, [dim_dat(1), dim_dat(2)]);
    dat_pca = reshape(dat_pca, [dim_dat(1), dim_dat(2)]);
end
