function res = meanRGB(varargin)

if nargin>0
    res = zeros(size(varargin{1}));
    for i=1:nargin
        res = res + double(varargin{i});
    end
    res = uint8(res./nargin);
end




