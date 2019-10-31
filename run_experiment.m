function run_experiment

addpath(genpath('C:\onoff_svm\skripte'));
maindir = 'C:\onoff_svm\';

% Construct a questdlg with three options
prompt = sprintf('Welcher Test soll gestartet werden?');
cond = questdlg(prompt, ...
    'Welcher Test soll gestartet werden?', 'Bewegung', 'Time up and go','Bewegung');

if strcmp(cond, 'Bewegung')
    fprintf('In wenigen Sekunden startet Test Nr. 1, drücken Sie CTRL + C zum abbrechen');
    pause(5)
    results = myo_onoff_noPTB(maindir);
else
    prompt = sprintf('Bitte geben Sie an, wieviele Wiederholungen gewünscht sind:');
    msrmnt = questdlg(prompt, ...
        'Wie viele Wiederholungen?', '1','5','8','5');
    fprintf('In wenigen Sekunden startet Test Nr. 2, drücken Sie CTRL + C zum abbrechen');
    pause(5)
    results = myo_timeupgo_noPSB(maindir, str2double(msrmnt));
end




