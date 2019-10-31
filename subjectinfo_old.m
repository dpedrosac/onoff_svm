function session = subjectinfo(maindir)

check = 1;
while check
    prompt = {'Pseudonym:','Kondition (ON vs OFF):', 'datum [ttmmjjjj]:'};
    title = 'Bitte geben Sie das Pseudonym des Patienten, die Kondition und das heutige datum an';
    size = repmat([1,90],[3 1]);                                            % set size of entry box to 90X1
    tmp = inputdlg(prompt,title,size);                                      % get the details of the experiment and create a new folder
    
    % Add info to a new structure, from which data will be retrieved
    session = struct('psdnm', tmp{1}, 'cond', tmp{2}, ...
        'dte', str2double(tmp{3}));
    
    % Check if the folder already exists, in order to avoid losing data by
    % overwriting something
    session.name = sprintf('%s_%s_%s', session.psdnm, ...
        session.cond, num2str(session.dte));                                % core name of files that will be saved later
    folder_name = char(strcat(maindir, 'recordings/',[session.name], '/')); % name of the folder to be created
    if exist(folder_name, 'dir')       % check if the folder is present and create a new folder in case it isn't
        uiwait(msgbox({'The folder already exists.', 'Please double check, to avoid losing data'},'Warning','modal'));
    else
        try
            mkdir(folder_name);
            fprintf('\n new folder %s was created \n', folder_name)
            check = 0;
        catch
            fprintf('\n folder %s could not be created  \n', folder_name)
            check = 1;
        end
    end
end