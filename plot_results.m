function plot_results(varargin)
if nargin==1
    data = load(varargin{1});
else
    data = load('c:\onoff_svm\recordings\79_MKU_CT0109_CTRL_1\recording_total_CTRL_M1.mat');
end

nconds = 4;

for cond=[1:nconds]
    tstart = data.results.t.start_trial(cond);
    tend   = tstart+data.results.t.trial_duration(cond);
    time = data.results.m1.timeIMU_log;
    acc  = data.results.m1.accel_log;
    waitforbuttonpress
end
