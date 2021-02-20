% script para hacer una calibración, tomando como input los datos generados
% por el script "medicion.m" del proyecto "barrido"
% (con el TRAPECIO)

clear variables
path_calibracion = '/home/andres/DIRECTORIO TESIS/2021/resultados_base/medicion42_base/';
path_offset = '/home/andres/DIRECTORIO TESIS/2021/resultados_base/medicion43_base/';

%%

% clasifico los datos, eliminando aquellas capturas en las que no se vio
% nada
% creo_directorios_2_camaras(path_calibracion);
% separar_frames_utiles(path_calibracion, 1);
% separar_frames_utiles(path_calibracion, 2);
% % acá estaría bueno eliminar los archivos originales, para no tenerlos
% % duplicados
% convertFiles2DotMatPath(path_calibracion);

%%

% encuentro la posición de las esquinas del patrón
% calculateIntersectionsPath(path_calibracion);

% además de la zona de interés, genero fronteras de la
% zona que efectivamente pude calibrar (en caso de no haber llenado
% la zona de interés)
fronteraZonaEfectiva(path_calibracion);

load([path_calibracion 'intersections.mat']);
% teniendo las coordenadas de cada esquina en mm y en pixels, calibro el
% sistema
calculateCalibration_base(C, path_calibracion);

%% 

% posterior a haber calibrado (con el trapecio) hay que hacer un barrido
% con el trapecio puesto horizontal, para determinar delta_x, delta_y

% ojo! Las deltas hay que calcularlas sólo en las regiones válidas. No me
% acuerdo si actualmente está implementado así

% clear variables

% hecho el 2do barrido para calcular el offset, encuentro las esquinas

% creo_directorios_2_camaras(path_offset);
% separar_frames_utiles(path_offset, 1);
% separar_frames_utiles(path_offset, 2);
% convertFiles2DotMatPath(path_offset);
% 
% % acá hay que señalar: para la cam1, la esquina izquierda, y para la cam2
% % la derecha
% calculateIntersectionsPath(path_offset);

% ahora a partir de los datos tengo que calcular el offset. 
offset = calculo_offset(path_offset, path_calibracion);

%% Esta es la celda que me dio problemas, pero luego la corregí

% antes de calibrar tengo que quedarme sólo con las regiones de interés.
% Las fronteras están generadas en "fronteras_region_valida_base_con_fronteras"

clear variables

path_calibracion = '/home/andres/DIRECTORIO TESIS/2021/resultados_base/medicion42_base/';
path_offset = '/home/andres/DIRECTORIO TESIS/2021/resultados_base/medicion43_base/';

load([path_calibracion 'intersections.mat']);
load([path_offset 'offset.mat']);
% load([path_calibracion 'fronteras.mat']);
% load([path_calibracion 'ind_fronteras.mat']);
load([path_calibracion 'fronteras_con_fronteras.mat']);
load([path_calibracion 'ind_fronteras_con_fronteras.mat']);

close all, figure, hold on, grid on
for q = 1:2

%     ind1=C{q}(:,6)>.4;
%     ind2=C{q}(:,8)>.4;
%     ind3=C{q}(:,7)<100;
%     ind4=C{q}(:,9)<100;
% 
%     ind1=~ind1 & ~ind2 & ~ind3 & ~ind4 & ~isnan(C{q}(:,1));
% 
%     grilla_mmx = C{q}(ind1,3);
%     grilla_mmy = C{q}(ind1,4);

    grilla_mmx = C{q}(:,3);
    grilla_mmy = C{q}(:,4);

    if q == 2
        grilla_mmx = grilla_mmx-offset(1);
        grilla_mmy = grilla_mmy-offset(2);
    end
   
%     ind = inpolygon(grilla_mmx, grilla_mmy, F{q}(:,1), F{q}(:,2));
    
    if q == 1
%         plot(grilla_mmx,grilla_mmy,'.b')
%         plot(grilla_mmx(ind),grilla_mmy(ind),'.c')
        plot(grilla_mmx(ind_fronteras{q}),grilla_mmy(ind_fronteras{q}),'+b')
    end
    
    if q == 2
%         plot(grilla_mmx,grilla_mmy,'.r')
%         plot(grilla_mmx(ind),grilla_mmy(ind),'.m')
        plot(grilla_mmx(ind_fronteras{q}),grilla_mmy(ind_fronteras{q}),'or')
    end
    
    plot(F{q}(:,1), F{q}(:,2), '--')
    title('Trapecio')
    
