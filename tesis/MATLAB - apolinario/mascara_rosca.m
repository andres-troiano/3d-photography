x_c = 104;
y_c = 594;
r_int = 84.16 - 50;
r_ext = 84.16 + 50;

t = linspace(0, 2*pi, 100);
x_int = x_c + r_int*cos(t);
y_int = y_c + r_int*sin(t);

x_ext = x_c + r_ext*cos(t);
y_ext = y_c + r_ext*sin(t);

% clear variables
path_calibracion = 'C:\Users\60069978\Documents\MATLAB\medicion32\';
load([path_calibracion 'intersections.mat']);

% cámara 1
q = 1;

figure(1)
plot(C{q}(:,1),C{q}(:,2),'.'),hold all,title(sprintf('Camera %d',q))
ind1=C{q}(:,6)>.4;plot(C{q}(ind1,1),C{q}(ind1,2),'o','MarkerSize',8)
ind2=C{q}(:,8)>.4;plot(C{q}(ind2,1),C{q}(ind2,2),'+','MarkerSize',10)
ind3=C{q}(:,7)<100;plot(C{q}(ind3,1),C{q}(ind3,2),'x','MarkerSize',10)
ind4=C{q}(:,9)<100;plot(C{q}(ind4,1),C{q}(ind4,2),'s','MarkerSize',12)
legend('all intersections', 'estd1>0.4', 'estd2>0.4', 'n1<100', 'n2<100')

close all

ind1=~ind1 & ~ind2 & ~ind3 & ~ind4 & ~isnan(C{q}(:,1));

grilla_mmx_1 = C{q}(ind1,3);
grilla_mmy_1 = C{q}(ind1,4);

q = 2;

figure(1)
plot(C{q}(:,1),C{q}(:,2),'.'),hold all,title(sprintf('Camera %d',q))
ind1=C{q}(:,6)>.4;plot(C{q}(ind1,1),C{q}(ind1,2),'o','MarkerSize',8)
ind2=C{q}(:,8)>.4;plot(C{q}(ind2,1),C{q}(ind2,2),'+','MarkerSize',10)
ind3=C{q}(:,7)<100;plot(C{q}(ind3,1),C{q}(ind3,2),'x','MarkerSize',10)
ind4=C{q}(:,9)<100;plot(C{q}(ind4,1),C{q}(ind4,2),'s','MarkerSize',12)
legend('all intersections', 'estd1>0.4', 'estd2>0.4', 'n1<100', 'n2<100')

close(1)

ind1=~ind1 & ~ind2 & ~ind3 & ~ind4 & ~isnan(C{q}(:,1));

grilla_mmx_2 = C{q}(ind1,3);
grilla_mmy_2 = C{q}(ind1,4);

% tengo que trasladar la calibración 2 antes de seguir
delta_x = 51.763;
delta_y = 30.463;

grilla_mmx_2 = grilla_mmx_2 - delta_x;
grilla_mmy_2 = grilla_mmy_2 - delta_y;

% DENTRO del radio EXTERIOR
in_1 = inpolygon(grilla_mmx_1, grilla_mmy_1, x_ext, y_ext);
in_2 = inpolygon(grilla_mmx_2, grilla_mmy_2, x_ext, y_ext);

x_buenos_1 = grilla_mmx_1(in_1);
y_buenos_1 = grilla_mmy_1(in_1);
x_buenos_2 = grilla_mmx_2(in_2);
y_buenos_2 = grilla_mmy_2(in_2);

% FUERA del radio INTERIOR
in_1 = inpolygon(x_buenos_1, y_buenos_1, x_int, y_int);
in_2 = inpolygon(x_buenos_2, y_buenos_2, x_int, y_int);

x_buenos_1 = x_buenos_1(~in_1);
y_buenos_1 = y_buenos_1(~in_1);
x_buenos_2 = x_buenos_2(~in_2);
y_buenos_2 = y_buenos_2(~in_2);

% px_buenos_2 = pixel_x_camara_2(in_2);
% py_buenos_2 = pixel_y_camara_2(in_2);

close all
figure(1)
hold on
grid on

plot(grilla_mmx_1, grilla_mmy_1, '.b')
plot(x_buenos_1, y_buenos_1, '.m')
plot(grilla_mmx_2, grilla_mmy_2, '.r')
plot(x_buenos_2, y_buenos_2, '.y')
plot(x_int, y_int, '--k')
plot(x_ext, y_ext, '--k')

axis equal

% R = {[x_buenos_1, y_buenos_1], [x_buenos_2, y_buenos_2]};
% guardo los 2 círculos en columnas
R = [x_int.', y_int.', x_ext.', y_ext.'];
save(fullfile(path_calibracion,'rosca.mat'),'R')

%%

close all
calibracion_rosca_2(C, R, path_calibracion)

%%

set(0,'DefaultFigureVisible', 'on');
close all

path_calibracion = 'C:\Users\60069978\Documents\MATLAB\medicion32\';
load([path_calibracion 'intersections.mat']);
load([path_calibracion 'rosca.mat']);

paso = 20;
fprintf('Paso = %d\n', paso);
calibracion_subsample(C, R, path_calibracion, paso)

close all