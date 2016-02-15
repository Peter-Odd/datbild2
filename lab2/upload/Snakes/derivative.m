%DERIVATIVE   Computes Gaussian derivatives of an image
%
%  IMG = DERIVATIVE(IMG,ORDER,SIGMA) computes the Gaussian
%  derivaitve of image IMG, with a Gaussian of SIGMA. ORDER
%  is a 2-element vector, giving the derivative order in the
%  x and y direction. ORDER has to be between 0 and 2.
%
%  See the functions LAPLACE and GRADMAG for examples of usage.

% (C) Copyright 2011, All rights reserved.
% Cris Luengo, Uppsala, 3 November 2011      - Initial code

function img = derivative(img,order,sigma)

if nargin<2
   order = [0,0];
elseif numel(order)~=2
   error('Expecting 2 values for order');
end
if nargin<3
   sigma = 1;
elseif numel(sigma)~=1 || sigma<0.8
   error('Expecting scalar sigma >= 0.8');
end

c = ceil(3*sigma)+1;
x = -c:c;
sigma2 = sigma.^2;
g = exp(-x.^2/(2*sigma2))/(sqrt(2*pi*sigma2));
gx = g .* (-x/sigma2);
gxx = gx .* (-x/sigma2) - g / sigma2;

switch order(1)
   case 0
      hx = g;
   case 1
      hx = gx;
   case 2
      hx = gxx;
   otherwise
      error('Illegal derivative order');
end
switch order(2)
   case 0
      hy = g;
   case 1
      hy = gx;
   case 2
      hy = gxx;
   otherwise
      error('Illegal derivative order');
end

img = conv2(hy,hx,img,'same');
