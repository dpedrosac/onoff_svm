which function run_experiment_final
%   This function runs all parts of the experiment. Specifically, one may
%   chose for the two different experiments and is guided through the
%   recordings in detail.

%   Copyright (C) July 2018, modified September 2018
%   D. Pedrosa, Urs Kleinholdermann, Max Wullstein, University Hospital of Gießen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

maindir = 'C:\Users\David\Jottacloud\onoff_svm\';
addpath(genpath(fullfile(maindir, 'skripte')))                              % adds the path in which all files/scripts, etc. are stored

% Construct a questdlg with three options
prompt = sprintf('Welcher Test soll gestartet werden?');                    % Two distinct tests may be selected, either the movement task or the T&G task
cond = questdlg(prompt, ...
    'Welcher Test soll gestartet werden?', 'Bewegung', 'Time up and go', 'Bewegung');
try
    if strcmp(cond, 'Bewegung')
        fprintf('In wenigen Sekunden startet Test Nr. 1, drücken Sie CTRL + C zum abbrechen');
        pause(2)
        results = myo_onoff_final(maindir); %#ok<*NASGU>
    else
        prompt = ...
            sprintf('Bitte geben Sie an, wieviele Wiederholungen gewünscht sind:');
        msrmnt = questdlg(prompt, ...
            'Wie viele Wiederholungen?', '1','5','8', '5');
        fprintf('In wenigen Sekunden startet Test Nr. 2, drücken Sie CTRL + C zum abbrechen');
        pause(2)
        results = myo_timeupgo_final(maindir, str2double(msrmnt));
    end
catch
    fprintf('An error occured. For details see Matlab')
    pause(10);
end
exit                                                                        % exits MATLAB in order to avoid conflicts with the Myo system etc.