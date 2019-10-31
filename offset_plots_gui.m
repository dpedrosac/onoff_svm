function offset_plots_gui(s, offset, tit_char)

%   This function plots all IMU and EMG data in order to detect the
%   individual offsets before cutting data into epochs.

%   Copyright (C) February 2019
%   David Pedrosa, Max Wullstein, Urs Kleinholdermann, University Hospital of Gieﬂen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.
if nargin <4
    dur = 15;
end

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MovePlottedData_OpeningFcn, ...
                   'gui_OutputFcn',  @MovePlottedData_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);

idx_plots = {[1, 3, 5, 7], [9, 11, 13, 15], 2, 4, 6, 8, 10, 12, 14, 16};
for nplots = 1:size(s,2)
    figure('name', sprintf('%s, recording no %s', tit_char, num2str(nplots))); % plot IMU components
    iter = 0;
    
    idx = find(cell2mat(s{nplots}.tble(:,7)));                    % the next lines create indices of the data that will be extracted later
    dat_name = {s{nplots}.gyro, s{nplots}.accel};
    lims = [300, 2];
    for sp = 1:2
        iter = iter + 1;
        ax_imu(sp) = subplot(8,2,idx_plots{iter}, 'FontName', 'Georgia'); hold on;
        plot(s{nplots}.timeIMU, dat_name{sp});
        
        opt = 1;
        switch opt
            case (1)
                gr = plot([1 1].*s{nplots}.timeIMU(cell2mat(s{nplots}.tble(idx,8)))-offset(nplots), ...
                    [-1 1].*lims(sp), 'g');
                rd = plot([1 1].*s{nplots}.timeIMU(cell2mat(s{nplots}.tble(idx,8)))-offset(nplots)+6, ...
                    [-1 1].*lims(sp), 'r');               
            case (2)    
                plot([1 1].*cell2mat(s{nplots}.tble(idx,9))-offset(nplots), ...
                    [-1 1].*lims(sp), 'g')
        end
        
        for str_all = 1:size(idx,1)
            str = char(s{nplots}.tble(str_all,3));
            switch opt
                case(1)
                    text(s{nplots}.timeIMU(cell2mat(s{nplots}.tble(str_all,8)))-offset(nplots), ...
                        .75*lims(sp), str, 'HorizontalAlignment', 'left', 'Clipping', 'on', ...
                        'FontName', 'Georgia');
                case(2)
                    text(cell2mat(s{nplots}.tble(str_all,9))-offset(nplots), ...
                        .75*lims(sp), str, 'HorizontalAlignment', 'left', 'Clipping', 'on', ...
                        'FontName', 'Georgia');
            end
        end
        ylim([-1 1].*lims(sp))
    end
    linkaxes([ax_imu(1),ax_imu(2)],'x')
    clear ax dat_name lims str;
    
    %     figure(200-nplots); % plot EMG channels
    for kch = 1:8; dat_name{kch} = sprintf('EMG no. %s', num2str(kch)); end
    lims = ones(1,8).*2;
    for sp = 1:8
        iter = iter + 1;
        ax_emg(sp) = subplot(8,2,idx_plots{iter},'FontName', 'Georgia'); hold on;
        
        %         ax_emg(sp) = subplot(8,1,sp); hold on;
        plot(s{nplots}.timeEMG, s{nplots}.emg(:,sp));
        switch opt
            case (1)
                plot([1 1].*s{nplots}.timeEMG(cell2mat(s{nplots}.tble(idx,7)))-offset(nplots), ...
                    [-1 1].*lims(sp), 'g')
%                 plot([1 1].*s{nplots}.timeIMU(cell2mat(s{nplots}.tble(idx,8)))-offset(nplots)+6, ...
%                     [-1 1].*lims(sp), 'r')                
            case(2)
                
                plot([1 1].*cell2mat(s{nplots}.tble(idx,9))-offset(nplots), ...
                    [-1 1].*lims(sp), 'g')
                
        end
        for str_all = 1:size(idx,1)
            str = char(s{nplots}.tble(str_all,3));
            switch opt
                case (1)
                    text(s{nplots}.timeEMG(cell2mat(s{nplots}.tble(str_all,7))) -offset(nplots), ...
                        .75*lims(sp), str, 'HorizontalAlignment', 'left', 'Clipping', 'on', ...
                        'FontName', 'Georgia');
                case(2)
                    text(cell2mat(s{nplots}.tble(str_all,9))-10*200, ...
                        .75*lims(sp), str, 'HorizontalAlignment', 'left', 'Clipping', 'on', ...
                        'FontName', 'Georgia');
                    
            end
        end
        ylim([-1 1].*lims(sp))
    end
    linkaxes([ax_imu(1), ax_imu(2), ax_emg(1),ax_emg(2),ax_emg(3),ax_emg(4), ...
        ax_emg(5),ax_emg(6),ax_emg(7),ax_emg(8)],'x')
    xlim([0 max([s{nplots}.timeEMG(end), s{nplots}.timeIMU(end)])])
    clear iter;
end
