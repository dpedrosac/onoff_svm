function [ey, ex] = acc_on(sig)

%   This function is intended to measure the time between the stimuli and
%   the onset of Accelerometer activity. It is elaborated from the 
%   Teager Keiser Energy Operator Vectorized script (by Hooman Sedghamiz),
%   which can be found at Mathcentral.


%   Copyright (C) November 2018
%   Max Wullstein, Urs Kleinholdermann, David Pedrosa University Hospital of Gieﬂen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.


sig=sig(:);
%% (x(t)) = (dx/dt)^2+ x(t)(d^2x/dt^2) 
%Operator 1
y=diff(sig);
y=[0;y];
squ=y(2:length(y)-1).^2;
oddi=y(1:length(y)-2);
eveni=y(3:length(y));
ey=squ - (oddi.*eveni);
%% [x[n]] = x^2[n] - x[n - 1]x[n + 1] 
%operator ex
squ1=sig(2:length(sig)-1).^2;
oddi1=sig(1:length(sig)-2);
eveni1=sig(3:length(sig));
ex=squ1 - (oddi1.*eveni1);
ex = [ex(1); ex; ex(length(sig)-2)]; %make it the same length
