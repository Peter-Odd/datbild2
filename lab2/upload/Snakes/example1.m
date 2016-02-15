% Example 1: Room example, using baloon force.

% (C) Copyright 2011, Cris Luengo.

% Parameters
alpha = 0.05; % membrane (length)
beta = 0.01;  % thin plate (curvature)
gamma = 1;    % step size
kappa = 0.15; % balloon force

% Load famous "room" example image
a = double(imread('room.pgm'));

% External force (external energy = -input image)
e = a/255; %inverse image
f = gradvec(e); %compute gradient vector

% Display images
figure
set(gcf,'position',[20,400,850,500]);
colormap(gray(256))

subplot(1,2,2)
angle = atan2(f{2},f{1})*(1/(2*pi));
angle = mod(angle,1);
norm = sqrt(f{1}.^2+f{2}.^2);
norm = norm./max(norm(:));
col = cat(3,angle,norm,norm*0.5+0.5);
col = hsv2rgb(col);
image(col)
axis image
title('external force')

subplot(1,2,1)
image(a)
axis image
title('input image')
hold on

% Create initial snake
t = linspace(0,2*pi,30)'; t(end)=[];
s = 32+3*[cos(t),sin(t)];
h = plot(s(:,1),s(:,2),'r');
pause(1)

% First 5 iteration steps
s = snakeminimize(s,f,alpha,beta,gamma,kappa,15);
set(h,'xdata',s(:,1),'ydata',s(:,2));
pause(1)

% Some more steps
s = snakeminimize(s,f,alpha,beta,gamma,kappa,15);
set(h,'xdata',s(:,1),'ydata',s(:,2));
pause(1)

s = snakeminimize(s,f,alpha,beta,gamma,kappa,15);
set(h,'xdata',s(:,1),'ydata',s(:,2));
pause(1)

s = snakeminimize(s,f,alpha,beta,gamma,kappa,15);
set(h,'xdata',s(:,1),'ydata',s(:,2));
pause(1)

s = snakeminimize(s,f,alpha,beta,gamma,kappa,15);
set(h,'xdata',s(:,1),'ydata',s(:,2));
pause(1)

s = snakeminimize(s,f,alpha,beta,gamma,kappa,15);
set(h,'xdata',s(:,1),'ydata',s(:,2));