end

axis equal
xlabel('X (mm)')
ylabel('Y (mm)')

% ahora que tengo la frontera, vuelvo a calibrar, vuelvo a medir el offset,
% y mido el cilindro
calculateCalibration_con_fronteras(C,path_calibracion, ind_fronteras)

% mido el offset nuevamente
% no me queda claro si tengo que calcular el offset sólo en la zona válida
% o no. De ser así, para la cámara 2 definiría la zona válida como la que
% tengo definida hasta acá menos el offset que tengo hasta acá, porque en
% el script de abajo todavía los datos no están desplazados
offset_fronteras = calculo_offset_con_fronteras_base(path_offset, path_calibracion, F);

%% ahora mido los patrones

clear variables, clc

% para trabajar con datos nuevos:
path_datos = '/home/andres/DIRECTORIO TESIS/2021/resultados_base/medicion48_base/';
path_fronteras = '/home/andres/DIRECTORIO TESIS/2021/resultados_base/medicion42_base/';
path_calibracion = '/home/andres/DIRECTORIO TESIS/2021/resultados_base/medicion42_base/';
path_offset = '/home/andres/DIRECTORIO TESIS/2021/resultados_base/medicion43_base/';

% usando calibración y datos viejos
% path_datos = 'C:\Users\Norma\Downloads\datos_calibraciones\cilindros_viejo\';
% path_fronteras = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion42\'; % esto no lo uso, pero se lo paso igual (adentro de la función lo comento)
% path_calibracion = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion32\';
% path_offset = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion43\'; % no pertenece a la medición

% forma "tradicional" (calibración y offset sin fronteras)
% load([path_calibracion 'calibration.mat']);
% load([path_offset 'offset.mat']);
% load([path_fronteras 'fronteras.mat']);

% calibración y offset CON fronteras
load([path_calibracion 'calibration_con_fronteras.mat']);
load([path_offset 'offset_fronteras_base.mat']);
load([path_fronteras 'fronteras_con_fronteras.mat']);
offset = offset_fronteras;
clear offset_fronteras;

load([path_calibracion 'FC.mat']);

% empaqueto lo que ya tengo hecho en el fronteras_region_valida. Ahí mido
% el patrón del medio

frame_cilindro = {'patron_34700530', 'patron_34700630', 'patron_34700730'};
id_cilindro = {'34700530', '34700630', '34700730'};
nominales = [139.707, 168.310, 177.805];

frames_cilindro = {[], []};

for f = 1:3
    close all
    for q = 1:2
        frames_cilindro{q} = [path_datos frame_cilindro{f} '_camara_' num2str(q) '.png'];
    end
    [centro_x, centro_y, r_teorico, r_individual, centro_individual] = mido_patron(frames_cilindro, id_cilindro{f}, px2mmPol, offset, F, FC, [path_datos 'medicion/']); % con las fronteras en el offset
%     [centro_x, centro_y, r_teorico, r_individual, centro_individual] = mido_patron_centros_coincidentes(frames_cilindro, id_cilindro{f}, px2mmPol, offset_fronteras, F, FC, path_datos); % haciendo coincidir los 2 centros
    fprintf([id_cilindro{f} '\nError 2 cámaras: %.3f mm\nError C1: %.3f mm, Error C2: %.3f mm\nCentro global: (%.3f, %.3f)\nCentro C1: (%.3f, %.3f)\nCentro C2: (%.3f, %.3f)\n\n'], 2*r_teorico - nominales(f), 2*r_individual(1) - nominales(f), 2*r_individual(2) - nominales(f), centro_x, centro_y, centro_individual{1}(1), centro_individual{1}(2), centro_individual{2}(1), centro_individual{2}(2))
end

% longitudes media, mínima y máxima del trapecio considerando los errores
% dados por la std:
% l_min = norm(offset_fronteras(1:2) - offset_fronteras(3:4));
% l_max = norm(offset_fronteras(1:2) + offset_fronteras(3:4));

% fprintf('Longitud media trapecio: %.3f\n', norm(offset_fronteras))
% fprintf('Longitud mínima trapecio: %.3f - Error: %.3f\n', l_min, l_min - norm(offset_fronteras))
% fprintf('Longitud máxima trapecio: %.3f - Error: %.3f\n', l_max, l_max - norm(offset_fronteras))
