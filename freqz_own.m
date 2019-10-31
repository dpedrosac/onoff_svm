function [wn, Hdb] = freqz_own(b,a)

N = 1024; % Number of points to evaluate at
upp = pi; % Evaluate only up to fs/2
% Create the vector of angular frequencies at one more point.
% After that remove the last element (Nyquist frequency)
w = linspace(0, pi, N+1);
w(end) = [];
ze = exp(-1j*w); % Pre-compute exponent
H = polyval(b, ze)./polyval(a, ze); % Evaluate transfer function and take the amplitude
Ha = abs(H);
Hdb  = Ha;%20*log10(Ha); % Convert to dB scale
wn   = w;%w/pi;
% % Plot and set axis limits
%         xlim = ([0 1]);
%         plot(wn, Hdb)
%         grid on