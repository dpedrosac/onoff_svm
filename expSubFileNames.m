function [SubFiles]=expSubFileNames(Sub,Task,Trial)
%Generates filenames for all files of subject (Sub) and Trial.
%If only Sub is specified, returns those files which are relevant
%for the subject independent of the Trial.

%Handle input:
if nargin<2
    error('You must specify at least two arguments')
elseif nargin==2
    TrialNames=false;
elseif nargin==3
    TrialNames=true;
    if ischar(Trial) Sub=str2double(Trial); end
else
    error('More than three argument not allowed')
end

% if ischar(Sub) ; Sub=str2double(Sub); end
% % this part was removed as pseudonyms are intended which do not
% necessarily need to be numeric

epar = expSettings;                                                         % load the task specific parameters to the workspace
if any(~cellfun(@ischar, epar.tasks))                                       % all tasks should be characters
    error('All tasks must be string, check expSettings.m');
end

%Subject and task specific paths (each task gets its own subdirectory):
%Note that this results in a number of filenames which are never used.
%But this doesn't hurt...
SubFiles.SubRootDir = ['./data/', Sub];
for k = 1:epar.ntasks
    SubFiles.SubDir(k)     = ['./data/',Sub,'/',Task];
%Subject and task specific files:
SubFiles.StatusFile(k)      = [SubFiles.SubDir,'/expstatus.mat'];
SubFiles.PosFile(k)         = [SubFiles.SubDir,'/positions.mat'];
SubFiles.FingerRigFile(k)   = [SubFiles.SubDir,'/finger'];
SubFiles.ThumbRigFile(k)    = [SubFiles.SubDir,'/thumb'];
SubFiles.Perc(k)            = [SubFiles.SubDir,'/',epar.ExpName,'_perc.', Sub];
SubFiles.Ap(k)              = [SubFiles.SubDir,'/',epar.ExpName,'_ap.', Sub];

%Trial specific files:
if TrialNames
    SubFiles.RawFile   =[SubFiles.SubDir,'/',epar.ExpName,'_raw.'  ,subnos(Sub),'.',subnos(Trial)];
    SubFiles.PC3DFile  =[SubFiles.SubDir,'/',epar.ExpName,'_PC3D.' ,subnos(Sub),'.',subnos(Trial)];
    SubFiles.MatFile   =[SubFiles.SubDir,'/',epar.ExpName,'_MAT3D.',subnos(Sub),'.',subnos(Trial)];
    SubFiles.GraspTime =[SubFiles.SubDir,'/',epar.ExpName,'_grasptime.',subnos(Sub),'.',subnos(Trial)];
    SubFiles.FingerRigSingleTrialBackup =[SubFiles.FingerRigFile,'.rig.',subnos(Trial)];
    SubFiles.ThumbRigSingleTrialBackup  =[SubFiles.ThumbRigFile ,'.rig.',subnos(Trial)];
end

