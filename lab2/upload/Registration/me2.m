% DEMO - Chamfer matching
% 
% Written by: Lu Ping & sh

close all

%%
%  image1_original=imread('01.png');
%  image2_original=imread('02.png');
%  image3_original=imread('03.png');

image1_original1=imread('01.png');
image2_original2=imread('02.png');
image3_original3=imread('03.png');

I1_thresholded = (image1_original1(:,:,1) == 255 & ...
                  image1_original1(:,:,2) == 255 & ...
                  image1_original1(:,:,3) == 0); %|  ...
%                  (image1_original1(:,:,1) == 254 & ...
%                   image1_original1(:,:,2) == 254 & ...
%                   image1_original1(:,:,3) == 253);

% figure;imshow(I1_thresholded,[])             

I2_thresholded = (image2_original2(:,:,1) == 255 & ...
                  image2_original2(:,:,2) == 246 & ...
                  image2_original2(:,:,3) == 77); %|  ...
%                  (image2_original2(:,:,1) == 255 & ...
%                   image2_original2(:,:,2) == 255 & ...
%                   image2_original2(:,:,3) == 255);

% figure;imshow(I2_thresholded,[])

I3_thresholded = (image3_original3(:,:,1) == 255 & ...
                  image3_original3(:,:,2) == 255 & ...
                  image3_original3(:,:,3) == 255);

% figure;imshow(I3_thresholded,[])   

% image1_edge=
% image2_edge=
% image3_edge=

% orig_size = size(image1_original1);
% new_size = [200 200];
% sf = orig_size(1:2)./new_size;
% image1_original = imresize(image1_original1,new_size,'bilinear');
% image2_original = imresize(image2_original2,new_size,'bilinear');
% image3_original= imresize(image3_original3,new_size,'bilinear');


%% convert to gray image
% image1=rgb2gray(image1_original);
% image2=rgb2gray(image2_original);
% image3=rgb2gray(image3_original);

%% canny edge detection
%set parameters
% t1=0.05;
% t2=0.08;
% sigma=0.8;

% image1=medfilt2(image1,[5 5]);%remove noise
% image2=medfilt2(image2,[5 5]);

% image1_edge=edge(image1,'canny',[t1 t2],sigma);
% image2_edge=edge(image2,'canny',[t1 t2],sigma);
%  image3_edge=edge(image3,'canny',[t1 t2],sigma); 
% 
% image1_edge=edge(image1,'canny',[t1 0.4],1);
% image2_edge=edge(image2,'canny',[t1 t2],1.2);
% image3_edge=edge(image3,'canny',[t1 t2],sigma); 


%% Calculate the distance transform of the original edge image (the base)

base = bwdist(I1_thresholded,'euclidean');
figure,imshow(base,[]);title('Base image')

floating_b=I2_thresholded;
% figure,imshow(floating);title('floating');
% floating_b = image2_edge - image2_edge;
%  floating_b(100:end,100:end) = image2_edge(1:end-100+1,1:end-100+1);
% floating_b(60:end,60:end) = image2_edge(1:end-60+1,1:end-60+1);

figure,imshow(floating_b,[]);
title('Floating image1');

floating_c = I3_thresholded;
% floating_c = image3_edge - image3_edge;
% floating_c(100:end,100:end) = image3_edge(1:end-100+1,1:end-100+1);
figure,imshow(floating_c,[]);
title('Floating image2');

%% Specify the directions that will be used for

 step = 5;
angle_interval = -16:4:16;
% step =4;
% angle_interval = 0:2:8;
translation_directions = [-0    -step;
                           -step  0 ;     
                           0     step;
                            step  0  ];

%% Finally do the chamermatching

last_score = inf; % Keep track of last positional score
stop = false; % Stop criterion
backwards = 0; % The direction which we came from
accumulated_scores = []; % For plotting reasons
counter = 1;

oldDir = -1;
trans_image2=image2_original;

