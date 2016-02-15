% DEMO - Chamfer matching
% 
% Written by: Patrik Malm 2011-11-17

close all

%% Create a test image
x = -128:127;
[y,x] = ndgrid(x,x);
m = (x.^2+y.^2)<(30.^2);
a = y;
a(m) = -a(m);
%a = a + randn(256,256)*10; % optionally add noise...
a = a-min(a(:));
a = a*(255/max(a(:)));

figure;
subplot(2,2,1)
imshow(a,[]);
title('Test image')

%% Generate the edge image using Canny

t1 = 0.1;
t2 = 0.2;
sigma = 0.8;

a_edge = edge(a,'canny',[t1 t2],sigma);

subplot(2,2,2)
imshow(a_edge,[]);
title('Canny result from test image')

%% Translate the edge image to get a floating image that is offset 

% Of course you don't need to do this later

floating = a_edge - a_edge;
floating(60:end,60:end) = a_edge(1:end-60+1,1:end-60+1);

subplot(2,2,3)
imshow(floating,[]);
title('Floating image')

%% Calculate the distance transform of the original edge image (the base)

base = bwdist(a_edge,'euclidean');

subplot(2,2,4)
imshow(base,[]);
title('Base image')

%% Specify the directions that will be used for 

step = 3;

translation_directions = [-0    -step; 
                          -step  0       ;
                           0     step; 
                           step  0      ];
                       
%% Now pad the images to make room to manouver

base = padarray(base,size(base),max(base(:)));
floating = padarray(floating,size(floating),0);

%% Finally do the chamermatching

last_score = inf; % Keep track of last positional score
stop = false; % Stop criterion
backwards = 0; % The direction which we came from
accumulated_scores = []; % For plotting reasons
counter = 1;

while ~stop
    
    tmp_image = floating; % Start with the current position
    scores = zeros(size(translation_directions,1),1); % To save the scores
    
    for i = 1 : size(translation_directions,1) 
        % Translate the image
        tmp_image = circshift(floating,translation_directions(i,:));
        % Calculate the score of the translation
        scores(i)=sum(base(logical(tmp_image)));      
    end
    
    % Get the best score
    [best_score,dir]=min(scores);
    
    % Now see if we fulfil the stop criteria. Else continue
    
    if best_score > last_score || dir == backwards
        stop = true;
        accumulated_scores(end+1) = best_score; %#ok
    else       
        floating = imtranslate(floating,translation_directions(dir,1),translation_directions(dir,2));
        backwards = mod(dir+1,4)+1;
        last_score = best_score;
        accumulated_scores(end+1) = best_score; %#ok
    end
    
    figure(2)
    imshow(edgeRGBoverlay(base,floating,'red'),[])
    title(['Floating image position for iteration ' num2str(counter)])

    counter = counter + 1;
end

figure;
plot(accumulated_scores,'r');
title('Positional scores')
ylabel('Scores')
xlabel('Iterations')