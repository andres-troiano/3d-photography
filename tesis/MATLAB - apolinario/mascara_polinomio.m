clear variables
path_calibracion = 'C:\Users\60069978\Documents\MATLAB\medicion27\';

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

x = C{q}(ind1,1);
y = C{q}(ind1,2);

j = boundary(x, y, 0.1);

px_bound_c1 = x(j);
py_bound_c1 = y(j);

figure(2)
hold all
plot(C{q}(~ind1,1),C{q}(~ind1,2),'sg')
plot(C{q}(:,1),C{q}(:,2),'.b')
plot(px_bound_c1,py_bound_c1, '-r');

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

x = C{q}(ind1,1);
y = C{q}(ind1,2);

j = boundary(x, y, 0.1);

px_bound_c2 = x(j);
py_bound_c2 = y(j);

figure(3)
hold all
plot(C{q}(~ind1,1),C{q}(~ind1,2),'sg')
plot(C{q}(:,1),C{q}(:,2),'.b')
plot(px_bound_c2,py_bound_c2, '-r');

%% testeo un perfil

path_datos = 'C:\Users\60069978\Documents\MATLAB\medicion30\34700030\';
load([path_datos 'camara_1.mat']);

perfiles_1 = Profiles;
x_1 = X;
y_1 = Y;

% cámara 2
load([path_datos 'camara_2.mat']);

perfiles_2 = Profiles;
x_2 = X;
y_2 = Y;

x_pedido = 17;
y_pedido = 18;

% encuentro el índice de la cámara 1
filtro_x = x_1 == x_pedido;
filtro_y = y_1 == y_pedido;
filtro = filtro_x == 1 & filtro_y == 1;

n1 = find(filtro);

% encuentro el índice de la cámara 2
filtro_x = x_2 == x_pedido;
filtro_y = y_2 == y_pedido;
filtro = filtro_x == 1 & filtro_y == 1;

n2 = find(filtro);

pixel_y_camara_1 = 1088 - perfiles_1;
pixel_y_camara_1 = pixel_y_camara_1(:, n1);
pixel_x_camara_1 = 1:numel(pixel_y_camara_1);
pixel_x_camara_1 = pixel_x_camara_1.';

pixel_y_camara_2 = 1088 - perfiles_2;
pixel_y_camara_2 = pixel_y_camara_2(:, n2);
pixel_x_camara_2 = 1:numel(pixel_y_camara_2);
pixel_x_camara_2 = pixel_x_camara_2.';

C1 = C{1};
C2 = C{2};

in_1 = inpolygon(pixel_x_camara_1, pixel_y_camara_1, px_bound_c1, py_bound_c1);
in_2 = inpolygon(pixel_x_camara_2, pixel_y_camara_2, px_bound_c2, py_bound_c2);

px_buenos_1 = pixel_x_camara_1(in_1);
py_buenos_1 = pixel_y_camara_1(in_1);

px_buenos_2 = pixel_x_camara_2(in_2);
py_buenos_2 = pixel_y_camara_2(in_2);

% POLINOMIOS

load([path_calibracion 'calibration.mat']);

% cámara 1
polinomio_x_camara_1 = px2mmPol{1}(1);
polinomio_y_camara_1 = px2mmPol{1}(2);

% cámara 2
polinomio_x_camara_2 = px2mmPol{2}(1);
polinomio_y_camara_2 = px2mmPol{2}(2);

delta_x = 51.763;
delta_y = 30.463;

mm_x_buenos_1 = polyval4XY(polinomio_x_camara_1, px_buenos_1, py_buenos_1);
mm_y_buenos_1 = polyval4XY(polinomio_y_camara_1, px_buenos_1, py_buenos_1);

mm_x_buenos_2 = polyval4XY(polinomio_x_camara_2, px_buenos_2, py_buenos_2);
mm_y_buenos_2 = polyval4XY(polinomio_y_camara_2, px_buenos_2, py_buenos_2);

mm_x_bound_1 = polyval4XY(polinomio_x_camara_1, px_bound_c1, py_bound_c1);
mm_y_bound_1 = polyval4XY(polinomio_y_camara_1, px_bound_c1, py_bound_c1);

mm_x_bound_2 = polyval4XY(polinomio_x_camara_2, px_bound_c2, py_bound_c2);
mm_y_bound_2 = polyval4XY(polinomio_y_camara_2, px_bound_c2, py_bound_c2);

mm_x_buenos_2_trasladado = mm_x_buenos_2 - delta_x;
mm_y_buenos_2_trasladado = mm_y_buenos_2 - delta_y;

mm_x_bound_2_trasladado = mm_x_bound_2 - delta_x;
mm_y_bound_2_trasladado = mm_y_bound_2 - delta_y;

close all
hold on
grid on
figure(1)

% plot(pixel_x_camara_1, pixel_y_camara_1, '.-b')
% plot(px_buenos_1, py_buenos_1, 'or')
% plot(x_bound_c1,y_bound_c1, '-r');
% 
% plot(pixel_x_camara_2, pixel_y_camara_2, '.-g')
% plot(px_buenos_2, py_buenos_2, 'oy')
% plot(x_bound_c2,y_bound_c2, '-y');

plot(mm_x_buenos_1, mm_y_buenos_1, '.-b')
plot(mm_x_buenos_2_trasladado, mm_y_buenos_2_trasladado, '--r')

plot(mm_x_bound_1, mm_y_bound_1, '--b')
plot(mm_x_bound_2_trasladado, mm_y_bound_2_trasladado, '--r')