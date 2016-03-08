videoFile = './source_sequence_.avi';
mask = imread('bwmask.png');
number_of_frames = 580;
[images,fps] = read_movie(videoFile, 1, number_of_frames);

%%
box_size = 10;
lenY = length(images(:,1,1));
lenX = length(images(1,:,1));
new_images = images;
error_count = 0;

worm_coords = zeros(4,2); %[y x y_momentum x_momentum]
for(i = 1:number_of_frames-500)
    if(mod(i,50) == 0)
        fprintf('%d of %d done\n',i,number_of_frames);
    end
    I = images(:,:,i);
    I = imsharpen(I);
    I = imsharpen(I);
    I_e = imextendedmin(I + mask,90);
    %imshow(I_e);
    r = regionprops(I_e);
    color = 'red';
    
    
    for(j = 1:3) 
    if(max(size(r)) >= j) %% Check so we have found enough worms
        y = r(j).Centroid(1);
        x = r(j).Centroid(2) ;          
        if(i == 1) % init
            worm_coords(j,1) = y;
            worm_coords(j,2) = x;
            worm_index = j;
        else
           % fprintf('Before: ');
           % worm_coords
            [worm_index,worm_coords] = closest_index_old(y,x,worm_coords);
           % if(j == 2) % init
                %[y x worm_index]
                %fprintf('After: '); 
                %worm_coords
                
           % end
        end
        
        new_images(:,:,i) = rgb2gray(insertText(new_images(:,:,i), [y-box_size/2+10 x-box_size/2],int2str(worm_index),'BoxOpacity', 0));
        new_images(:,:,i) = rgb2gray(insertShape(new_images(:,:,i), 'rectangle', [y-box_size/2 x-box_size/2 box_size box_size], 'Color', {color}, 'LineWidth', 1));
        %imshow(images(:,:,j));
    else
        error_count = error_count + 1;
    end
    end
    worm_coords;
%worm_coords = new_coords;
end
fprintf('\nNumber of errors: %d\n', error_count);

%% "Play" video
for j = 1:number_of_frames
    imshow(new_images(:,:,j));    
    %pause(.3);

end
%%
%%
box_size = 10;
lenY = length(images(:,1,1));
lenX = length(images(1,:,1));
new_images = images;
error_count = 0;
coords = zeros(3,3);
worm_coords = zeros(4,2); %[y x y_momentum x_momentum]
for(i = 1:number_of_frames-250)
    if(mod(i,50) == 0)
        fprintf('%d of %d done\n',i,number_of_frames);
    end
    I = images(:,:,i);
    I = imsharpen(I);
    I = imsharpen(I);
    I_e = imextendedmin(I + mask,90);
    %imshow(I_e);
    
    r = regionprops(I_e);
    coords(1,1:2) = r(1).Centroid;
    coords(2,1:2) = r(2).Centroid;
    coords(3,1:2) = r(3).Centroid;
    
    coords(1,3) = 1;
    coords(2,3) = 2;
    coords(3,3) = 3;
    
    if(i == 1) % init
        worm_coords = coords;
        current_worm_id = 1:3;
        closest_old_worm_pos = 1:3;
    else
       [current_worm_id closest_old_worm_pos] = find_closest_worms(coords, worm_coords);
    end
        for(j = 1:3)
            new_images(:,:,i) = rgb2gray(insertText(new_images(:,:,i), [coords(current_worm_id(j),1)-box_size/2+10 coords(current_worm_id(j),2)-box_size/2],int2str(coords(current_worm_id(j),3)),'BoxOpacity', 0));
            new_images(:,:,i) = rgb2gray(insertShape(new_images(:,:,i), 'rectangle', [coords(current_worm_id(j),1)-box_size/2 coords(current_worm_id(j),2)-box_size/2 box_size box_size], 'Color', {color}, 'LineWidth', 1));
        end
        %imshow(images(:,:,j));
    %else
    %    error_count = error_count + 1;
    worm_coords = coords;
    end    
    worm_coords;


fprintf('\nNumber of errors: %d\n', error_count);



%%
img = images(:,:,j);
subplot(1,2,1);
imshow(img);
img = imsharpen(img);
subplot(1,2,2);
imshow(img);


%%
   
imshow(new_images(:,:,1));

    
    
