function time = draw_text(scr, TextSize, FontName, txt, locx, locy, color, dur, time_start)
% Settings:
%   - scr               - Screen-object to which the crosses will be added
%   - TextSize          - Size of the text
%   - txt               - Text to display
%   - locx/-y           - locyation of the text on the x- amd y-axis
%   - color             - color of the text
%   - dur               - duration, that is the time the textwill be
%                       displayed; may be set to forever to waiti until
%                       e.g key is pressed

if nargin < 4 && nargin > 1
    TextSize = 45;
    FontName = 'Cambria';
    txt = 'WTF?';
    color = [255 255 255];
    dur = 2;
    locx = 'center';
    locy = 'center';
    
elseif nargin <1
    fprintf('\n a "Screen object from the Psychtoolbox MUST be provided\n');
    return
end

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)

Screen('Flip',scr.Ptr);
Screen('TextSize', scr.Ptr, TextSize);
Screen('TextFont', scr.Ptr, FontName);
DrawFormattedText(scr.Ptr, txt, locx, locy, color);
Screen('Flip',scr.Ptr)
time = (GetSecs() - time_start);
if strcmp(dur, 'forever')
    return
else
    WaitSecs(dur)
end