clc; clear; close all;
figure('units','normalized','outerposition',[0 0 1 1]); %full screen figure

%% load images
base = imread('01.png');
img2 = imread('02.png');
img3 = imread('03.png');
orig = imread('01.png');

%% display the three images
subplot(331);
imshow(base);
title('Image 01');
subplot(332);
imshow(img2);
title('Image 02');
subplot(333);
imshow(img3);
title('Image 03');


%% show canny of base image
t1 = 0.1;
t2 = 0.2;
sigma = 0.8;
base_gray = rgb2gray(base); %convert to grayscale
base_edge = edge(base_gray, 'canny', [t1 t2], sigma); %canny edges
subplot(334);
imshow(base_edge);
title('Canny of base (01) image');


%% canny for img2
img2_gray = rgb2gray(img2);
img2_edge = edge(img2_gray, 'canny', [t1 t2], sigma);


%% canny for img3
img3_gray = rgb2gray(img3);
img3_edge = edge(img3_gray, 'canny', [t1 t2], sigma);


%% calculate DT of the original edge image (base)
baseDT = bwdist(base_edge, 'euclidean');
subplot(335);
imshow(baseDT,[]);
title('DT of base image');

%% specify the directions that will be used for
step = 3;
translation_directions = [
                            0      -step;
                            -step  0;
                            0      step;
                            step   0 
                          ];

%% specify the rotations that will be used for
rot_size = 20;
number_of_rots = 10;
rotation_directions = -rot_size:rot_size/number_of_rots:rot_size;
rotation_directions = fliplr(rotation_directions);

%% now pad the images to make room to manouver
baseDT = padarray(baseDT, size(baseDT), max(baseDT(:)));
img2_edge = padarray(img2_edge, size(img2_edge), 0);


%% chamfermatching!
last_score = inf;
stop = false;
backwards = 0;
accumulated_scores = [];
counter = 1;
len = length(orig(:,1,1));
visitedCoords = zeros(len,len,rot_size*number_of_rots);

while ~stop
    top_image = img2_edge;
    scores = zeros(size(translation_directions, 1), 1);
    
    for i = 1 : size(rotation_directions, 1)
        tmp_image = circshift(img2_edge, rotation_directions(i,:));
        scores(i) = sum(baseDT(logical(tmp_image)));
    end
    
    for i = 1 : size(translation_directions, 1)
        tmp_image = circshift(tmp_image, translation_directions(i,:));
        
        scores(i) = sum(baseDT(logical(tmp_image)));
    end
    
    [best_score, dir] = min(scores);

    if best_score > last_score %|| dir == backwards
        stop = true;
        accumulated_scores(end+1) = best_score;
    else
        img2_edge = imrotate(img2_edge,rotation_directions(dir),'bilinear','crop');
        img2_edge = imtranslate(img2_edge, translation_directions(dir, 1), translation_directions(dir, 2));
        %backwards = mod(dir+1, 4) + 1;
        last_score = best_score;
        accumulated_scores(end+1) = best_score;
    end
   
    
    subplot(336);
    imshow(edgeRGBoverlay(baseDT, img2_edge,'red'),[])
    title(['Floating image position for iteration ' num2str(counter)])
    counter = counter + 1;

    

end

figure;
imshow(meanRGB(orig, img2_edge));
title('TEST');

%subplot(337);
figure;
plot(accumulated_scores, 'r');
title('Positional scores');
ylabel('Scores');
xlabel('Iterations');

%% show merged result
%subplot(338);
figure;
imshow(meanRGB(orig,img2));
title('Images 01, 02 & 03 merged');

