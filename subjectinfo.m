function session = subjectinfo(maindir)
%   This function provides interactive dialogues, serving to provide 
%   information needed to save data, run the correct experiment, etc. 

%   Copyright (C) February 2018, modified July 2018
%   D. Pedrosa, U. Kleinholdermann and M. Wullstein, University Hospital of Gießen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

check = 1;
while check
    prompt = {'Pseudonym:'};
    title = 'Bitte geben Sie das genaue Pseudonym des Teilnehmers ein';
    size = repmat([1,90],[1 1]);                                            % set size of entry box to 90X1
    psdnm = inputdlg(prompt,title,size);                                      % get the details of the experiment and create a new folder
    
    % Construct a questdlg with three options
    prompt = sprintf('Bitte geben sie die Kondition ein:');
    cond = questdlg(prompt, ...
        'Which condition ', 'ON','OFF','CTRL','OFF');
    
    if strcmp(cond, 'CTRL')
        % Construct a questdlg with two options
        prompt = sprintf('Bitte geben Sie an, welche Messung dies ist:');
        msrmnt = questdlg(prompt, ...
            'Which run ', '1','2','1');
    elseif strcmp(cond, 'ON')
        % Construct a questdlg with four options
        prompt = sprintf('Bitte geben Sie an, welche Messung dies ist:');
        msrmnt = questdlg(prompt, ...
            'Which run ', '3','4','3');
    else  
        % Construct a questdlg with four options
        prompt = sprintf('Bitte geben Sie an, welche Messung dies ist:');
        msrmnt = questdlg(prompt, ...
            'Which run ', '1','2','1');
    end
    
    % Construct a questdlg with three options
    queststr = sprintf('Stimmt die folgende Information über dem Teilnehmer?\nPseudonym: %s\nKondition: %s\nMessung: %s\n', psdnm{:}, cond, msrmnt);
    choice = questdlg(queststr, 'Bestätigung der Daten', 'Ja','Nein','Ja');
    
    % Handle response and run the while loop whil information is not correct
    switch choice
        case 'Nein'
            check = 1;
            continue
    end
    
    % Add info to a new structure, from which data will be retrieved
    session = struct('psdnm', psdnm, 'cond', cond, 'msrmnt', msrmnt);
    
    % Check if the folder already exists, in order to avoid losing data by
    % overwriting something
    session.name = sprintf('%s_%s_%s', session.psdnm, session.cond, session.msrmnt);         % core name of files that will be saved later
    folder_name = char(strcat(maindir, 'recordings\',[session.name], '\')); % name of the folder to be created
    if exist(folder_name, 'dir')       % check if the folder is present and create a new folder in case it isn't
        uiwait(msgbox({'Das Verzeichnis existiert bereits.', 'Bitte prüfen Sie, ob Sie fortfahren wollen, damit keine Daten verloren gehen'},'Warning','modal'));
        prompt = sprintf('Wollen Sie fortfahren?');
        cntn = questdlg(prompt, ...
            'Fortfahren ', 'Ja','Nein','Ja');
        if strcmp(cntn, 'Ja')
            check = 0;
        else
            check = 1;
        end
    else
        try
            mkdir(folder_name);
            fprintf('\n new folder %s was created \n', folder_name)
            check = 0;
        catch
            fprintf('\n folder %s could not be created \n', folder_name)
            check = 1;
        end
    end
    session.folder_name = folder_name;
end