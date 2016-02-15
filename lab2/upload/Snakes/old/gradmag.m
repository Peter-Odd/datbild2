%GRADMAG   Computes the gradient magnitude with Gaussian regulatization
%
%  IMG = GRADMAG(IMG,SIGMA)

% (C) Copyright 2011, All rights reserved.
% Cris Luengo, Uppsala, 3 November 2011      - Initial code

function img = gradmag(img,sigma)

if nargin<2
   sigma = 1;
elseif numel(sigma)~=1 || sigma<0.8
   error('Expecting scalar sigma >= 0.8');
end

dx = derivative(img,[1,0],sigma);
dy = derivative(img,[0,1],sigma);
img = sqrt( dx.^2 + dy.^2 );
