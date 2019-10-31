function offset_plots(s, offset, tit_char)

%   This function plots all IMU and EMG data in order to detect the
%   individual offsets before cutting data into epochs.

%   Copyright (C) February 2019, modified March 2019
%   David Pedrosa, Max Wullstein, Urs Kleinholdermann, University Hospital of Gieﬂen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

idx_plots = {[1, 3, 5, 7], [9, 11, 13, 15], 2, 4, 6, 8, 10, 12, 14, 16};    % indices of the plots (not ideal but pragmatic)
for nplots = 1:size(s,2)
    figure('name', sprintf('%s, recording no %s', ...
        tit_char, num2str(nplots)));                                        % figure name
    iter = 0;
    
    correct = 1;                                                            % argment to perform a correction of the time scale or not, to ensure that EMG and IMU have the same scale
    switch correct
        case (0) % no correction
            timeIMU = s{nplots}.timeIMU;
            timeEMG = s{nplots}.timeEMG;
        case (1) % correction according to longer time series
            if s{nplots}.timeEMG(end) < s{nplots}.timeIMU(end)
                timeIMU = linspace(0,s{nplots}.timeEMG(end),length(s{nplots}.timeIMU)).';%[0:1./s{nplots}.rateIMU:s{nplots}.timeEMG(end)].';
                timeEMG = s{nplots}.timeEMG;
            else
                timeEMG = linspace(0,s{nplots}.timeIMU(end),length(s{nplots}.timeEMG)).';%[0:1./s{nplots}.rateIMU:s{nplots}.timeEMG(end)].';
                timeIMU = s{nplots}.timeIMU;    
            end            
    end
    
    idx = find(cell2mat(s{nplots}.tble(:,7)));                              % the next lines create indices of the data that will be extracted later
    lims = [300, 2];                                                        % a little bit arbitrary limits for the data
    dat_name = {s{nplots}.gyro, s{nplots}.accel};                           % data as a structure so that a loop is possible
    for sp = 1:2 % loop through both modalities: (EMG) and (IMU)
        iter = iter + 1;
        ax_imu(sp) = ...
            subplot(8,2,idx_plots{iter}, 'FontName', 'Georgia'); hold on;
        if length(timeIMU) ~= length(dat_name{sp})
          dat_name{sp} = ...
              [dat_name{sp}; nan(length(timeIMU)-length(dat_name{sp}),3)];  % earlier versions used this unprecise correction which is obselete due to the (correct) switch above 
        end
        plot(timeIMU, dat_name{sp});                                        % plot data at subplot(ax_imu)
        
        opt = 1;
        switch opt
            case (1)
                plot([1 1].*timeIMU(cell2mat(s{nplots}.tble(idx,8)))-offset(nplots), ...
                    [-1 1].*lims(sp), 'g')
                plot([1 1].*timeIMU(cell2mat(s{nplots}.tble(idx,8)))-offset(nplots)+6, ...
                    [-1 1].*lims(sp), 'r')
            case (2)
                plot([1 1].*cell2mat(s{nplots}.tble(idx,9))-offset(nplots), ...
                    [-1 1].*lims(sp), 'g')
        end
        
        for str_all = 1:size(idx,1)
            str = char(s{nplots}.tble(str_all,3));
            switch opt
                case(1)
                    text(timeIMU(cell2mat(s{nplots}.tble(str_all,8)))-offset(nplots), ...
                        .75*lims(sp), str, 'HorizontalAlignment', 'left', 'Clipping', 'on', ...
                        'FontName', 'Georgia');
                case(2)
                    text(cell2mat(s{nplots}.tble(str_all,9))-offset(nplots), ...
                        .75*lims(sp), str, 'HorizontalAlignment', 'left', 'Clipping', 'on', ...
                        'FontName', 'Georgia');
                case(3)
                    text(cell2mat(s{nplots}.tble(str_all,9))-offset(nplots), ...
                        .75*lims(sp), str, 'HorizontalAlignment', 'left', 'Clipping', 'on', ...
                        'FontName', 'Georgia');
            end
        end
        ylim([-1 1].*lims(sp))
    end
    linkaxes([ax_imu(1),ax_imu(2)],'x')                                     % links aces so that changes in the X-axis are equal in all subplots
    clear ax dat_name lims str;
    
    for kch = 1:8; dat_name{kch} = sprintf('EMG no. %s', num2str(kch)); end % loop through EMG data
    lims = ones(1,8).*2;                                                    % limits at +/-2 for all 8 channels
    for sp = 1:8 % loop through EMG channels available
        iter = iter + 1;
        ax_emg(sp) = subplot(8,2,idx_plots{iter},'FontName', 'Georgia'); hold on;

        if length(timeEMG) ~= length(s{nplots}.emg)
          s{nplots}.emg = [s{nplots}.emg; ...
              nan(length(timeEMG)-length(s{nplots}.emg),8)];   
        end

        plot(timeEMG, s{nplots}.emg(:,sp));                                 % plot EMG data at subplot (ax_emg)
        switch opt
            case (1)
                plot([1 1].*timeEMG(cell2mat(s{nplots}.tble(idx,7)))-offset(nplots), ...
                    [-1 1].*lims(sp), 'g')
            case(2)
                plot([1 1].*cell2mat(s{nplots}.tble(idx,9))-offset(nplots), ...
                    [-1 1].*lims(sp), 'g')
        end
        
        for str_all = 1:size(idx,1)
            str = char(s{nplots}.tble(str_all,3));
            switch opt
                case (1)
                    text(timeEMG(cell2mat(s{nplots}.tble(str_all,7))) -offset(nplots), ...
                        .75*lims(sp), str, 'HorizontalAlignment', 'left', ...
                        'Clipping', 'on', 'FontName', 'Georgia');
                case(2)
                    text(cell2mat(s{nplots}.tble(str_all,9))-10*200, ...
                        .75*lims(sp), str, 'HorizontalAlignment', ...
                        'left', 'Clipping', 'on', 'FontName', 'Georgia');
            end
        end
        ylim([-1 1].*lims(sp))
    end
    linkaxes([ax_imu(1), ax_imu(2), ax_emg(1),ax_emg(2),ax_emg(3), ...      % links axes so that changes in X-axis are equal at all subplots
        ax_emg(4), ax_emg(5),ax_emg(6),ax_emg(7),ax_emg(8)],'x')
    xlim([0 max([timeEMG(end), timeIMU(end)])])
    clear iter;
end