% Have to provide map of source and sinks, and weight of edges
% algorithm does: find the optimum, min-cut and max-flow.
% The algorithm removes 'edges' and that is the segmentation.
% Sink does not have to be connected.

% Have to build a graph and decide what is sink and source.
% Eliminate hor/ver edge, penalty should be the same (for edges in a
% graph) ??

% 'Pixels' = nodes, contours will become edges with canny



% After calculating derivates, calculate graph edges
% Every pixel becomes a node, have to be connected horizontally and
% vertically, dont want all to be connected. Those with derivative along x
% and y will be connected (with the help of canny) (?). Thus, only
% preserving peak edges.

% Divergence map used to get source and sink.


% Call this function with the file name of the source image and the
% file name for the output image.
clear all; %close all;
%InputDir  = dir('./DIBCO');
%addpath('./DIBCO');
InputDir  = dir('./SetSourceSink');
addpath('./SetSourceSink');


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
for f = 1:1%size(Input)
    
    wgt = 122.1634;
    sr = 23.2084;
    ct = [5.2742e-004 0.3899];
    %ct = [75/255 77/255];
    
    iim   = imread(char(Input(1)));
    
    if (size(iim,3)==3)
        img = rgb2gray(iim);
    end;
    
    %red_img = iim(:,:,1);
    %red_img(red_img~=255) = 0;
    eimg = edge(img(),'canny',ct);
    %size(eimg)
 
    if isa(img,'uint8')
        img = double(img);
    else
        img = 255.*img; % numbers are set for 255 scale
    end;
    figure;
    subplot(2,2,1);
    imshow(eimg);
    title('canny');
    dx = img(1:end-1,2:end)-img(1:end-1,1:end-1);
    dy = img(2:end,1:end-1)-img(1:end-1,1:end-1);
    dvr = divergence(dx,dy);
    
    img2 = (img-gsmooth(img,sr,3*sr,'mirror')); % Gaussian smooth

    
    rms = sqrt(gsmooth(img2.^2,sr)); % root mean square
    himask = (img2./(rms+eps)>2);
    for(x = 1:2)
    if(x == 1) 
        himask = himask | (iim(:,:,1) > 200); %red
    else
        himask = himask | (iim(:,:,3) > 200); %blue
    end
    dvr(himask(1:end-1,1:end-1)) = -500;
 
% first run, only find edges with canny (true image contours)
    hc = ~((eimg(1:end-1,1:end-1)&(dy>0))|(eimg(2:end,1:end-1)&(dy<=0))); % Horizontal component (graph edges)
    vc = ~((eimg(1:end-1,1:end-1)&(dx>0))|(eimg(1:end-1,2:end)&(dx<=0))); % Vertical graph edges (preserve only those who have difference in 
    hc = hc(1:end-1,:);
    vc = vc(:,1:end-1);
   
   %old
   source = 1500-dvr;
   sink = 1500+dvr;
   
   subplot(2,2,2)
   imshow(source/2000);
   title('source');
   subplot(2,2,3);
   imshow(sink/2000);
   title('sink');
   
   
   %source = 1500+dvr;
   %sink = 1500-dvr;
   
   
    bimg = logical(imgcut(source,sink,wgt.*hc,wgt.*vc)); % 3,4th arguments = weights for vertical and horizontal
    bimg = bimg([1:end end],[1:end end]);

    
% here, thresholds are more forgiving, more thresholds, 
% only take those you found with the segmentation in 
% second run, which makes it finer, (will get all edges).    
    % refine edge map by adding faint edges within detected foreground
    eimg2 = edge(img,'canny',0);
    eimg = eimg|(eimg2&bimg);
    
    hc = ~((eimg(1:end-1,1:end-1)&(dy>0))|(eimg(2:end,1:end-1)&(dy<=0)));
    vc = ~((eimg(1:end-1,1:end-1)&(dx>0))|(eimg(1:end-1,2:end)&(dx<=0)));
    hc = hc(1:end-1,:);
    vc = vc(:,1:end-1);

    
    % redo binarization
    bimg = logical(imgcut(source,sink,wgt.*hc,wgt.*vc));
 


    bimg = bimg([1:end end],[1:end end]);

    
    nw = bimg&~bimg([1 1:end-1],:)&~bimg(:,[1 1:end-1]);

    bimg = bimg&~nw;
   
    bimg = ~bimg;  % match DIBCO sign convention

    oldFolder = cd(OutDir);
    oFile     = strcat(num2str(f),'_GCut.png');
    
    imwrite(bimg, oFile);
    subplot(2,2,4);
    imshow(bimg);
    title('Final image');
    cd(oldFolder);
    end
end
