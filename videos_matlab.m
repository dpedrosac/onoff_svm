function videos_matlab(movie_name)

% movie_names = {'posture_short.v1.4.mov', 'tapping_short.v1.4.mov', ...    % name of the (short) videos that intend to explain what subjects need to do
%     'diadochokinesia_short.v1.4.mov', 'rest_short.v1.4.mov'};
% matlab.video.read.UseHardwareAcceleration('Off');
set(0,'DefaultFigureMenu','none');
iptsetpref('ImshowBorder','tight');
videoSrc = VideoReader(movie_name);                                         % name of the file to be used
videoSrc.CurrentTime = .5;
hFig = figure('Color', zeros(1,3), 'Renderer', 'OpenGL');
WindowAPI(hFig, 'topmost');
WindowAPI(hFig, 'maximize');
WindowAPI(hFig, 'OuterPosition', 'work')
WindowAPI(hFig, 'Button', false);
WindowAPI(hFig, 'Enable', 0);
axes('Visible', 'off', 'Units', 'normalized');

type = 2;
switch type
    case (1)
        nFrames = floor(videoSrc.Duration * videoSrc.FrameRate);                    % number of frames in order to display the entire video
        for i = 1:nFrames
            img = readFrame(videoSrc); imshow(img); drawnow                            % "plotting videos" as frame x frame
        end
        
    case (2)
        vidHeight = videoSrc.Height;
        vidWidth = videoSrc.Width;
        s = struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'), 'colormap', []);
        
        k = 1;
        while hasFrame(videoSrc)
            s(k).cdata = readFrame(videoSrc);
            k = k+1;
        end 
        movie(s,1,videoSrc.FrameRate);
end
close(hFig)                                                                 % close the figure