while ~stop
    
    tmp_image1 = floating_b; % Start with the current position
    scores = zeros(size(translation_directions,1),size(angle_interval,2)); % To save the scores
   
    %  for i = 1 : size(translation_directions,1)
    %progressbar('deg','row','col');
    
    for x = 1:size(angle_interval,2)
        % Translate the image
        tmp_image1 = imrotate(floating_b,angle_interval(x),'nearest','crop');
  
        for i = 1 : size(translation_directions,1)
            tmp_image1 = circshift(tmp_image1,translation_directions(i,:));
            scores(i,x)=sum(base(logical(tmp_image1)));
            
           % progressbar([],i/size(translation_directions,1));
        end
        % progressbar([],[],x/size(angle_interval,2)));
    end
    
    % Get the best score
    
    [Y1,Col1]=min(scores);
    [Y2,Col]=min(Y1);
    row=Col1(Col);
    best_score = scores(row,Col);
    dir = row;
    angle = Col;
    
     % Now see if we fulfil the stop criteria. Else continue
    if best_score > last_score || dir == backwards || dir == oldDir
        stop = true;
        accumulated_scores(end+1) = best_score; %#ok
    else
        floating_b = imtranslate(floating_b,translation_directions(dir,1),translation_directions(dir,2));
        floating_b = imrotate(floating_b,angle_interval(angle),'nearest','crop');
        
         trans_image2 = imtranslate(trans_image2,translation_directions(dir,1),translation_directions(dir,2));
         trans_image2 = imrotate(trans_image2,angle_interval(angle),'nearest','crop');

        oldDir = backwards;
        backwards = mod(dir+1,4)+1;
        last_score = best_score;
        accumulated_scores(end+1) = best_score; %#ok
    end
    
    figure(2)
    imshow(edgeRGBoverlay(base,floating_b,'red'),[])
    
    title(['Floating image position for iteration ' num2str(counter)])
    
    
    counter = counter + 1;
end
%%
figure('name', 'Performance Plot for floating image1');
plot(accumulated_scores,'r');
title('Performance Plot for floating image1')
ylabel('Scores')
xlabel('Iterations')

%%

last_score = inf; % Keep track of last positional score
stop = false; % Stop criterion
backwards = 0; % The direction which we came from
 accumulated_scores2= []; % For plotting reasons
counter = 1;
oldDir = -1;

trans_image3=image3_original;
while ~stop
    tmp_image1 = floating_c; % Start with the current position
    
    scores = zeros(size(translation_directions,1),size(angle_interval,2)); % To save the scores
    for x = 1:size(angle_interval,2)   
        tmp_image1 = imrotate(floating_c,angle_interval(x),'nearest','crop');  
        for i = 1 : size(translation_directions,1)
            tmp_image1 = circshift(tmp_image1,translation_directions(i,:));
     
            scores(i,x)=sum(base(logical(tmp_image1)));
            
        end
    end
    
    
    [y1,col1]=min(scores);
    [y2,col]=min(y1);
    row=col1(col);
    
    best_score = scores(row,col);
    dir = row;
    angle = col;
    
    % Now see if we fulfil the stop criteria. Else continue
    
    if best_score > last_score || dir == backwards || dir == oldDir
        stop = true;
         accumulated_scores2(end+1) = best_score; %#ok
    else
       
        floating_c = imrotate(floating_c,angle_interval(angle),'nearest','crop');
        floating_c=circshift(floating_c,translation_directions(dir,:));
        
        trans_image3 = imtranslate(trans_image3,translation_directions(dir,1),translation_directions(dir,2));
        trans_image3 = imrotate(trans_image3,angle_interval(angle),'nearest','crop');
        
        
        oldDir = backwards;
        backwards = mod(dir+1,4)+1;
        last_score = best_score;
        accumulated_scores2(end+1) = best_score; 
    end
    
         figure;
         imshow(edgeRGBoverlay(base,floating_c,'green'),[])
         title(['Floating image position for iteration ' num2str(counter)])
    
    counter = counter + 1;
end 
%%
figure('name', 'Performance Plot for floating image1');
plot( accumulated_scores2,'g');
title('Performance Plot for floating image1')
ylabel('Scores')
xlabel('Iterations')

%%

rgb = meanRGB(image1_original,trans_image2);
[ind_r ind_c] = ind2sub(size(rgb(:,:,1)),find(rgb(:,:,1)>0));
rgb_crop = rgb(min(ind_r):max(ind_r),min(ind_c):max(ind_c),:);
figure;imshow(rgb_crop);

rgb = meanRGB(image1_original,trans_image3);
[ind_r ind_c] = ind2sub(size(rgb(:,:,1)),find(rgb(:,:,1)>0));
rgb_crop = rgb(min(ind_r):max(ind_r),min(ind_c):max(ind_c),:);
figure;imshow(rgb_crop);

rgb = meanRGB(image1_original,trans_image2,trans_image3);
[ind_r ind_c] = ind2sub(size(rgb(:,:,1)),find(rgb(:,:,1)>0));
rgb_crop = rgb(min(ind_r):max(ind_r),min(ind_c):max(ind_c),:);
figure;imshow(rgb_crop);

