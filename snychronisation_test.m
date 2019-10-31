% function snychronisation_test

maindir = 'C:\onoff_svm\';
addpath(genpath(fullfile(maindir, 'skripte')))                              % adds the path in which all files/scripts, etc. are stored

%%
dur = 240; % 10 minutes
t = timer('TimerFcn', 'stat=false; disp(''Timer!'')',...
    'StartDelay', dur);
dat = nan(dur, 4);
%% Start with the MYO part, in which the myos are initialised and data is saved
sdk_path = 'C:/myo-sdk-win-0.9.0'; % root path to Myo SDK
install_myo_mex;                                                            % adds directories to MATLAB search path
try build_myo_mex sdk_path; catch; build_myo_mex(sdk_path); end             % builds myo_mex; Written this way ('try ... catch'), as if there is a problem, the routine ends itself and may be started again, therefore try-catch argument is included
countMyos   = 1;                                                            % number of MYO devices used for the experiment; more than one device is not advised as, it would not record the EMG
mm          = MyoMex(countMyos);
m1          = mm.myoData(1);                                                % continuos recordngs of MYO device is called m1 (saved later as results.mm)

tic;


iter = 0; iter2 = 0;
stamp = [];
stat=true;
start(t)
while(stat==true)
    iter = iter + 1;
    fprintf('\nrunning for %s secs\n', num2str(iter));
    dat(iter,1) = length(m1.timeEMG_log);
    dat(iter,2) = length(m1.timeIMU_log);
    dat(iter,3) = toc;
    dat(iter,4) = iter;
    pause(1)
    if mod(iter,5) == 0
        iter2 = iter2 + 1;
        stamp(iter2,1) = length(m1.timeIMU_log)/50;
        stamp(iter2,2) = length(m1.timeEMG_log)/200;
        stamp(iter2,3) = length(m1.timeIMU_log)/m1.rateIMU;
        stamp(iter2,4) = length(m1.timeEMG_log)/m1.rateEMG;
        
        stamp(iter2,5) = iter;
    elseif iter == 0; stat=false;
    end
end

time_emg = m1.timeEMG_log;
time_imu = m1.timeIMU_log;
m1.stopStreaming()
figure; subplot(2,1,1); plot(dat(:,1)./m1.rateEMG); hold on; plot(dat(:,2)./m1.rateIMU); plot(dat(:,3))
keyboard;