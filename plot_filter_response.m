function plot_filter_response(sr, n, b, a, freq, type)

%   This function plots the filter response of the filtre applied to the
%   There are tweo options available, either HPF or BPF of the data

%   Copyright (C) May 2019
%   David Pedrosa, Max Wullstein, University Hospital of Gieﬂen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

figure(n); hold on; par = figure_params_gen;                                % creates a figure and loads general plotting routines intow workspace

switch type
    case ('high')
        [w1, h1] = freqz_own(b, a);
        plot(w1/pi*sr/2, h1);
        
        plot([freq freq], [0.2 1.3], '--r', 'Linewidth', par.lnsize(3))
        set(gca,'FontName',par.ftname,'FontSize',par.ftsize(1), ...
            'XMinorTick','off','YMinorTick','off', 'XGrid','on','YGrid','on', ...
            'GridLineStyle',':', 'LineWidth', 0.2);
        
        ylabel('Response of the high-pass filter', ...
            'FontName', par.ftname, 'FontSize', par.ftsize(1), ...
            'fontweight','b');
        xlabel('Frequency [in Hz]', 'FontName', par.ftname, ...
            'FontSize', par.ftsize(1), 'fontweight','b');
        ylim([0 1.5]); xlim([0 5*freq]);
        
        legend({strcat(num2str(freq), 'Hz high-pass filter')}, ...
            'FontName',par.ftname,'FontSize',par.ftsize(1)) % this is a cell array!
        box('off');
        
    case ('band')
        [w2, h2] = freqz_own(b, a);
        plot(w2/pi*sr/2, h2);

        plot([freq(1) freq(1)], [0.2 1.3], '--r', 'Linewidth', par.lnsize(3))
        plot([freq(2) freq(2)], [0.2 1.3], '--r', 'Linewidth', par.lnsize(3))
        
        set(gca,'FontName',par.ftname,'FontSize',par.ftsize(1), ...
            'XMinorTick','off','YMinorTick','off', 'XGrid','on','YGrid','on', ...
            'GridLineStyle',':', 'LineWidth', 0.2);
        
        ylabel(sprintf('Response of the band-pass filter between %s and %s Hz', num2str(freq(1)), num2str(freq(2))), ...
            'FontName', par.ftname, 'FontSize', par.ftsize(1), ...
            'fontweight','b');
        xlabel('Frequency [in Hz]', 'FontName', par.ftname, ...
            'FontSize', par.ftsize(1), 'fontweight','b');
        ylim([0 1.5]); xlim([0 1.5*freq(2)]);
        
        legend({sprintf('%s - %s Hz bandpass filter', num2str(freq(1)), num2str(freq(2)))}) % this is a cell array!
        box('off');
    otherwise
        fprintf('this type is not available, plotting impossible \n')
        
end