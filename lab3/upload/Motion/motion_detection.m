%Read images
videoFile = './source_sequence_.avi';
mask = imread('bwmask.png');
number_of_frames = 580;
[images,fps] = read_movie(videoFile, 1, number_of_frames);

%%
box_size = 10;
new_images = images;
old_coords = zeros(3,4); %[y x y_momentum x_momentum]
new_coords = zeros(3,4); %[y x y_momentum x_momentum]
init = 1;
conn = 90;
conn_subtract = 1;
tic;
for(i = 1:number_of_frames)
    conn_subract = 10;
    if(mod(i,50) == 0)
        fprintf('%d of %d done\n',i,number_of_frames);
    end
    I = images(:,:,i);
    
    % Preprocessing
    I = imsharpen(I);
    I = imsharpen(I);
    I = imsharpen(I);
    
    %Binarization
    I_e = imextendedmin(I + mask,90);
    
    %Stored for debugging
    I_e_array(:,:,i) = I_e;
    
    I_e_shrink = I_e;
    I_e_grow = I_e;
    r_shrink = regionprops(I_e);
    r_grow = regionprops(I_e);
    
    while(length(r_shrink) < 3 || length(r_grow) > 3) % Search for binary images that contain all masks
        if(conn - conn_subract > 0)
            I_e_shrink = imextendedmin(I + mask,conn - conn_subract);     
        end
        r_shrink = regionprops(I_e_shrink);
        I_e_grow = imextendedmin(I + mask,conn + conn_subract);     
        r_grow = regionprops(I_e_grow);
        conn_subract = conn_subract + 1;
    end
    
    if(length(r_shrink) == 3) %Select the correct regionsprops with 3 distinct centroids
        r = r_shrink;
        I_e = I_e_shrink;
    else
        r = r_grow;
        I_e = I_e_grow;
    end
    I_e_array(:,:,i) = I_e;
        
    if(length(r) > 3 || length(r) < 3)
        fprintf('Alert!, check image: %d\n',i);
        new_coords = old_coords;
    else
        new_coords(1,1:2) = r(1).Centroid;
        new_coords(2,1:2) = r(2).Centroid;
        new_coords(3,1:2) = r(3).Centroid;
    end

    if(i == 1) % init
        old_coords = new_coords;
        current_worm_id = 1:3;
        closest_old_worm_pos = 1:3;
    else
       new_coords = find_closest_worms(new_coords, old_coords,i);
    end
    
    for(j = 1:3)
         new_images(:,:,i) = rgb2gray(insertText(new_images(:,:,i), [new_coords(j,1)-box_size/2+10 new_coords(j,2)-box_size/2],int2str(j),'BoxOpacity', 0));
         new_images(:,:,i) = rgb2gray(insertShape(new_images(:,:,i), 'rectangle', [new_coords(j,1)-box_size/2 new_coords(j,2)-box_size/2 box_size box_size], 'Color', {'red'}, 'LineWidth', 1));            new_images(:,:,i) = rgb2gray(insertShape(new_images(:,:,i), 'rectangle', [new_coords(j,3)-box_size*2 new_coords(j,4)-box_size*2 box_size box_size], 'Color', {'red'}, 'LineWidth', 1));            %new_images(:,:,i) = rgb2gray(insertShape(new_images(:,:,i), 'rectangle', [new_coords(current_worm_id(j),1)-box_size/2 new_coords(current_worm_id(j),2)-box_size/2 box_size box_size], 'Color', {'red'}, 'LineWidth', 1));
    end

    old_coords = new_coords;
    end    
toc


%% "Play" video
for j = 1:number_of_frames
    imshow(new_images(:,:,j));    
    %imshow(I_e_array(:,:,j)*255);    
     %pause(0.01);
    j
end
    
