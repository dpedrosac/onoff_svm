function time = video_display(scr, mviname, time_start)

[movie, ~, ~,  ~, ~] = ...
    Screen('OpenMovie', scr.Ptr, mviname);
% Screen('SetMovieTimeIndex', movie, 0);
rate = 1;
Screen('PlayMovie', movie, rate);
time = (GetSecs() - time_start);

while (1)
    tex = Screen('GetMovieImage', scr.Ptr, movie);
    if tex <=0
        break
        
    end
    %Draw the new texture immediately to screen:
    Screen('DrawTexture', scr.Ptr, tex);
    % Update display:
    Screen('Flip', scr.Ptr);
    % Release texture:
    Screen('Close', tex);
end
% Stop playback:
Screen('PlayMovie', movie, 0);

Screen('CloseMovie', movie);
