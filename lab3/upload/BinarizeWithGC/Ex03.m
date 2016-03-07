clear all; close all;

%####################### MACROS ##########################

InputDir     = dir('./DIBCO');
addpath('./DIBCO');
ClstDataDir  = './Clusters';
addpath('./Clusters');

OutDir = './SourceSink';

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
    
    iim   = imread(char(Input(f)));

    if(size((size(iim)),2) == 3);
        img  = double(rgb2gray(iim));
    else
        img  = double(iim);
    end
    
    clustData = strcat(num2str(f),'.clust');
    [im, in]  = size(img(1:end-1,1:end-1));
    
    if (exist(clustData,'file'))
        load(clustData,'-mat','p2cl');
        numClust = max(p2cl);
        clMembsCell = [];
        for cN = 1:numClust
            myMembers = numel(find(p2cl == cN));
            clMembsCell = [clMembsCell; myMembers];
        end
        [val, idx] = max(clMembsCell);
    else
         print('Error: Cluster file not found \n');
    end
    
    sr  = 23.2084;
    ct  = [5.2742e-004 0.3899];

    eimg = edge(img,'canny',ct);
    dx   = img(1:end-1,2:end)-img(1:end-1,1:end-1);
    dy   = img(2:end,1:end-1)-img(1:end-1,1:end-1);
    dvr  = divergence(dx,dy);

    img2 = (img-gsmooth(img,sr,3*sr,'mirror'));
    rms = sqrt(gsmooth(img2.^2,sr));
    himask = (img2./(rms+eps)>2);
    dvr(himask(1:end-1,1:end-1)) = -500;

    dvr1 = dvr;
    Hfe = 2;
    wgt = 25;
    dvr1(reshape((p2cl == idx),im,in)) = -( 1/3 * Hfe);
    
    hc = ~((eimg(1:end-1,1:end-1)&(dy>0))|(eimg(2:end,1:end-1)&(dy<=0)));
    vc = ~((eimg(1:end-1,1:end-1)&(dx>0))|(eimg(1:end-1,2:end)&(dx<=0)));
    hc = hc(1:end-1,:);
    vc = vc(:,1:end-1);

    bimg = logical(imgcut(Hfe-dvr1,Hfe+dvr1,wgt.*hc,wgt.*vc));
    bimg = bimg([1:end end],[1:end end]);
    
    eimg = NormalizeEdgeMap(eimg, eimg&bimg);
    
    wgt = 122.1634;

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
    bimg = ~bimg;
    
    oldFolder = cd(OutDir);
    
    oFile     = strcat(num2str(f),'_SourceSink.png');
    
    imwrite(bimg, oFile);
    
    cd(oldFolder);
end
