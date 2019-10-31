function plot_filter_notch(datraw, datfilt, f_hpf, bpf1, bpf2, bband, aband, ahigh, bhigh, sr, wdir)

%   This function plot the results of the filter through which data is sent

%   Copyright (C) December 2018
%   Max Wullstein, University Hospital of Gieﬂen and Marburg
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

Hs1     = spectrum.welch('Hamming', sr);                       %#ok<DWELCH>
fig_directory   = [wdir 'analyses\filters\'];                   % folder at which figures will be stored if needed
font            = 'Cambria';
fontsize        = [14, 19, 24];

%% First figure
figure;
subplot(2,2,1);
spec_raw = ...
    arrayfun(@(q) psd(Hs1, datraw{q}, 'Fs', sr), ...
    1:length(datraw),'UniformOutput',false);
mean_spec_raw = ...
    arrayfun(@(x) spec_raw{x}.Data, 1:numel(spec_raw),'un',0);
semilogy(spec_raw{1}.Frequencies, ...
    nanmean(horzcat(mean_spec_raw{:}),2));
hold on;

spec_filt = ...
    arrayfun(@(q) psd(Hs1, datfilt{q}, 'Fs', sr), ...
    1:length(datfilt),'UniformOutput',false);
mean_spec_filt = ...
    arrayfun(@(x) spec_filt{x}.Data, 1:numel(spec_filt),'un',0);
mean_spec_filt = nanmean(horzcat(mean_spec_filt{:}),2);
semilogy(spec_raw{1}.Frequencies, mean_spec_filt);
ylabel({'Average power of the'; 'EMG-signal [in a.u.] log-scaled'}, ...
    'FontName', font, 'FontSize', fontsize(1), ...
    'fontweight','b');
xlabel('Frequency [in Hz.]', ...
    'FontName', font, 'FontSize', fontsize(1), ...
    'fontweight','b');
xlim([0 100]);
ylim('auto');
set(gca,'FontName',font,'FontSize',fontsize(1));
set(gca,'XMinorTick','off','YMinorTick','off');
set(gca,'XGrid','on','YGrid','on');
set(gca,'GridLineStyle',':', 'LineWidth', 0.2);
legend({'Raw signal';'Preprocessed EMG'}) % this is a cell array!

subplot(2,2,2);
[h1, w1] = freqz(bhigh, ahigh);
[h2, w2] = freqz(bband, aband);
[ax, ~, ~] = ...
    plotyy(w1/pi*sr/2, abs(h1), w2/pi*sr/2, abs(h2));
set(get(ax(1),'Ylabel'), 'String', ...
    {'Response of the high-pass filter'}, ...
    'FontName', font, 'FontSize', fontsize(1), ...
    'fontweight','b');
set(get(ax(2),'Ylabel'), 'String', ...
    {'Response of the bandpass filter'}, ...
    'FontName', font, 'FontSize', fontsize(1), ...
    'fontweight','b');

set(ax(1),'YTick',[.5 1 1.5]);
set(ax(2),'YTick',[.5 1 1.5]);
xlabel('Frequency [in Hz]', ...
    'FontName', font, 'FontSize', fontsize(1), ...
    'fontweight','b');
ylim(ax(1), [0 1.5]); ylim(ax(2), [0 1.5]);
xlim(ax(1), [0 50]); xlim(ax(2), [0 50]);

set(gca,'FontName',font,'FontSize',fontsize(1));
set(gca,'XMinorTick','off','YMinorTick','off');
set(gca,'XGrid','on','YGrid','on');
set(gca,'GridLineStyle',':', 'LineWidth', 0.2);
legend({strcat(num2str(f_hpf), 'Hz high-pass filter'); ...
    strcat(num2str(bpf1), '-', ...
    num2str(bpf2), 'Hz bandpass filter')}) % this is a cell array!
box('off');

subplot(2,2,4);
[ax, ~, ~] = ...
    plotyy(w1/pi*sr/2, abs(h1), w2/pi*sr/2, abs(h2));

set(ax(1),'YTick',[.5 1 1.5]);
set(ax(2),'YTick',[.5 1 1.5]);
for i = 1:2
    ylim(ax(i), [0 1.5]);
    xlim(ax(i), [0 45]);
end

set(gca,'XMinorTick','off','YMinorTick','off');
set(gca,'XGrid','on','YGrid','on');
set(gca,'GridLineStyle',':', 'LineWidth', 0.2);
box('off');

% supertitle('Summary of the EMG preprocessing', ...
%     'FontName', font, 'FontSize',fontsize(3),'Color','k');
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 30 20])
% fig_name = strcat(fig_directory, 'subj', num2str(np), ...
%     filename(end-10), '_EMG.tif');
% print('-dtiff', fig_name, '-r300');
% %             savefig(gcf,strcat(fig_name(1:end-3), 'fig'));
% close(gcf);
end
