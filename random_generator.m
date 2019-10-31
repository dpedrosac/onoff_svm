function rdm_order = ...
    random_generator(flag_check, cond, dur_tr, dur_rest, nrep, nrest, no_rand)

%   This function creates a random order. It may be used in two ways:
%   1)  the first way is to create a set of random which may be plotted. 
%       Therefore, either only the flag_check should be set to one or, 
%       alternatively, the settings should be made additionally. 
%   2) the second way to use it is to set no_rand to one and all other
%       input arguments should be set as desired


%   Copyright (C) February 2018
%   D. Pedrosa, University Hospital of Gieﬂen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.



% General settings
% addpath('C:\onoff_svm\skripte\othercolor')


if nargin < 2
    %% general settings
    cond        = 4;                                                            % conditions, including the rest condition
    dur_tr      = 4.5;                                                          % duration of the motor trials [in seconds]
    dur_rest    = 25;                                                           % duration of the rest condition [in seconds]
    nrep        = 18;                                                           % no. of repetitions (except the rest condition)
    nrest       = 6;                                                            % no od rest trials
    no_rand     = 3;                                                            % (fictive) subjects to simulate
end

test_no     = [];
for l = 1:cond-1                                                            % the for-loop andn the following line result in a
    test_no = [test_no, ones(1,nrep)*l];                                    % vector of conditions in ascending order
end
test_no = [test_no, ones(1,nrest)*cond];                                    % vector of conditions in ascending order

rng('shuffle')
rdm_order = nan(no_rand, length(test_no));                                  % pre-allocates space
for l = 1:no_rand   % loop through the number of (fictive) subjects to simulate
    rdm_order(l,:) = test_no(randperm(length(test_no)));
end

if flag_check ==1 % if flag_check == 1, results are plotted
    figure(1); hold on;                                                     % create figure to plot data in
    for fig = 1:no_rand % loop through (fictive) subjects
        subplot(1,no_rand, fig)                                             % create a subplot for every (fictive) subject
        Tx = linspace(1.5,size(rdm_order,2)/cond-.5, ...
            [size(rdm_order,2)/cond]-1);                                    % XTicks with linear distances
        Ty = linspace(.5,3.5,cond);                                         % YTicks with linear distances
        matrix_rdm_order = reshape(rdm_order(fig,:), ...                    % this reshapes the vecor into a matrix of (cond) columns and (nrep) rows
            [cond, size(rdm_order,2)/cond]).';
        imagesc(matrix_rdm_order);                                          % plot matrix at subplot (fig)
        colormap(othercolor('Paired12',cond))                               % change colormap
        set(gca,'YDir','normal', 'YTick', Ty, 'XTick', Tx, ...              % adapts the figure properties
            'YTickLabel', [], 'XTickLabel', []); grid on; axis image;
        
        xlabel(sprintf('subj #%s', num2str(fig)), 'FontName', 'Cambria', ...
            'FontSize', 14);
        for m = 1:size(matrix_rdm_order,2) % this loop adds the condition on top of imagesc
            for n = 1:size(matrix_rdm_order,1)
                text(m-.1,n, num2str(matrix_rdm_order(n,m)), ...
                    'FontName', 'Cambria', 'FontSize', 12)
            end
        end
    end
end

% the next few lines intend to provide information about the duration of
% the task in order to able to evaluate how exhausting it may be. ONe trial
% consists of a presnetation of the task that is supposed to be made, a
% variable time in which subjects watch a red cross, the green cross, at
% which the trial should be perdormed and a second red cross, at which
% subjects are intended to relax the arm again

if flag_check == 1
    pres        = 1.5;                                                          % duration of presentation of task
    red_screen  = [mean([1.3, 1.8]), 1.5];                                      % duration of the respective red screens
    dur_tr_tot  = pres + red_screen(1) + dur_tr + red_screen(2);                % duration of one trial
    tot_time    = [nrest*dur_rest + (cond-1)*dur_tr_tot*nrep;]/60;              % total duration
    task_time = [nrest*dur_rest + (cond-1)*dur_tr*nrep;]/60;                    % duration of all motor trials
    fprintf('\nThe total duration of the experiment would be %s min.', num2str(tot_time));
    fprintf('\nThe duration of the motor tasks would be %s min.', num2str(task_time));
end
end