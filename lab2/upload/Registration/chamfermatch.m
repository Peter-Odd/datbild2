function [trans_rot_seq,scores] = chamfermatch(base_image,floating_image,angle_interval,row_step,col_step,scale_space_no)

translation_directions = [-row_step -col_step
    -row_step  col_step
    row_step -col_step
    row_step  col_step
    -0        -col_step
    -row_step  0
    0         col_step
    row_step  0];

tmp_image = floating_image;
n = 1;
scores = [];
last_idx = 0;
tot_rot = 0;
rot_seq = [];
trans_seq = [];
tot_trans = [0 0];
% figure(1)

while 1
    score = zeros(length(angle_interval)+size(translation_directions,1),1);
    %floating_image = tmp_image;
    tmp_image = imrotate(floating_image,tot_rot,'nearest','crop');
    tmp_image = imtranslate(tmp_image,tot_trans(1),tot_trans(2));
    
    for i = 1:length(angle_interval) % Perform rotations
        search_image = imrotate(tmp_image,angle_interval(i),'nearest','crop');
        score(i) = sum((search_image(:).*base_image(:)));
    end
    for i = 1:size(translation_directions,1) % Perform translations
        search_image = imtranslate(tmp_image,translation_directions(i,1),translation_directions(i,2));
        score(length(angle_interval)+i) = sum((search_image(:).*base_image(:)));
    end
    
    [new_score idx] = min(score);
    scores(n) = new_score;
%     figure(1);plot(scores);xlim([0 20]);
    
    if n > 1        
        if idx<=length(angle_interval) && last_idx <= length(angle_interval)  % rotation
            if angle_interval(idx) == -angle_interval(last_idx)
                if scale_space_no > 0
                    disp('Changing scalespace');
                    angle_interval = angle_interval * 0.5;
                    translation_directions = ceil(translation_directions*0.5);
                    scale_space_no = scale_space_no - 1;
                else
                    break;
                end
            end
        elseif idx > length(angle_interval) && last_idx > length(angle_interval)% translation
            if translation_directions(idx-length(angle_interval),:) == -translation_directions(last_idx-length(angle_interval),:)
                if scale_space_no > 0
                    disp('Changing scalespace');
                    angle_interval = angle_interval * 0.5;
                    translation_directions = ceil(translation_directions*0.5);
                    scale_space_no = scale_space_no - 1;
                else
                    break;
                end
            end
        end
    end
    
    if idx<=length(angle_interval) % rotation
        tot_rot = tot_rot + angle_interval(idx);
        rot_seq(end+1) = tot_rot;
        trans_seq(end+1,1:2) = tot_trans;
        tmp_image = imrotate(floating_image,tot_rot,'nearest','crop');
        tmp_image = imtranslate(tmp_image,tot_trans(1),tot_trans(2));
    else % translation
        i = idx-length(angle_interval);
        tmp_image = imrotate(floating_image,tot_rot,'nearest','crop');
        tot_trans = tot_trans + [translation_directions(i,1),translation_directions(i,2)];
        trans_seq(end+1,1:2) = tot_trans;
        rot_seq(end+1,1) = tot_rot;
        tmp_image = imtranslate(tmp_image,tot_trans(1),tot_trans(2));
    end

    if n>1
        trans_rot_seq = [trans_seq rot_seq];
        cmp_trans_rot = repmat([tot_trans tot_rot],size(trans_rot_seq,1),1);
        
        if any(sum(cmp_trans_rot(1:end-1,:)==trans_rot_seq(1:end-1,:),2)==3)
            if scale_space_no > 0
                disp('Changing scalespace');
                angle_interval = angle_interval * 0.5;
                translation_directions = ceil(translation_directions*0.5);
                scale_space_no = scale_space_no - 1;
            else
                break;
            end
        end
    end
        
    imwrite(edgeRGBoverlay(base_image,tmp_image,'red'),['images/chamfer' num2str(n,'%.4d') '.png']);
    n = n + 1;
    disp(n)
    
    last_idx = idx;
end