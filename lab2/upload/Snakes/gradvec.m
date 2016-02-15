%GRADVEC   Computes the gradient vector with Gaussian regulatization
%
%  F = GRADVEC(IMG,SIGMA) returns the gradient vector field in the
%  cell array F. F{1} contains an image with the x-component of the
%  vector field, F{2} contains an image with the y-component.

% (C) Copyright 2011, All rights reserved.
% Cris Luengo, Uppsala, 3 November 2011      - Initial code

function f = gradvec(img,sigma)

if nargin<2
   sigma = 1;
elseif numel(sigma)~=1 || sigma<0.8
   error('Expecting scalar sigma >= 0.8');
end

dx = derivative(img,[1,0],sigma);
dy = derivative(img,[0,1],sigma);
f = {dx,dy};
