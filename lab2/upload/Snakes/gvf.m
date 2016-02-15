%GVF   Computes an external force using Gradient Vector Flow
%
%  F = GVF(EDGE_IMAGE,MU,ITERATIONS) returns the Gradient Vector
%  Flow field in the cell array F. F{1} contains an image with the
%  x-component of the vector field, F{2} contains an image with
%  the y-component.
%
%  EDGE_IMAGE is a scalar image with large values at the locations
%  where the snake has to move to, for example the gradient magnitude.
%
%  MU is a smoothness parameter, and ITERATIONS is number of
%  iterations for the propagation of gradient vectors. Defaults are
%  MU = 0.2 and ITERATIONS = 80.
%
%  See: C. Xu, J.L. Prince, "Snakes, Shapes and Gradient Vector Flow",
%       IEEE-TIP 7(3):359-369 (1998)

% (C) Copyright 2009-2011, All rights reserved.
% Cris Luengo, Uppsala, 21 September 2009    - Initial code
% Cris Luengo, Uppsala, 3 November 2011      - Independent from DIPimage

function out = gvf(edge_image,mu,iterations)

if nargin<2
   mu = 0.2;
elseif numel(mu)~=1 || mu<=0
   error('Expecting positive scalar MU');
end
if nargin<3
   iterations = 80;
elseif numel(iterations)~=1 || iterations<1
   error('Expecting positive scalar ITERATIONS');
end

% Compute gradient field
fx = derivative(edge_image,[1,0],1);
fy = derivative(edge_image,[0,1],1);
fn = sqrt(fx.^2+fy.^2);

% Run the iterations
c = {fn.*fx,fn.*fy};
out = {fx,fy};
for ii=1:iterations
   out{1} = out{1} + mu.*laplace(out{1}) - fn.*out{1} + c{1};
   out{2} = out{2} + mu.*laplace(out{2}) - fn.*out{2} + c{2};
end

% Normalize output
fn = sqrt(out{1}.^2+out{2}.^2);
fn = max(fn,1e-10);
out{1} = out{1}./fn;
out{2} = out{2}./fn;
