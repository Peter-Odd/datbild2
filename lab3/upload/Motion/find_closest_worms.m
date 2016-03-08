    function [cols, rows, coords] = find_closest_worms(coords,worm_coords)
        %worm_coords = [10, 10;20,20;30,30];
  
        
   %worm_coords=[202.0345 , 367.9655;  334.3824,  405.7941;  374.2083 , 403.6667];
  

worm_coords=[1, 1;
  5,  5;
  20, 20];
  

  coords = [0,1;20,20;5,8];
  
  
        new_coords = worm_coords;
        distances = zeros(1,3);
        for(i = 1 : length(coords(:,1)))  
            for(j = 1 : length(worm_coords(:,1)))                
                distances(j,i) = sqrt(sum(coords(j,:)-worm_coords(i,:)).^2); % Euclidean distance from coord j to worm_coord i
            end
        end
        
        

        distances_ = distances;
        
for(i = 1:3)        
    [min_val,idx]=min(distances(:));
    [rows(i),cols(i)]=ind2sub(size(distances),idx);
    distances(rows(i),:) = inf;
end
    end