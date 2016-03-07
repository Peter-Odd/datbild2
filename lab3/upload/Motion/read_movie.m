function [movmat,fps] = read_movie(filename,startframe,endframe)

% READ MOVIE
% 
%  [movmat,fps] = read_movie(filename,startframe,endframe)
% 
%        filename: Path and filename of the movie file (see help mmreader
%                  for information on formats).
%      startframe: Starting frame
%        endframe: Final frame
%          movmat: An height*width*(endframe-startframe) uint8 matrix
%             fps: Frames per second (for mplay)
% 
% Description: read_movie reads a movie and stores the specified frame
% interval in a matlab matrix.
% 
% Written by: Gustaf Kylberg och Patrik Malm, Dec. 2010, Matlab 2009R

% Create video object
vidObj = mmreader(filename);

% Get video metadata
vidInf = mmfileinfo(filename);
vidHeight = vidObj.Height;
vidWidth = vidObj.Width;
fps = round(vidObj.FrameRate);

% Display the video information in prompt
vidObj
tmp = regexp(filename,'\.','start');
disp(['  Video Container: ' filename(tmp(end):end)]);
disp(['  Video Format: ' vidInf.Video.Format]);

% Initialize the target matrix
movmat = uint8(zeros(vidHeight, vidWidth,(endframe-startframe+1)));

% Read one frame at a time
progressbar('Loading movie...');

n = 1;
for k = startframe : endframe
    tmp = read(vidObj, k);
    movmat(:,:,n) = rgb2gray(tmp); % Convert to grayscale
    progressbar(n/(endframe-startframe+1));
    n = n + 1;
end
