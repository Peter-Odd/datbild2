% Exercise 2: Try to segment the pear!
%  - Preprocessing the image?
%  - Changing the external force?
%  - Changing the parameters?

% (C) Copyright 2011, Cris Luengo.

% Parameters
%alpha = 0.2; % membrane (length)
%beta = 0.4;  % thin plate (curvature)
%gamma = 1;   % step size
%kappa = 0;   % balloon force

alpha = 1; % membrane (length)      <-- new
beta = 1;  % thin plate (curvature) <-- new
gamma = 0.2;   % step size          <-- new
kappa = 1.35;   % balloon force     <-- new

% Read in the image
a = imread('pears.png');
a = rgb2gray(a);
a = double(a);

% Edge image and external force
%e = gradmag(a,1);
e = gradmag(a, 6);                  %<-- new
f = vfc(e,41,2);


% Display images
figure
set(gcf,'position',[20,20,1000,700]);
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
t = linspace(0,2*pi,100)'; t(end)=[];
%s = [235+40*cos(t),350+50*sin(t)];
s = [235+50*cos(t),350+50*sin(t)];      %<-- new
h = plot(s(:,1),s(:,2),'r');
pause(1)

s = snakeminimize(s,f,alpha,beta,gamma,kappa,70);
set(h,'xdata',s(:,1),'ydata',s(:,2));

% % First 5 iteration steps
% s = snakeminimize(s,f,alpha,beta,gamma,kappa,5);
% set(h,'xdata',s(:,1),'ydata',s(:,2));
% pause(1)
% 
% % Some more steps
% s = snakeminimize(s,f,alpha,beta,gamma,kappa,5);
% set(h,'xdata',s(:,1),'ydata',s(:,2));
% pause(1)
% 
% s = snakeminimize(s,f,alpha,beta,gamma,kappa,10);
% set(h,'xdata',s(:,1),'ydata',s(:,2));
% pause(1)
% 
% s = snakeminimize(s,f,alpha,beta,gamma,kappa,10);
% set(h,'xdata',s(:,1),'ydata',s(:,2));
% pause(1)
% 
% s = snakeminimize(s,f,alpha,beta,gamma,kappa,20);
% set(h,'xdata',s(:,1),'ydata',s(:,2));
% pause(1)
% 
% s = snakeminimize(s,f,alpha,beta,gamma,kappa,20);
% set(h,'xdata',s(:,1),'ydata',s(:,2));
