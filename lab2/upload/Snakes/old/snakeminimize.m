%SNAKEMINIMIZE   Minimizes the energy function of a snake
%
% SYNOPSIS:
%  snake_out = snakeminimize(snake_in,Fext,alpha,beta,stepsz,kappa,iterations)
%
% PARAMETERS:
%  snake_in :   initial snake, Nx2 array with coordinates
%  Fext :       external force field, cell array {Fx,Fy}
%               for example: GRADVEC, GVF, VFC
%  alpha :      elasticity parameter (membrane)
%  beta :       rigidity parameter (thin plate)
%  stepsz :     step size
%  kappa :      balloon force (negative for inwards force)
%  iterations : number of iterations performed
%
% DEFAULTS:
%  alpha = 0.2
%  beta = 0.4
%  stepsz = 1
%  kappa = 0
%  iterations = 20
%
% NOTE:
%  You can create the initial snake coordinates using IM2SNAKE.
%
%  See: M. Kass, A. Witkin, D. Terzopoulos, "Snakes: Active Contour Models",
%       Int. J. of Computer Vision 4(1):321-331 (1988)
%  and: L.D. Cohen, I. Cohen, "Finite-element methods for active contour models
%       and balloons for 2-D and 3-D images", IEEE TPAMI 15(11):1131-1147 (1993)

% (C) Copyright 2009-2011, All rights reserved.
% Cris Luengo, Uppsala, 18-24 September 2009 - Initial code
% Cris Luengo, Uppsala, 3 November 2011      - Independent from DIPimage

function s = snakeminimize(s,f,alpha,beta,stepsz,kappa,iterations)

if nargin<3
   alpha = 0.2;
elseif numel(alpha)~=1 || alpha<0
   error('Expecting positive scalar ALPHA');
end
if nargin<4
   beta = 0.4;
elseif numel(beta)~=1 || beta<0
   error('Expecting positive scalar BETA');
end
if nargin<5
   stepsz = 1;
elseif numel(stepsz)~=1 || stepsz<=0
   error('Expecting positive scalar STEPSZ');
end
if nargin<6
   kappa = 0;
elseif numel(kappa)~=1
   error('Expecting scalar KAPPA');
end
if nargin<7
   iterations = 20;
elseif numel(iterations)~=1 || iterations<1
   error('Expecting positive scalar ITERATIONS');
end

if ~iscell(f) || numel(f)~=2 || ~isequal(size(f{1}),size(f{2}))
   error('The external force must be a 2-element cell array with images');
end
[maxy,maxx] = size(f{1});

x = s(:,1);
y = s(:,2);
if length(x)<3
   error('Snake has too few control points.')
end

% Constrict points to image
x(x<1) = 1;
x(x>maxx) = maxx;
y(y<1) = 1;
y(y>maxy) = maxy;

% Do the snake!
md = 1; % The average distance we want to keep between points.
[x,y] = resample(x,y,md);
P = compute_matrix(length(x),alpha,beta,stepsz);
for ii = 1:iterations

   % Do we need to resample the snake?
   d = sqrt( diff(x).^2 + diff(y).^2 );
   if any(d<md/3) || any(d>md*3)
      [x,y] = resample(x,y,md);
      P = compute_matrix(length(x),alpha,beta,stepsz);
   end
   
   % Calculate external force
   fex = interp2(f{1},x,y,'linear');
   fey = interp2(f{2},x,y,'linear');

   % Calculate balloon force
   s = [x,y];
   if kappa~=0
      b = [s(2:end,:);s(1,:)] - [s(end,:);s(1:end-1,:)];
      m = sqrt(sum(b.^2,2));
      bx =  b(:,2)./m;
      by = -b(:,1)./m;
      % Add balloon force to external force
      fex = fex+kappa*bx;
      fey = fey+kappa*by;
   end

   % Move control points
   x = P*(x+stepsz*fex);
   y = P*(y+stepsz*fey);

   % Constrict points to image
   x(x<1) = 1;
   x(x>maxx) = maxx;
   y(y<1) = 1;
   y(y>maxy) = maxy;

end
s = [x,y];



% The matrix P = (stepsz*A+I)^(-1)
function P = compute_matrix(N,alpha,beta,stepsz)
a = stepsz*(2*alpha+6*beta)+1;
b = stepsz*(-alpha-4*beta);
c = stepsz*beta;
P = diag(repmat(a,1,N));
P = P + diag(repmat(b,1,N-1), 1) + diag(   b, -N+1);
P = P + diag(repmat(b,1,N-1),-1) + diag(   b,  N-1);
P = P + diag(repmat(c,1,N-2), 2) + diag([c,c],-N+2);
P = P + diag(repmat(c,1,N-2),-2) + diag([c,c], N-2);
P = inv(P);



% Resamples the snake
function [x,y] = resample(x,y,d)
mode = 'linear'; r = 1;
% ( Alternative: mode = 'cubic'; r = 3; )
% replicate samples at either end (periodic boundary condition)
x = [x(end-r+1:end);x;x(1:r)];
y = [y(end-r+1:end);y;y(1:r)];
% p is the parameter along the snake
p = [0;cumsum(sqrt( diff(x).^2 + diff(y).^2 ))];
% the first control point should be at p=0
p = p-p(r+1);
% resample snake between first and last+1 control points
x = interp1(p,x,0:d:p(end-r+1),mode);
y = interp1(p,y,0:d:p(end-r+1),mode);
% if the last new point is too close to the first one, remove it
if norm([x(end),y(end)]-[x(1),y(1)]) < d/2
   x(end) = [];
   y(end) = [];
end
% ensure column vectors
x = x(:);
y = y(:);
if length(x)<3
   error('Snake has become too small!')
end
