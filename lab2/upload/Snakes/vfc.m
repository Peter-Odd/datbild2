%VFC   Computes an external force using Vector Field Convolution
%
%  F = VFC(EDGE_IMAGE,FSIZE,GAMMA) returns the vector field in the
%  cell array F. F{1} contains an image with the x-component of the
%  vector field, F{2} contains an image with the y-component.
%
%  EDGE_IMAGE is a scalar image with large values at the locations
%  where the snake has to move to, for example the gradient magnitude.
%
%  FSIZE is the size of the convolution kernel, GAMMA is the kernel
%  parameter. Defaults are FSIZE = 41 and GAMMA = 2.
%
%  See: B. Li, S.T. Acton, "Active Contour External Force Using Vector
%       Field Convolution for Image Segmentation", IEEE-TIP 16(8):2096-
%       2106 (2007)

% (C) Copyright 2009-2011, All rights reserved.
% Cris Luengo, Uppsala, 21 September 2009    - Initial code
% Cris Luengo, Uppsala, 3 November 2011      - Independent from DIPimage

function out = vfc(edge_image,fsize,gamma)

if nargin<2
   fsize = 41;
elseif numel(fsize)~=1 || fsize<=1
   error('Expecting positive scalar FSIZE');
end
if nargin<3
   gamma = 2;
elseif numel(gamma)~=1 || gamma<=0
   error('Expecting positive scalar GAMMA');
end

fsize = floor(fsize/2);
x = -fsize:fsize;
[Ky,Kx] = ndgrid(x,x);

Kn = sqrt(Kx.^2 + Ky.^2);
Kn = max(Kn,1e-10);
Kx = -Kx./(Kn.^(gamma+1));
Ky = -Ky./(Kn.^(gamma+1));

out = { conv2(edge_image,Kx,'same') , conv2(edge_image,Ky,'same') };
n = sqrt(out{1}.^2+out{2}.^2);
n = max(n,1e-10);
out{1} = out{1}./n;
out{2} = out{2}./n;
