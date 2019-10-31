function time = draw_cross(scr, fixCrossDimPix, LineWidthPix, color, dur, time_start)

% Settings:
%   - scr               - Screen-object to which the crosses will be added
%   - fixCrossDimPix    - cross widh
%   - lineWidth         - line width of the cross
%   - color             - color of the cross
%   - dur               - duration, that is the time the cross will be displayed


% blank screen and wait a second

Screen('FillRect',scr.Ptr,scr.BGCLR);
Screen('Flip',scr.Ptr);
if nargin < 5 && nargin > 1
    fixCrossDimPix = 60;
    lineWidthPix = 10;
    color = [255 0 0];
    dur = 2;
elseif nargin <1
    fprintf('\n a "Screen object from the PSychtoolbox MUST be provided\n');
    return
end

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

Screen('Flip',scr.Ptr);
Screen('DrawLines', scr.Ptr, allCoords, LineWidthPix, color, ...
    [scr.xc scr.yc],2);
time = (GetSecs() - time_start);
Screen('Flip',scr.Ptr)
WaitSecs(dur)
