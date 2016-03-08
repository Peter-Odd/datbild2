    function [new_coords_] = find_closest_worms(new_coords,old_coords,index)
  
     old_coords=[379.6327  ,109.4286;  476.3158  ,198.1316;  301.7273  ,410.9091];

     new_coords= [    290.0690  ,410.0345;  402.2353  ,119.5882;  479.6522  ,214.0000];
  
        distances = zeros(3,3);
        for(new_i = 1 : length(new_coords(:,1)))  
            for(old_i = 1 : length(old_coords(:,1)))                
                distances(old_i,new_i) = sqrt(sum(new_coords(old_i,:)-old_coords(new_i,:)).^2); % Euclidean distance from old_coord to new_coord
            end
        end
        
        

        distances_ = distances;
           
for(i = 1:3)        
    [min_val,idx]=min(distances(:));
    [from,to]=ind2sub(size(distances),idx);
    distances(from,:) = inf;
    new_coords_(to,:) = new_coords(from,:);
end


if(index == 51)
    old_coords
    new_coords    
    new_coords_
    distances_
    distances
    from
    to
 end


% new_coords =
% 
%   290.0690  410.0345
%   402.2353  119.5882
%   479.6522  214.0000
% 
% 
% old_coords =
% 
%   379.6327  109.4286
%   476.3158  198.1316
%   301.7273  410.9091