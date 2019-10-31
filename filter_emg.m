function emg_filt = filter_emg(dat, filterOrder, f_hpf, f_lpf, sr, rectify)

%   This script preprocesses EMG data. Thereby, first a notch filter for
%   the main frequency is applied. Consecutively, data is high-pass filtered
%   at f_hpf, low-pass filtered at f_lpf and finally rectified (optional)

%   Copyright (C) October 2015, D. Pedrosa, University Hospital of Cologne
%
%   This software may be used, copied, or redistributed as long as it is not
%   sold and this copyright notice is reproduced on each copy made. This
%   routine is provided as is without any express or implied warranties
%   whatsoever.

for n = 1:size(dat,2)
    dat(n,:) = dat(n,:) - mean(dat(n,:));
end

fo = 50;  q = 35; bw = (fo/(sr/2))/q;
[b,a] = iircomb(sr/fo,bw,'notch'); % Note type flag 'notch'
emg_filt = filtfilt(b, a, dat);

[b,a]=butter(filterOrder,2*f_lpf/sr,'low');
emg_filt = filtfilt(b, a, emg_filt);

[b,a]=butter(filterOrder,2*f_hpf/sr,'high');
emg_filt = filtfilt(b, a, emg_filt);

if rectify == 1
    emg_filt = abs(emg_filt);
end

end