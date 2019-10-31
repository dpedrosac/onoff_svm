function p = figure_params_gen

%   This function reads the general settings for figures throughout the 
%   script so that it is unifrom 

%   Copyright (C) August 2017
%   D. Pedrosa, University Hospital of Gieﬂen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

params = {};
params.ftname = 'Cambria';
params.ftsize = [14, 19, 24];
params.greys = {24./255*ones(1,3), 84./255*ones(1,3), 144./255*ones(1,3)};  % different grey tones for data
params.colors = {[207 68 44], [103 138 23], [255 118 95], [85 115 171], [24 47 89]};
params.colors = cellfun(@(x) x./255, params.colors, 'Un', 0);
params.lnsize = [.35, .75, 1.5];
params.symbols = {'.', 's', '^','o'};

p = params; clear params