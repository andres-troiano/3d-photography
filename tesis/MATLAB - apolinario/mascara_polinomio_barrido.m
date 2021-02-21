% toda esta celda pasa a ser obsoleta, teniendo como boundary a rosca.mat
% sigue sirviendo si no se quiere usar la máscara de rosca

clear variables
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

x = C{q}(ind1,1);
y = C{q}(ind1,2);

j = boundary(x, y, 0.1);

px_bound_c1 = x(j);
py_bound_c1 = y(j);

% figure(2)
% hold all
% plot(C{q}(~ind1,1),C{q}(~ind1,2),'sg')
% plot(C{q}(:,1),C{q}(:,2),'.b')
% plot(px_bound_c1,py_bound_c1, '-r');

figure
hold all
plot(C{q}(~ind1,3),C{q}(~ind1,4),'sg')
plot(C{q}(:,3),C{q}(:,4),'.b')
title('Cámara 1')
xlabel('X (mm)')
ylabel('Y (mm)')
axis equal

%%

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

% figure(3)
% hold all
% plot(C{q}(~ind1,1),C{q}(~ind1,2),'sg')
% plot(C{q}(:,1),C{q}(:,2),'.b')
% plot(px_bound_c2,py_bound_c2, '-r');

figure
hold all
plot(C{q}(~ind1,3),C{q}(~ind1,4),'sg')
plot(C{q}(:,3),C{q}(:,4),'.b')
title('Cámara 2')
xlabel('X (mm)')
ylabel('Y (mm)')
axis equal

%% analizo todos los perfiles

path_calibracion = 'C:\Users\60069978\Documents\MATLAB\medicion32\';
path_datos = 'C:\Users\60069978\Documents\MATLAB\medicion33\34700730\';
load([path_datos 'camara_1.mat']);
load([path_calibracion 'intersections.mat']);

% cargo la máscara
load([path_calibracion 'mascara_rosca.mat']);
% load([path_calibracion 'calibration.mat']); % ???????

% nominal = 139.707;
% nominal = 168.310;
nominal = 177.806;

perfiles_1 = Profiles;
x_1 = X;
y_1 = Y;

% cámara 2
load([path_datos 'camara_2.mat']);

perfiles_2 = Profiles;
x_2 = X;
y_2 = Y;

x_comunes = intersect(x_1, x_2);
y_comunes = intersect(y_1, y_2);

N_x = numel(x_comunes);
N_y = numel(y_comunes);

X = [];
Y = [];

x_array = NaN(1, N_x*N_y);
y_array = NaN(1, N_x*N_y);
error_array = NaN(1, N_x*N_y);

set(0,'DefaultFigureVisible', 'off');

k = 0;

% genero las máscaras en forma de rosca

x = M{1}(:, 1);
y = M{1}(:, 2);

j = boundary(x, y, 1);
bound_rosca_x_1 = x(j);
bound_rosca_y_1 = y(j);

delta_x = 51.763;
delta_y = 30.463;

x = M{2}(:, 1) - delta_x;
y = M{2}(:, 2) - delta_y;

j = boundary(x, y, 1);
bound_rosca_x_2 = x(j);
bound_rosca_y_2 = y(j);

% figure
% hold on
% grid on
% 
% plot(M{1}(:, 1), M{1}(:, 2), '.b');
% plot(M{2}(:, 1) - delta_x, M{2}(:, 2) - delta_y, '.r');
% 
% plot(bound_rosca_x_1, bound_rosca_y_1, '--b')
% plot(bound_rosca_x_2, bound_rosca_y_2, '--r')
% 
% axis equal



% for i = 1:1
%     for j = 1:1
for i = 1:N_x
    for j = 1:N_y
        
        k = k+1;
        grafico = 0;
        
        sprintf('Paso %d de %d\n', k, N_x*N_y)

        x_pedido = x_comunes(i);
        y_pedido = y_comunes(j);

