function scr = initialise()

scr.nmbr = 0;   % 0 = main screen
ListenChar(2);  % we don't want the pressed keys to appear in Matlab from this point on
HideCursor;     % hide the cursor
Priority(1);    % high priority om Windows machines

% on MACs, do not use operating system native beamposition queries (because of bugs; see Psychtoolbox website)
if (ismac() == 1)
    v = bitor(2^16, Screen('Preference','ConserveVRAM'));
    Screen('Preference','ConserveVRAM', v);
end

% set some preferences
scr.vbl = Screen('Preference', 'SkipSyncTests', 1);
scr.debug = Screen('Preference', 'VisualDebugLevel', 2);                    % do some basic debugging
scr.verbos = Screen('Preference', 'Verbosity', 1);                          % critical errors only
scr.FGCLR = [255 255 255];                                                  % foreground color = white
scr.BGCLR = [0 0 0];                                                        % background color = black

% open the window and determine size.
% [scr.Ptr, scr.Rect] = Screen('OpenWindow',scr.nmbr);
    
end