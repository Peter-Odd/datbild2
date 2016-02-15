%IM2SNAKE   Creates a snake based on a binary image
%
%  SNAKE = IM2SNAKE(IMAGE), with IMAGE a binary image, returns
%  in SNAKE the coordinates of the boundary of the first object
%  encountered in IMAGE. An object is defined as an 8-connected
%  group of non-zero pixels.

% (C) Copyright 2010-2011, All rights reserved.
% Cris Luengo, Uppsala, 4 March 2010         - Initial code
% Cris Luengo, Uppsala, 3 November 2011      - Independent from DIPimage

function snake = im2snake(img)

directions = [ 0, 1
              -1, 1
              -1, 0
              -1,-1
               0,-1
               1,-1
               1, 0
               1, 1]; % directions(cc+1,:) = [y,x] increment

sz = size(img);

% Find the start pixel for the contour
indx = find(img,1)-1;
coord = [0,floor((indx)/sz(1))];
coord(1) = indx-(coord(2)*sz(1));
coord = coord+1;
start = coord; % remember where we started

% Go around the contour
cc = [];
dir = 1+1; % we take this as our initial direction to go clockwise
           % around the object, our start pixel does not have a
           % neighbour in the 5, 4, 3 or 2 directions.
while 1
   newcoord = coord + directions(dir,:);
   if all(newcoord>0) && all(newcoord<=sz) && img(newcoord(1),newcoord(2))
      cc = [cc,dir];
      coord = newcoord;
      dir = mod(dir+1,8)+1;
   else
      dir = mod(dir-2,8)+1;
   end
   if all(coord==start) && dir==2 % back to starting situation
      break;
   end
end

% Convert back to coordinates
cc(end) = []; % remove duplicate point
snake = cumsum([start;directions(cc',:)]);
