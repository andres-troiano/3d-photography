
path = 'C:\Users\60069978\Documents\MATLAB\alineacion_trapecio\';
basepath_calibracion = 'C:\Users\60069978\Documents\MATLAB\medicion23\';
% load([basepath_calibracion 'calibration.mat']);

% polinomio_x_camara_2 = px2mmPol{2}(1);
% polinomio_y_camara_2 = px2mmPol{2}(2);

close all
figure(1)

longitud = [];

for i = 1:500
% for i = 1
    
    frame = getsnapshot(camara2);

    % guardo 2 iguales para engañar el script. Considerar modificaciones
    % les doy coordenadas dummy
    imwrite(frame, [path 'camara_1\LUT_camara_1_frame_x_1_y_1.png'], 'PNG');
    imwrite(frame, [path 'camara_2\LUT_camara_2_frame_x_1_y_1.png'], 'PNG');

    % correr los scripts de martín, cargar los resultados y medir la norma de
    % las 2 esquinas

    % OJO CON EL PATH DE ESTO!
    convertFiles2DotMat

    % ESTO CAMBIA SEGÚN LA PIEZA ESTÁ HORIZONTAL O NO
    intersecciones_alineacion_trapecio_izq
    intersecciones_alineacion_trapecio_der

%     intersecciones_alineacion_trapecio_izq_simetrico
%     intersecciones_alineacion_trapecio_der_simetrico

    % cargo las intersecciones y mido la longitud
    load([path 'intersections_izq.mat']);
    C2_izq = C{2};

    load([path 'intersections_der.mat']);
    C2_der = C{2};

    punta_px_2_izq = C2_izq(1, 1);
    punta_py_2_izq = C2_izq(1, 2);

    punta_px_2_der = C2_der(1, 1);
    punta_py_2_der = C2_der(1, 2);
    
    
%     
%     punta_mm_x_2_izq = polyval4XY(polinomio_x_camara_2, punta_px_2_izq, punta_py_2_izq);
%     punta_mm_y_2_izq = polyval4XY(polinomio_y_camara_2, punta_px_2_izq, punta_py_2_izq);
% 
%     punta_mm_x_2_der = polyval4XY(polinomio_x_camara_2, punta_px_2_der, punta_py_2_der);
%     punta_mm_y_2_der = polyval4XY(polinomio_y_camara_2, punta_px_2_der, punta_py_2_der);

    n = norma([punta_px_2_izq, punta_px_2_der], [punta_py_2_izq, punta_py_2_der]);
%     n = norma([punta_mm_x_2_izq, punta_mm_x_2_der], [punta_mm_y_2_izq, punta_mm_y_2_der]);
    
    longitud = [longitud n];
    
    plot(longitud, '.-')
%     ylim([59.99 60.025])

end

% save(fullfile(basepath_calibracion,'longitud_trapecio.mat'),'longitud')

error = max(L) - min(L);s