%         x_pedido = 200;
%         y_pedido = 560;

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
        
        % esto me descarta los que no fueron medidos
        % no me descarta los que sí fueron medidos pero no se vio nada
        if numel(n1) == 0 || numel(n2) == 0
            grafico = -1;
            continue
        end

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

        % hasta ahora tengo enmascarada la calibración. Ahora tengo que
        % hacerle lo mismo a los perfiles
        in_1 = inpolygon(pixel_x_camara_1, pixel_y_camara_1, px_bound_c1, py_bound_c1);
        in_2 = inpolygon(pixel_x_camara_2, pixel_y_camara_2, px_bound_c2, py_bound_c2);

%         ind5 = ~inpolygon(pixel_x_camara_1, pixel_y_camara_1, x_int, y_int);
%         ind6 = inpolygon(pixel_x_camara_1, pixel_y_camara_1, x_ext, y_ext);
%         
%         in_1 = ind5 & ind6;
%         
%         ind5 = ~inpolygon(pixel_x_camara_2, pixel_y_camara_2, x_int, y_int);
%         ind6 = inpolygon(pixel_x_camara_2, pixel_y_camara_2, x_ext, y_ext);
%         
%         in_2 = ind5 & ind6;

        px_buenos_1 = pixel_x_camara_1(in_1);
        py_buenos_1 = pixel_y_camara_1(in_1);

        px_buenos_2 = pixel_x_camara_2(in_2);
        py_buenos_2 = pixel_y_camara_2(in_2);
        
        % tiro los "ceros" (los 1088)
        filtro = py_buenos_1 < 1000;
        px_buenos_1 = px_buenos_1(filtro);
        py_buenos_1 = py_buenos_1(filtro);
        
        filtro = py_buenos_2 < 1000;
        px_buenos_2 = px_buenos_2(filtro);
        py_buenos_2 = py_buenos_2(filtro);
        
%         tiro ruidos en Y
        [py_buenos_1, px_buenos_1, ~, ~] = filtro_valores_inusuales(py_buenos_1, px_buenos_1, 1, 3);
        [py_buenos_1, px_buenos_1, ~, ~] = filtro_valores_inusuales(py_buenos_1, px_buenos_1, -1, 3);
        [py_buenos_2, px_buenos_2, ~, ~] = filtro_valores_inusuales(py_buenos_2, px_buenos_2, 1, 3);
        [py_buenos_2, px_buenos_2, ~, ~] = filtro_valores_inusuales(py_buenos_2, px_buenos_2, -1, 3);
        
        % acá descarto los que medí pero no vi nada
        if numel(px_buenos_1) == 0 || numel(px_buenos_2) == 0
            continue
        end

        % POLINOMIOS

