function epar = expSettings(maindir)
%   This function provides all necessary options for the experiment with
%   the MYO™ wristband.

%   Copyright (C) January 2019
%   D. Pedrosa, University Hospital of Gießen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

epar.ExpName         = 'myo_onoffPD_stim';                                  % name of the experiment
epar.UseCatchLoop    = false;%true => for debugging (see: expdriver_RunTask)
if nargin > 0
    epar.session     = subjectinfo(maindir);                                % get session info from the script in subjectinfo.m, if a maindir is provided
end
epar.ntrials         = [9,3];                                              % number of trials for the two "blocks" [1:3 and 4, see conditions]
epar.tasks           = {'hold', 'tapping', 'diadochokinesia', 'rest'};      % task names
epar.ntasks           = numel(epar.tasks);
epar.dur_tr          = [4.5, 4.5, 4.5, 8];
epar.r_int           = [1.3, 2];                                            % duration of fixation cross before the trial

epar.fx_rand         = @(x,y) (x(2)-x(1)).*rand(1) + x(1);                  % Randomisation formula to get values between x and y
epar.trial_order     = ...
    random_generator(0, epar.ntasks, epar.dur_tr(2), ...
    epar.dur_tr(end), epar.ntrials(1), epar.ntrials(end), 1);
rpt_rest = find(epar.trial_order == 4);
while any(diff(rpt_rest) == 1)
    epar.trial_order     = ...
        random_generator(0, epar.ntasks, epar.dur_tr(2), ...
        epar.dur_tr(end), epar.ntrials(1), epar.ntrials(end), 1);
    rpt_rest = find(epar.trial_order == 4);
end