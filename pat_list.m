function patdat = pat_list(wdir)

%   This function reads out general data that is stored in a sepoarate
%   excel file within the main folder

%   Copyright (C) November 2018
%   Max Wullstein, University Hospital of Gieﬂen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

filename = 'patientenliste_onoff.xlsx';                                     % filename defines where the information for all subjects can be found  

%% Import the data, extracting spreadsheet dates in Excel serial date format
cd(wdir)
[~, ~, raw] = ...
    xlsread(strcat(wdir, filename),'working','','',@convertSpreadsheetExcelDates);
cd(strcat(wdir, 'skripte'));
stringVectors = string(raw(2:end,[3,4,5,7,10,11,12,13]));
stringVectors(ismissing(stringVectors)) = '';

raw = raw(2:end,[1,2,6,7,8,9,14:22]);
raw(cellfun(@(x) ~isnumeric(x), raw)) = {NaN};                             % replaces empty values with NaNs

%% Create output variable
datall = reshape([raw{:}],size(raw));

%% Create table
patdat = table;

%% Allocate imported array to column variable names
patdat.no = datall(:,1);
patdat.pseud = stringVectors(:,1);
patdat.group = categorical(datall(:,2));
patdat.age = datall(:,3);
patdat.gender = categorical(stringVectors(:,4));
patdat.subtype = datall(:,5);
patdat.size = datall(:,6);
patdat.dd = datall(:,7);
patdat.hy = datall(:,8);
patdat.updrs_off = datall(:,9);
patdat.updrs_on = datall(:,10);
patdat.updrs_diff = datall(:,11);
patdat.pdq39 = datall(:,12);
patdat.demtect = datall(:,13);
patdat.ehi = datall(:,14);
patdat.ledd = datall(:,15);
