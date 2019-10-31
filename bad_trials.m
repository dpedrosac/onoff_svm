function bt = bad_trials(wdir)

%   This function extracts bad trials that are stored in a separate excel 
%   file within the main folder 

%   Copyright (C) Mai 2019
%   David Pedrosa and Max Wullstein, University Hospital of Gieﬂen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

filename = 'patientenliste_onoff.xlsx';                                     % filename defines where the information for all subjects can be found  

%% Import the data, extracting spreadsheet dates in Excel serial date format
cd(wdir)
[~, ~, raw] = ...
    xlsread(strcat(wdir, filename),'correction','','',@convertSpreadsheetExcelDates);
cd(strcat(wdir, 'skripte'));
bt = raw(2:end,[8:11, 14:17]);