%         load([path_calibracion 'calibration.mat']);
%         load([path_calibracion 'calibracion_rosca.mat']);
        load([path_calibracion 'calibracion_subsample.mat']);

        % cámara 1
        polinomio_x_camara_1 = px2mmPol{1}(1);
        polinomio_y_camara_1 = px2mmPol{1}(2);
        
        % cámara 2
        polinomio_x_camara_2 = px2mmPol{2}(1);
        polinomio_y_camara_2 = px2mmPol{2}(2);
        
        mm_x_buenos_1 = polyval4XY(polinomio_x_camara_1, px_buenos_1, py_buenos_1);
        mm_y_buenos_1 = polyval4XY(polinomio_y_camara_1, px_buenos_1, py_buenos_1);

        mm_x_buenos_2 = polyval4XY(polinomio_x_camara_2, px_buenos_2, py_buenos_2);
        mm_y_buenos_2 = polyval4XY(polinomio_y_camara_2, px_buenos_2, py_buenos_2);

        mm_x_bound_1 = polyval4XY(polinomio_x_camara_1, px_bound_c1, py_bound_c1);
        mm_y_bound_1 = polyval4XY(polinomio_y_camara_1, px_bound_c1, py_bound_c1);

        mm_x_bound_2 = polyval4XY(polinomio_x_camara_2, px_bound_c2, py_bound_c2);
        mm_y_bound_2 = polyval4XY(polinomio_y_camara_2, px_bound_c2, py_bound_c2);

        if numel(mm_x_buenos_2) < 10 || numel(mm_x_buenos_1) < 10
            continue
        end
        
        % sobreescribo los trasladados
        mm_x_buenos_2 = mm_x_buenos_2 - delta_x;
        mm_y_buenos_2 = mm_y_buenos_2 - delta_y;
        
        %%%%%%%%%%%%%%%%%%
        % opcional:
        
        % a los filtros que ya estaban les agrego la máscara en forma de
        % rosca
        in_1 = inpolygon(mm_x_buenos_1, mm_y_buenos_1, bound_rosca_x_1, bound_rosca_y_1);
        in_2 = inpolygon(mm_x_buenos_2, mm_y_buenos_2, bound_rosca_x_2, bound_rosca_y_2);
        
        mm_x_buenos_1 = mm_x_buenos_1(in_1);
        mm_y_buenos_1 = mm_y_buenos_1(in_1);
        mm_x_buenos_2 = mm_x_buenos_2(in_2);
        mm_y_buenos_2 = mm_y_buenos_2(in_2);
        %%%%%%%%%%%%%%%%%%
  
        mm_x_bound_2 = mm_x_bound_2 - delta_x;
        mm_y_bound_2 = mm_y_bound_2 - delta_y;
        
        % busco el punto del medio de cada perfil
        [pyc2, idx] = max(py_buenos_2);
        pxc2 = px_buenos_2(idx);
        
        [pyc1, idx] = max(py_buenos_1);
        pxc1 = px_buenos_1(idx);
        
        mmxc1 = polyval4XY(polinomio_x_camara_1, pxc1, pyc1);
        mmyc1 = polyval4XY(polinomio_y_camara_1, pxc1, pyc1);
        
        mmxc2 = polyval4XY(polinomio_x_camara_2, pxc2, pyc2);
        mmyc2 = polyval4XY(polinomio_y_camara_2, pxc2, pyc2);
        
        mmxc2 = mmxc2 - delta_x;
        mmyc2 = mmyc2 - delta_y;
        
        % calculo el centro de cada círculo
        XY = [mm_x_buenos_2, mm_y_buenos_2];
        circulo = TaubinNTN(XY);

        centro_x_2 = circulo(1);
        centro_y_2 = circulo(2);
        radio_2 = circulo(3);
        diametro_2 = 2*radio_2;
        
        XY = [mm_x_buenos_1, mm_y_buenos_1];
        circulo = TaubinNTN(XY);

        centro_x_1 = circulo(1);
        centro_y_1 = circulo(2);
        radio_1 = circulo(3);
        diametro_1 = 2*radio_1;
        
        % calculo el ángulo del segmento central (respecto de la vertical)
        alpha_1 = calculo_angulo([0, 0], [0, 1], [mmxc1, mmyc1], [centro_x_1, centro_y_1]);
        alpha_2 = calculo_angulo([0, 0], [0, 1], [mmxc2, mmyc2], [centro_x_2, centro_y_2]);
        
        alpha_izq_2 = alpha_2 + 35;
        alpha_der_2 = alpha_2 - 35;
        
        alpha_izq_1 = alpha_1 + 35;
        alpha_der_1 = alpha_1 - 35;
        
