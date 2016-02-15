%LAPLACE   Computes the Laplacian with Gaussian regulatization
%
%  IMG = LAPLACE(IMG,SIGMA)

% (C) Copyright 2011, All rights reserved.
% Cris Luengo, Uppsala, 3 November 2011      - Initial code

function img = laplace(img,sigma)

if nargin<2
   sigma = 1;
elseif numel(sigma)~=1 || sigma<0.8
   error('Expecting scalar sigma >= 0.8');
end

img = derivative(img,[2,0],sigma) + derivative(img,[0,2],sigma);
