function [varargout] = edgeRGBoverlay(varargin)
%%
% Takes a gray valued or a RGB 8bit 2D image and overlay a edge of an
% binary mask in a colour, transparent or not. The transparency
% option results in a preserved intensity but a change in colour. Using a
% RGB image as input the colour of the transparent edge will be added to 
% the existing colour, additiv colour mixing that is.
% 
% To add several contours in difefrent colours just iterate the function
% with the output from the prior run as input in the current one.
%
% edgeRGBoverlay(grey)                          Returns grey.
% edgeRGBoverlay(grey,mask,'red')               Return the edge of mask in red 
%                                               on grey. 
% edgeRGBoverlay(grey,mask,[125 75 121])        Edge colour will be 
%                                               [125 75 121] in the RGB colour
%                                               space.
% edgeRGBoverlay(grey,mask,'red','transp')      Return the edge of mask in 
%                                               transparent red on grey. Additiv 
%                                               colour mixing is used.
%
%
% 29 Sep 2009 - gustaf@cb.uu.se
%%

se = strel('disk',1);
if isempty(varargin) % If no input
    Irgb = 0;   
elseif length(varargin) >= 1
    grey = double(fillUp8bit(varargin{1}));
    [d1 d2 d3] = size(grey);
    if d3 == 3 % If a RGB image is the input use it
        Irgb = grey;
    else % If a grey scale image is the input extend it to RGB.
        Irgb = double(zeros([size(grey) 3]));
        Irgb(:,:,1) = grey;
        Irgb(:,:,2) = grey;
        Irgb(:,:,3) = grey; 
    end
end 

% Case of default colour and transparency
if length(varargin) == 2 
    mask = varargin{2};
    mask(mask>0) = 1;
    edge = mask;%double(mask)-imerode(double(mask),se);
    colour = double([0 0 255])./255; 
% Case of predefined or custom colour
elseif length(varargin) == 3 || length(varargin) == 4
    mask = varargin{2};
    mask(mask>0) = 1;
    edge = mask;%double(mask)-imerode(double(mask),se);
    if strcmp(varargin{3},'red')
        colour = double([255 0 0])./255;
    elseif strcmp(varargin{3},'green')
        colour = double([0 255 0])./255;
    elseif strcmp(varargin{3},'blue')
        colour = double([0 0 255])./255;
    elseif size(varargin{3},2) == 3
        colour = varargin{3};
    end
end
colour = double(colour);

% if no transparency
if length(varargin) == 4 && ~strcmp(varargin{4},'transp') || ...
        length(varargin) == 3 && ~strcmp(varargin{3},'transp')
    
    Irgb(:,:,1) = Irgb(:,:,1).*~edge;
    Irgb(:,:,2) = Irgb(:,:,2).*~edge;
    Irgb(:,:,3) = Irgb(:,:,3).*~edge; 
end

% Adding colour edge 
Irgb(:,:,1) = Irgb(:,:,1) + edge.*colour(1).*255;
Irgb(:,:,2) = Irgb(:,:,2) + edge.*colour(2).*255;
Irgb(:,:,3) = Irgb(:,:,3) + edge.*colour(3).*255;

% Converting output to uint8
varargout{1} = uint8(Irgb);
