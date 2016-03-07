% Call this function with the file name of the source image and the
% file name for the output image.
clear all; close all;
%####################### MACROS ##########################
InputDir  = dir('./DIBCO');
addpath('./DIBCO');

OutDir = './Otsu';

if (~exist(OutDir,'dir'))
    mkdir(OutDir);
end

x={};
for i = 1:size(InputDir,1)
    x = [x; InputDir(i).name];
end
InputDir = x(3:end);

Input  = InputDir;

%####################### ENTER MAIN ##########################
for f = 1:size(Input)
    
    iim   = imread(char(Input(f)));
    level = graythresh(iim);
    BW    = im2bw(iim,level);
    
    oldFolder = cd(OutDir);
    oFile     = strcat(num2str(f),'_Otsu.png');
    
    imwrite(BW, oFile);
    
    cd(oldFolder);
end
