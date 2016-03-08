% Extract images from video file
% videoFile = path to video file.
% startSecond = where to start image extractions in videoFile.
% secondsWanted = # of seconds to extract from videoFile.
% returns a 1D cell with extracted images.
function images = extractImages(videoFile, startSecond, framesWanted)
    v = VideoReader(videoFile);
    v.CurrentTime = 1;
    i = 1;
    %images = cell(1, secondsWanted * 25);
    while hasFrame(v) && i <= framesWanted
        %images{i} = readFrame(v);
        imwrite(readFrame(v),[sprintf('output/image-%03d',i) '.jpg']);
        i = i + 1;
    end 
end