%         x_recta_2 = linspace(min(mm_x_buenos_2), max(mm_x_buenos_2));
        a = 1/tand(alpha_2);
        y_recta_2 = a*mm_x_buenos_2 + (centro_y_2 - a*centro_x_2);
        
        a = 1/tand(alpha_izq_2);
        y_recta_izq_2 = a*mm_x_buenos_2 + (centro_y_2 - a*centro_x_2);
        
        a = 1/tand(alpha_der_2);
        y_recta_der_2 = a*mm_x_buenos_2 + (centro_y_2 - a*centro_x_2);
        
        
        a = -1/tand(alpha_1);
        y_recta_1 = a*mm_x_buenos_1 + (centro_y_1 - a*centro_x_1);
        
        a = -1/tand(alpha_izq_1);
        y_recta_izq_1 = a*mm_x_buenos_1 + (centro_y_1 - a*centro_x_1);
        
        a = -1/tand(alpha_der_1);
        y_recta_der_1 = a*mm_x_buenos_1 + (centro_y_1 - a*centro_x_1);
        
        % no es lo mismo si la "derecha" tiene pendiente positiva que
        % negativa
        if a < 0
            flag_a = -1;
        end
        
        if a > 0
            flag_a = 1;
        end
        
        % me quedo con los puntos que están dentro de los 70º
        filtro = mm_y_buenos_2 < y_recta_izq_2 & mm_y_buenos_2 < y_recta_der_2;
        x_mm_validos_2 = mm_x_buenos_2(filtro);
        y_mm_validos_2 = mm_y_buenos_2(filtro);
        
        if flag_a == -1
            filtro = mm_y_buenos_1 > y_recta_der_1 & mm_y_buenos_1 < y_recta_izq_1;
        end
        
        if flag_a == 1
            filtro = mm_y_buenos_1 < y_recta_der_1 & mm_y_buenos_1 < y_recta_izq_1;
        end
        
        x_mm_validos_1 = mm_x_buenos_1(filtro);
        y_mm_validos_1 = mm_y_buenos_1(filtro);
        
        
        % ajusto sólo con los datos válidos
        X = [x_mm_validos_1; x_mm_validos_2];
        Y = [y_mm_validos_1; y_mm_validos_2];
        
        XY = [X, Y];
        circulo = TaubinNTN(XY);

        centro_x = circulo(1);
        centro_y = circulo(2);
        radio = circulo(3);
        diametro = 2*radio;
        
        error = diametro - nominal;
        
        close all
        h = figure(1);        
        hold on
        grid on
        
%         plot(px_buenos_2, py_buenos_2, '.-b')
        
%         plot(mm_x_bound_1, mm_y_bound_1, '--b')
%         plot(mm_x_bound_2, mm_y_bound_2, '--r')

        plot(bound_rosca_x_1, bound_rosca_y_1, '--b')
        plot(bound_rosca_x_2, bound_rosca_y_2, '--r')
        
        plot(mm_x_buenos_1, mm_y_buenos_1, '.-b')
        plot(mm_x_buenos_2, mm_y_buenos_2, '.r')
        
        plot(mmxc2, mmyc2, 'og')
        plot(mmxc1, mmyc1, 'om')
        
        plot(centro_x_2, centro_y_2, '*g')
        plot(centro_x_1, centro_y_1, 'om')
        
        plot(x_mm_validos_1, y_mm_validos_1, 'om')
        plot(x_mm_validos_2, y_mm_validos_2, '.y')
        
        ylim([min(mm_y_bound_1), max(mm_y_bound_1)])
        axis equal
        tit = sprintf('Diámetro = %.3f mm\nError = %.3f mm', diametro, error);
        title(tit)
        xlabel('x (mm)')
        ylabel('y (mm)')
        
        x_array(k) = x_pedido;
        y_array(k) = y_pedido;
        error_array(k) = error;
        
        fig_name = ['plot_x_' num2str(x_pedido) '_y_' num2str(y_pedido) '.png'];
%         saveas(h, [path_datos 'perfiles\' fig_name], 'png');
%         saveas(h, [path_datos 'perfiles_rosca\' fig_name], 'png');
        saveas(h, [path_datos 'perfiles_subsample\' fig_name], 'png');
        
    end

end

%% calculo y grafico el error en el diámetro

set(0,'DefaultFigureVisible', 'on');

x_array = x_array(~isnan(x_array));
y_array = y_array(~isnan(y_array));
error_array = error_array(~isnan(error_array));
error_array = 1e3*error_array;

[mean(error_array), std(error_array)]

close all
h = figure(1);        
hold on
grid on

plot3(x_array, y_array, error_array, '.b')

view(38, 22)
xlabel('X (mm)')
ylabel('Y (mm)')
zlabel('Error en el diámetro (um)')
tit = sprintf('Valor medio = %.0f um\nStd = %.0f um', mean(error_array), std(error_array));
title(tit)