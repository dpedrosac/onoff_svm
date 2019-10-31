function [openname, k] = list_recordings(wdir, fldr, cond, sess, flag, start)

%   This function provides the name of the recording from which data should
%   be extracted; inputs: 
%   wdir    - working directory
%   fldr    - folder at which data is saved
%   sess    - session name, i.e. usually 1/2 (OFF/CTRL) & 3/4 (ON)
%   flag    - when set to (0), complete data is assumed; otherwise
%               something went wrong with recording and recording_block_xx 
%               is found
%   start   - (not necessary) but if set, search for recording_block_xx
%               starts earlier than 10, e.g. when data could not be loaded
%               due to corrupted file during data_read_pd.m

%   Copyright (C) December 2018
%   David Pedrosa, Max Wullstein, Urs Kleinholdermann, University Hospital of Gieﬂen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

if nargin < 6; start = 10; end                                              % if (start) is undefined, start at 10 is assumed

if flag == 0
    openname = strcat('recording_total_', cond, '_M', num2str(sess), '.mat');      % begin with filename after all recordings
    k = 11;
else
    openname = ...
        strcat('recording_block_', num2str(start), '_', cond, '_M', ...            % begin with filename of preliminary blocks using (start) as starting point
        num2str(sess), '.mat');          
    k = start;
end

if exist(fullfile(wdir, 'recordings', char(fldr), openname), 'file')        % if inexistent, loop through further possibe possibilities
    return
else
    fprintf('recordings apparently not completed, trying to find last recording\n')
    for k = start:-1:1
        openname = strcat('recording_block_', num2str(k),'_', cond, '_M', num2str(sess), '.mat');
        if ~exist(fullfile(wdir, 'recordings', char(fldr), openname), 'file')
            continue
        else
            return
        end
    end
end