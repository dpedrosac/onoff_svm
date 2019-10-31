function save_thalmicmyo(mm, m1, savedir, time_start_IMU, time_start_EMG)

%   This function extracts the data from the continuous recordings of the 
%   MYO device and saves it to a separate file which may be loaded in a later 
%   ste p and may be processed

%   Copyright (C) February 2018
%   D. Pedrosa, University Hospital of Gieﬂen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

results.time_start_IMU  = time_start_IMU;
results.time_start_EMG  = time_start_EMG;
results.quat            = m1.quat;
results.rot             = m1.rot; 
results.gyro            = m1.gyro;
results.gyro_fixed      = m1.gyro_fixed;
results.accel           = m1.accel; 
results.accel_fixed     = m1.accel_fixed;
results.timeEMG         = m1.timeEMG; 
results.emg             = m1.emg; 
results.rateIMU         = m1.rateIMU;
results.rateEMG         = m1.rateEMG;

