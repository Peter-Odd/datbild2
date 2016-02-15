% Exercise 1: Simple snake example, using VFC.
% - Play with the parameters (alpha, beta, gamma).
% - Try changing the external force, use for example GVF, GRADVEC, etc.
% - Try adding a balloon force.

% (C) Copyright 2011, Cris Luengo.

% Parameters
alpha = 0.5; % membrane (length)
beta = 1;    % thin plate (curvature)
gamma = 0.5; % step size
kappa = 0;   % balloon force

% Create a test image
x = -128:127;
[y,x] = ndgrid(x,x);
m = (x.^2+y.^2)<(60.^2);
a = y;
a(m) = -a(m);
%a = a + randn(256,256)*10; % optionally add noise...
a = a-min(a(:));
a = a*(255/max(a(:)));

% Edge image and external force
e = gradmag(a,2);
f = vfc(e);

% Display images
figure
set(gcf,'position',[20,20,850,850]);
colormap(gray(256))

subplot(2,2,1)
image(a)
axis image
title('input image')

subplot(2,2,2)
image(e*(255/max(e(:))))
axis image
title('gradient magnitude')

subplot(2,2,4)
angle = atan2(f{2},f{1})*(1/(2*pi));
angle = mod(angle,1);
norm = sqrt(f{1}.^2+f{2}.^2);
norm = norm./max(norm(:));
col = cat(3,angle,norm,norm*0.5+0.5);
col = hsv2rgb(col);
image(col)
axis image
title('external force')

subplot(2,2,3)
image(a)
axis image
title('evolving snake')
hold on

% Create initial snake
m = (x.^2+y.^2)<(50.^2);
s = im2snake(m);
h = plot(s(:,1),s(:,2),'r');
pause(1)

% First 5 iteration steps
s = snakeminimize(s,f,alpha,beta,gamma,kappa,5);
set(h,'xdata',s(:,1),'ydata',s(:,2));
pause(1)

% Some more steps
s = snakeminimize(s,f,alpha,beta,gamma,kappa,5);
set(h,'xdata',s(:,1),'ydata',s(:,2));
pause(1)

s = snakeminimize(s,f,alpha,beta,gamma,kappa,5);
set(h,'xdata',s(:,1),'ydata',s(:,2));
pause(1)

s = snakeminimize(s,f,alpha,beta,gamma,kappa,5);
set(h,'xdata',s(:,1),'ydata',s(:,2));
pause(1)

s = snakeminimize(s,f,alpha,beta,gamma,kappa,5);
set(h,'xdata',s(:,1),'ydata',s(:,2));
pause(1)

s = snakeminimize(s,f,alpha,beta,gamma,kappa,5);
set(h,'xdata',s(:,1),'ydata',s(:,2));
