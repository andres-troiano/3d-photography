% este script hace 1 sola medicion. El script "alineacion_trapecio" hace
% varias, pero es en vivo

clear variables
basepath_datos = 'C:\Users\60069978\Documents\MATLAB\alineacion_trapecio\longitud_trapecio\';
basepath_calibracion = 'C:\Users\60069978\Documents\MATLAB\medicion23\';

% cargo los polinomios de la cámara 2
load([basepath_calibracion 'calibration.mat']);

polinomio_x_camara_2 = px2mmPol{2}(1);
polinomio_y_camara_2 = px2mmPol{2}(2);

% cámara 2
load([basepath_datos 'camara_2.mat']);

perfiles_2 = Profiles;
x_2 = X;
y_2 = Y;

N = numel(x_2);

longitud_trapecio = zeros(1, N);

for n2 = 1:N

    pixel_y_camara_2 = 1088 - perfiles_2;
    pixel_y_camara_2 = pixel_y_camara_2(:, n2);
    pixel_x_camara_2 = 1:numel(pixel_y_camara_2);
    pixel_x_camara_2 = pixel_x_camara_2.';

    load([basepath_datos 'intersections_izq.mat']);
    C2_izq = C{2};

    load([basepath_datos 'intersections_der.mat']);
    C2_der = C{2};

    punta_px_2_izq = C2_izq(n2, 1);
    punta_py_2_izq = C2_izq(n2, 2);

    punta_px_2_der = C2_der(n2, 1);
    punta_py_2_der = C2_der(n2, 2);

    % MILÍMETROS
    % cámara 2
    mm_x_camara_2 = polyval4XY(polinomio_x_camara_2, pixel_x_camara_2, pixel_y_camara_2);
    mm_y_camara_2 = polyval4XY(polinomio_y_camara_2, pixel_x_camara_2, pixel_y_camara_2);

    % cámara 2
    punta_mm_x_2_izq = polyval4XY(polinomio_x_camara_2, punta_px_2_izq, punta_py_2_izq);
    punta_mm_y_2_izq = polyval4XY(polinomio_y_camara_2, punta_px_2_izq, punta_py_2_izq);

    punta_mm_x_2_der = polyval4XY(polinomio_x_camara_2, punta_px_2_der, punta_py_2_der);
    punta_mm_y_2_der = polyval4XY(polinomio_y_camara_2, punta_px_2_der, punta_py_2_der);

    % [punta_px_2_izq, punta_py_2_izq]


%     close all
%     figure(1)
%     hold on
%     grid on
% 
%     % plot(pixel_x_camara_2, pixel_y_camara_2, '.-b')
%     % plot(punta_px_2_izq, punta_py_2_izq, '*r')
%     % plot(punta_px_2_der, punta_py_2_der, '*g')
% 
%     plot(mm_x_camara_2, mm_y_camara_2, '.-b')
%     plot(punta_mm_x_2_izq, punta_mm_y_2_izq, '*r')
%     plot(punta_mm_x_2_der, punta_mm_y_2_der, '*g')

    n = norma([punta_mm_x_2_izq, punta_mm_x_2_der], [punta_mm_y_2_izq, punta_mm_y_2_der]);
    longitud_trapecio(n2) = n;

end

close all
figure(1)
hold on
grid on

plot(longitud_trapecio, '.-')

error = max(longitud_trapecio) - min(longitud_trapecio);
error