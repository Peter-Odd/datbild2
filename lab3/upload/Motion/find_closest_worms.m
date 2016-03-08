function [new_coords_sorted] = find_closest_worms(new_coords,old_coords,index)
    distances = zeros(3,3);
    for(old_i = 1 : length(old_coords(:,1)))  
        for(new_i = 1 : length(new_coords(:,1)))
            predicted_posY = old_coords(old_i,1) + old_coords(old_i,3);
            predicted_posX = old_coords(old_i,2) + old_coords(old_i,4);
            % Euclidean distance from old_coord to new_coord
            distances(new_i,old_i) = sqrt(sum(new_coords(new_i,1)-(predicted_posY))^2 + ...
                                          sum(new_coords(new_i,2)-(predicted_posX))^2); 
        end
    end
        
    
    %distances[i,j] is a matrix where element distances(i,j) corresponds to
    %the distance from old_coords(i) to new_coords(j). 
    for(index = 1:3)
        [min_val,idx]=min(distances(:));
        [from,to]=ind2sub(size(distances),idx);
        distances(from,:) = inf; %This is done so we don't select the same mask twice
        distances(:,to) = inf;

        %Here, the worms in new_coords_sorted will be represented contain new_coords
        %but they are(hopefully) sorted in the same order as old_coords so we can
        %classify each mask correctly.
        new_coords_sorted(to,:) = new_coords(from,:);
        
        %We add momentum to the all masks, so i.e. predicted_posY will be
        %pushed forward
        new_coords_sorted(index,3) = new_coords_sorted(index,1) - old_coords(index,1);
        new_coords_sorted(index,4) = new_coords_sorted(index,2) - old_coords(index,2);
    end
