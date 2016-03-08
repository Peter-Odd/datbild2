    function [index, new_coords] = closest_index(y,x,worm_coords)
        %worm_coords = [10, 10;20,20;30,30];
    %   y = 193.3124;
     %   x = 350.6250;
        
   %worm_coords=[ 202.0345 , 367.9655;
  %334.3824,  405.7941;
  %374.2083 , 403.6667]
        new_coords = worm_coords;
        vector = [y x];
        distances = zeros(1,3);
        for(i = 1 : length(worm_coords(:,1)))            
            distances(i) = sqrt(sum(vector-worm_coords(i,:)).^2); % Euclidean distance
        end
        [distance, index] = min(distances);
        new_coords(index,1) = y;
        new_coords(index,2) = x;        
    end
    
    
    
    
    

%  193.3125  359.6250




 % 328.1786  406.4286




  %371.2800  403.8800
  
  
  %202.0345  367.9655
  %334.3824  405.7941
  %374.2083  403.6667