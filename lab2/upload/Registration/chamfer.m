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
step = 40;
translation_directions = [
                            0      -step;
                            -step  0;
                            0      step;
                            step   0;
                            0      -step/2;
                            -step/2  0;
                            0      step/2;
                            step/2   0;
                          ];

%% specify the rotations that will be used for
rot_size = 10;
number_of_rots = 4;
number_of_rots = number_of_rots-1;
rotation_directions = -rot_size:rot_size/number_of_rots*2:rot_size
%rotation_directions = fliplr(rotation_directions);

%% now pad the images to make room to manouver
baseDT = padarray(baseDT, size(baseDT), 0);%max(baseDT(:)));
img2_edge = padarray(img2_edge, size(img2_edge), 0);
base_show = padarray(base_edge, size(base_edge), 0);



%% chamfermatching!
last_score = inf;
stop = false;
backwards = 0;
accumulated_scores = [];
counter = 1;
len = length(orig(:,1,1));
visitedCoords = zeros(len,len,number_of_rots);
accumulator_index = 0;
acc_rot = 0;
acc_dir = [0 0];
prev_dir = [inf inf]

while ~stop
    top_image = img2_edge;
    scores = zeros(size(translation_directions, 1), number_of_rots); 
    
    for i = 1 : size(translation_directions, 1)
        tmp_image_ = circshift(img2_edge, translation_directions(i,:));
        for(j = 1:length(rotation_directions))
            tmp_image = imrotate(tmp_image_,rotation_directions(j),'bilinear','crop');
            scores(i,j)=sum(baseDT(logical(tmp_image)));
            %scores(i,j) = sum((baseDT(:)-not(logical(tmp_image(:))).*70).^2);%sum(baseDT(logical(tmp_image)));
        end
    end
        
    %[best_score, dir] = min(scores);

    %[best_translation_dir,best_rotation_dir,best_score] = find(scores == min(scores(:)))
    [best_translation_dir,best_rotation_dir] = find(scores == min(scores(:)));
    best_score = min(min(scores));
    acc_rot = acc_rot + rotation_directions(best_rotation_dir)
    acc_dir = acc_dir + translation_directions(best_translation_dir,:)
    curr_dir = translation_directions(best_translation_dir,:);
    
    
    
    if (counter > inf || sum(curr_dir == -prev_dir) > 1)
        stop = true;
        accumulated_scores(accumulator_index+1) = best_score;        
    else
        img2_gray = rgb2gray(img2);
        img2_edge = edge(img2_gray, 'canny', [t1 t2], sigma);
        
        img2_edge = padarray(img2_edge, size(img2_edge), 0);
        img2_edge = imrotate(img2_edge,acc_rot, 'bilinear','crop');
        img2_edge = imtranslate(img2_edge,  ...
        acc_dir(1), acc_dir(2));
                
        last_score = best_score;
        accumulated_scores(accumulator_index+1) = best_score;
        accumulator_index = accumulator_index + 1;

    end
    
    prev_dir = translation_directions(best_translation_dir,:);
            
    l1 = length(base_edge(1,:));
    l2 = length(base_edge(:,1));
    start = 200;
    figure(2)
    imshow(edgeRGBoverlay(base_show,img2_edge,'red'),[])
    title(['Floating image position for iteration ' num2str(counter)])
    
    %subplot(336);
    %imshow(edgeRGBoverlay(baseDT, img2_edge,'red'),[])
    %title(['Floating image position for iteration ' num2str(counter)])
    counter = counter + 1;

%subplot(338);
%figure;
%imshow(meanRGB(orig,img2),[]);
%title('Images 01, 02 & 03 merged');

end
    img2 = imrotate(img2, acc_rot,'bilinear','crop');
    img2 = imtranslate(img2,  ...
    acc_dir(1), acc_dir(2));

subplot(337);
figure;
plot(accumulated_scores, 'r');
title('Positional scores');
ylabel('Scores');
xlabel('Iterations');

%% show merged result
subplot(338);
figure;
imshow(meanRGB(orig,img2));
title('Images 01, 02 & 03 merged');

