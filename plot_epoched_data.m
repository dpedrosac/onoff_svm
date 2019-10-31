function plot_epoched_data(dat, pat, pdgm, cond, num, sr, dev, yl)
%   This function plots all available epoches from a certain paradigm and
%   a condition. All subplots will be labelled with a number, so that an
%   identification is possible to exlude 'wrong' or 'bad' trials

%   inputs:
%       loaddir = directory in which data to be processed is saved
%       option  = different possibilities such as hpf, lpf, cut
%       pat     = pseudonym of subject to preprocess, or, 'all'


%   Copyright (C) April 2019
%   David Pedrosa, Max Wullstein, University Hospital of Gieﬂen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.
if nargin <8; yl=[]; end

fx_transf = @(x) x - mean(x);
pars = figure_params_gen;                                                   % load general settings for plotting data
figure(num); clf;
set( gcf, 'Color', 'White', 'Unit', 'Normalized', ...
    'Position', [0,0,1,1] ) ;

idx_row = 1:4:20;                                                           % ensures that only the first column receives a ylabel
time_vector = linspace(0, length(dat)*1/sr, length(dat));

% - Compute #rows/cols, dimensions, and positions of lower-left corners.
nCol = 4 ;
if size(dat,3) > 20; nRow = 6; elseif size(dat,3) > 16 && size(dat,3) <= 20; nRow = 5; elseif size(dat,3) < 8; nRow = 2; else; nRow = 4; end                          % settings for no. of subplots
rowH = 0.50 / nRow ;  colW = 0.7 / nCol ;
colX = 0.06 + linspace( 0, 0.96, nCol+1 ) ;  colX = colX(1:end-1) ;
rowY = 0.1 + linspace( 0.84, 0, nRow+1 ) ;  rowY = rowY(2:end) ;

all_plots = 1:size(dat,3);
% - Build subplots axes and plot data.
for dId = all_plots % loop through all avaialble data
    rowId = ceil( dId / nCol );                                             % Id of the row
    colId = dId - (rowId - 1) * nCol;                                       % Id of the column
    
    try ax_plot(dId)=axes( 'Position', [colX(colId), rowY(rowId), colW, rowH] );             % position of the row
    catch
        keyboard;
    end
    plot(time_vector, fx_transf(squeeze(dat(:,:,dId))), 'LineWidth', .2, ...
        'Color', pars.greys{2}); hold on;
    set(gca,'FontName', pars.ftname, 'FontSize', pars.ftsize(1));
    if isempty(yl); yl = get(gca, 'ylim'); end
    try
        grid on ; xlim([0 time_vector(end)]); ylim([-1.2 1.2].*abs(max(yl)));
    catch; keyboard; end
    text(0.5, yl(1)*.9, num2str(dId), 'FontName', pars.ftname, ...
        'FontSize', pars.ftsize(1)', 'FontWeight', 'Bold', ...
        'HorizontalAlignment', 'Left', 'VerticalAlignment', 'Top' ) ;
    
    if dId > nRow*nCol - nCol
        xlabel( 'Time [in sec.]' );
    end
    
    if ismember(dId, idx_row)
        ylabel( 'Amplitude [in a.u.]', 'FontSize', pars.ftsize(1) );
    end
end
linkaxes(eval([strcat('[', sprintf('ax_plot(%d),', dId(1:end-1)), sprintf('ax_plot(%d)]', dId(end)))]),'y')

% - Build title axes and title.
axes( 'Position', [0, 0.95, 1, 0.05] ) ;
set( gca, 'Color', 'None', 'XColor', 'White', 'YColor', 'White' ) ;
tit = sprintf('subj: %s, paradigm: %s, condition: %s, device: %s', pat, pdgm, cond, dev);
text( 0.5, 0, tit, 'FontName', pars.ftname, 'Interpreter', 'none', ...
    'FontSize', pars.ftsize(3)', 'FontWeight', 'Bold', ...
    'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom' ) ;