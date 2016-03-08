    function [index, new_coords,pred] = closest_index(y,x,worm_coords)
  %     y = 193.3124;
  %      x = 350.6250;
        
   %worm_coords=[ 202.0345 , 367.9655,0,0; 334.3824,  405.7941,0,0; 374.2083 , 403.6667,0,0];
        new_coords = worm_coords;
        current_pos = [y x];        
        distances = zeros(1,3);
        pred_ = zeros(3,2);
        for(i = 1 : length(worm_coords(:,1)))
            previous_pos = worm_coords(i,1:2);
            predicted_pos = previous_pos + worm_coords(i,3:4);            
            pred_(i,:) = predicted_pos;
            distances(i) = sqrt(sum(current_pos - predicted_pos).^2); % Euclidean distance
        end
        [distance, index] = min(distances);
        new_coords(index,3) = y - new_coords(index,1);
        new_coords(index,4) = x - new_coords(index,2);
        new_coords(index,1) = y;
        new_coords(index,2) = x;  
        pred = zeros(1,2);
        pred = pred_(index,:);
        
    end
    
    
    
    
    

%  193.3125  359.6250




 % 328.1786  406.4286




  %371.2800  403.8800
  
  
  %202.0345  367.9655
  %334.3824  405.7941
  %374.2083  403.6667