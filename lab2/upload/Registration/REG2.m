close all;
clear all;
clc


%Load images

I{1}=rgb2gray(imread('01.png'));
I{2}=rgb2gray(imread('02.png'));
I{3}=rgb2gray(imread('03.png'));

J=imread('01.png');
J3=J(:,:,3);
figure;imshow(J3);
thresh = graythresh(J3);
Jthresh = im2bw(J3,0.01);
figure;imshow(Jthresh);
SE = strel('disk', 1);
Jimopen = imclose(Jthresh, SE);
%Jimopen = imerode(Jthresh, SE);
figure;imshow(Jimopen);

I{1} = Jimopen;

%%
%I_padded{1} = padarray(imread('01.png'),size(I{1}),0);
I_padded{1} = padarray(I{1},size(I{1}),0);
figure;imshow(I_padded{1});

figure;
for i=1:3
    subplot(1,3,i);
    imshow(I{i});
    
end;
%% Generate the edge image using Canny


t1 = 0.1;
t2 = 0.2;
sigma = 0.7;
se=strel('disk',2);
for i=1:3
a_edge{i} = imdilate(edge(I{i},'canny',[t1 t2],sigma),se);
%a_edge{i} =edge(I{i},'canny',[t1 t2],sigma);

end;
% 
figure;
for i=1:3
subplot(1,3,i)
imshow(a_edge{i},[]);
title('Canny result from test image')
end;

%% Calculate the distance transform of the original edge image (the base)
figure;
base = bwdist(a_edge{1},'euclidean');

imshow(base,[]);
title('Base image')
%% Specify the directions that will be used for 

step =20;

translation_directions = [0    -step; 
                          -step  0;
                           0     step; 
                           step  0];
                       
%% Specify rotation that will be used.
angle=5;
rotation_directions = [angle -angle]; 
                       
                       
%% Now pad the images to make room to manouver
offset=[100 100;
        0 0];

movement=[0 0 0;
          0 0 0];
      base2 = padarray(base,size(base),max(base(:)));
for im_nr=1:2

    floating = padarray(a_edge{im_nr+1},size(a_edge{im_nr+1}),0);


    %% Finally do the chamermatching


    last_score = inf; % Keep track of last positional score

    stop = false; % Stop criterion
    backwards = 0; % The direction which we came from
    accumulated_scores = []; % For plotting reasons
    counter = 1;

    %Initial position
    floating = circshift(floating,offset(im_nr,:));
    
    
    while ~stop
    scores = zeros([4 2]); % To save the scores


        for i=1:size(translation_directions,1)

            %Two different rotations
            tmp_image1 = imrotate(floating,rotation_directions(1),'crop');
            tmp_image2 = imrotate(floating,rotation_directions(2),'crop');


            %Translation with two rotations
            tmp_image1 = circshift(tmp_image1,translation_directions( i,:));
            tmp_image2 = circshift(tmp_image2,translation_directions( i,:));

            %Find sums of distance
            scores(i,1)=sum(base2(logical(tmp_image1)));
            scores(i,2)=sum(base2(logical(tmp_image2)));

        end;
            disp(scores);

         [best_score,dir]=min(scores(:));
            disp(best_score);

         if best_score <1%> last_score || dir == backwards
            stop = true;
            accumulated_scores(end+1) = best_score; %#ok
         else
             if(dir>=1 && dir<=4)
                 rot_angle=rotation_directions(1);

             elseif(dir>4 && dir<=8)
                 rot_angle=rotation_directions(2);
             end;

            movement(im_nr,1)=movement(1,1)+rot_angle;
            floating= imrotate(floating,rot_angle,'crop');
            disp(['Rotating ' num2str(rot_angle) ' degrees']);

            movement(im_nr,2:3)=movement(1,2:3)+[translation_directions(mod(dir-1,4)+1,1) translation_directions(mod(dir-1,4)+1,2)];
            floating = imtranslate(floating,translation_directions(mod(dir-1,4)+1,1),translation_directions(mod(dir-1,4)+1,2));
            disp(['Translating x(' num2str(translation_directions(mod(dir-1,4)+1,2)) ') y(' num2str(translation_directions(mod(dir-1,4)+1,1)) ')' ]);
            backwards = mod(dir+1,8)+1;
            last_score = best_score;
            accumulated_scores(end+1) = best_score; %#ok
        end

        figure(222);
        imshow(edgeRGBoverlay(I_padded{1},floating,'red'),[])
        title(['Floating image position for iteration ' num2str(counter)])
        pause(0.05);

        if(counter>20)
            break
        end;

        counter = counter + 1;
    end
    figure;
    plot(accumulated_scores,'r');
end;