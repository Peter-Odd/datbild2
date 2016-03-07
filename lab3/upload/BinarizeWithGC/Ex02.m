% Call this function with the file name of the source image and the
% file name for the output image.
clear all; close all;
InputDir  = dir('./DIBCO');
addpath('./DIBCO');
OutDir = './GCuts';

if (~exist(OutDir,'dir'))
    mkdir(OutDir);
end


%####################### MACROS ##########################
x={};
for i = 1:size(InputDir,1)
    x = [x; InputDir(i).name];
end
InputDir = x(3:end);

Input  = InputDir;

%####################### ENTER MAIN ##########################
for f = 1:size(Input)

    wgt = 122.1634;
    sr = 23.2084;
    ct = [5.2742e-004 0.3899];
    
    iim   = imread(char(Input(f)));
    
    if (size(iim,3)==3)
        img = rgb2gray(iim);
    end;

    eimg = edge(img,'canny',ct);
    if isa(img,'uint8')
        img = double(img);
    else
        img = 255.*img; % numbers are set for 255 scale
    end;

    dx = img(1:end-1,2:end)-img(1:end-1,1:end-1);
    dy = img(2:end,1:end-1)-img(1:end-1,1:end-1);
    dvr = divergence(dx,dy);

    img2 = (img-gsmooth(img,sr,3*sr,'mirror'));
    rms = sqrt(gsmooth(img2.^2,sr));
    himask = (img2./(rms+eps)>2);
    
    dvr(himask(1:end-1,1:end-1)) = -500;

    hc = ~((eimg(1:end-1,1:end-1)&(dy>0))|(eimg(2:end,1:end-1)&(dy<=0)));
    vc = ~((eimg(1:end-1,1:end-1)&(dx>0))|(eimg(1:end-1,2:end)&(dx<=0)));
    hc = hc(1:end-1,:);
    vc = vc(:,1:end-1);

    bimg = logical(imgcut(1500-dvr,1500+dvr,wgt.*hc,wgt.*vc));
    bimg = bimg([1:end end],[1:end end]);

    % refine edge map by adding faint edges within detected foreground
    eimg2 = edge(img,'canny',0);
    eimg = eimg|(eimg2&bimg);

    hc = ~((eimg(1:end-1,1:end-1)&(dy>0))|(eimg(2:end,1:end-1)&(dy<=0)));
    vc = ~((eimg(1:end-1,1:end-1)&(dx>0))|(eimg(1:end-1,2:end)&(dx<=0)));
    hc = hc(1:end-1,:);
    vc = vc(:,1:end-1);

    % redo binarization
    bimg = logical(imgcut(1500-dvr,1500+dvr,wgt.*hc,wgt.*vc));
    bimg = bimg([1:end end],[1:end end]);
    
    nw = bimg&~bimg([1 1:end-1],:)&~bimg(:,[1 1:end-1]);
    bimg = bimg&~nw;
    bimg = ~bimg;  % match DIBCO sign convention

    oldFolder = cd(OutDir);
    oFile     = strcat(num2str(f),'_GCut.png');
    
    imwrite(bimg, oFile);
    
    cd(oldFolder);
end
