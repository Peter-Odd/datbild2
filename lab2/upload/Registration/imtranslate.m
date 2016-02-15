% IMTRANSLATE
% 
%  b = imtranslate(a,dr,dc)
% 
%  a: Input image (any 2 or 3D matrix)
% dr: Change in rows (integer)
% dc: Change in columns (integer)
%  b: Translated image, same size as a
% 
% Description: imtranslate translates the contents of the image according
% to dr, dc. Absence of image content after translation is filled with
% zeros.
% 
% Written by: Gustaf Kylberg och Patrik Malm, Nov. 2010

function b = imtranslate(a,dr,dc)

sz = size(a);
b = zeros(sz);
 
if length(sz) > 2
    if dr <= 0 && dc <= 0
        b(1:end+dr,1:end+dc,:) = a(1-dr:end,1-dc:end,:);
    elseif dr > 0 && dc > 0
        b(1+dr:end,1+dc:end,:) = a(1:end-dr,1:end-dc,:);
    elseif dr > 0 && dc <= 0
        b(1+dr:end,1:end+dc,:) = a(1:end-dr,1-dc:end,:);
    elseif dr <= 0 && dc > 0
        b(1:end+dr,1+dc:end,:) = a(1-dr:end,1:end-dc,:);
    end
else
    if dr <= 0 && dc <= 0
        b(1:end+dr,1:end+dc) = a(1-dr:end,1-dc:end);
    elseif dr > 0 && dc > 0
        b(1+dr:end,1+dc:end) = a(1:end-dr,1:end-dc);
    elseif dr > 0 && dc <= 0
        b(1+dr:end,1:end+dc) = a(1:end-dr,1-dc:end);
    elseif dr <= 0 && dc > 0
        b(1:end+dr,1+dc:end) = a(1-dr:end,1:end-dc);
    end
end




