% script para hacer una calibración, tomando como input los datos generados
% por el script "medicion.m" del proyecto "barrido"
% (con el TRAPECIO)

clear variables
path_calibracion = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion42\';
path_offset = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion43\';

%%

% clasifico los datos, eliminando aquellas capturas en las que no se vio
% nada
creo_directorios_2_camaras(path_calibracion);
separar_frames_utiles(path_calibracion, 1);
separar_frames_utiles(path_calibracion, 2);
% acá estaría bueno eliminar los archivos originales, para no tenerlos
% duplicados
convertFiles2DotMatPath(path_calibracion);

%%

% encuentro la posición de las esquinas del patrón
calculateIntersectionsPath(path_calibracion);
% load([path_calibracion 'intersections.mat']);
% % teniendo las coordenadas de cada esquina en mm y en pixels, calibro el
% % sistema
% calculateCalibration(C, path_calibracion);

%% 

% posterior a haber calibrado (con el trapecio) hay que hacer un barrido
% con el trapecio puesto horizontal, para determinar delta_x, delta_y

% ojo! Las deltas hay que calcularlas sólo en las regiones válidas. No me
% acuerdo si actualmente está implementado así

% clear variables

% hecho el 2do barrido para calcular el offset, encuentro las esquinas

creo_directorios_2_camaras(path_offset);
separar_frames_utiles(path_offset, 1);
separar_frames_utiles(path_offset, 2);
convertFiles2DotMatPath(path_offset);

% acá hay que señalar: para la cam1, la esquina izquierda, y para la cam2
% la derecha
calculateIntersectionsPath(path_offset);

% ahora a partir de los datos tengo que calcular el offset. 
offset = calculo_offset(path_offset, path_calibracion);

%%

% antes de calibrar tengo que quedarme sólo con las regiones de interés.
% Las fronteras están generadas en "fronteras_region_valida"

path_calibracion = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion42\';
path_offset = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion43\';

load([path_calibracion 'intersections.mat']);
load([path_offset 'offset.mat']);
load([path_calibracion 'fronteras.mat']);
load([path_calibracion 'ind_fronteras.mat']);

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
        plot(grilla_mmx(ind_fronteras{q}),grilla_mmy(ind_fronteras{q}),'.c')
    end
    
    if q == 2
%         plot(grilla_mmx,grilla_mmy,'.r')
%         plot(grilla_mmx(ind),grilla_mmy(ind),'.m')
        plot(grilla_mmx(ind_fronteras{q}),grilla_mmy(ind_fronteras{q}),'.m')
    end
    
    plot(F{q}(:,1), F{q}(:,2), '--')
    title('Trapecio')
    
end

axis equal
xlabel('X (mm)')
ylabel('Y (mm)')

% ahora que tengo la frontera, vuelvo a calibrar, vuelvo a medir el offset,
% y mido el cilindro
% calculateCalibration_con_fronteras(C,path_calibracion, ind_fronteras)

% mido el offset nuevamente
% no me queda claro si tengo que calcular el offset sólo en la zona válida
% o no. De ser así, para la cámara 2 definiría la zona válida como la que
% tengo definida hasta acá menos el offset que tengo hasta acá, porque en
% el script de abajo todavía los datos no están desplazados
offset_fronteras = calculo_offset_con_fronteras(path_offset, path_calibracion);

%% ahora mido los patrones

clear variables

path_datos = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion48\';
path_calibracion = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion42\';
path_offset = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion43\';

% load([path_calibracion 'calibration.mat']);
% load([path_offset 'offset.mat']);
load([path_calibracion 'calibration_con_fronteras.mat']);
load([path_offset 'offset_fronteras.mat']);
load([path_calibracion 'fronteras.mat']);

% empaqueto lo que ya tengo hecho en el fronteras_region_valida. Ahí mido
% el patrón del medio

frame_cilindro = {'patron_34700530', 'patron_34700630', 'patron_34700730'};
id_cilindro = {'34700530', '34700630', '34700730'};

frames_cilindro = {[], []};

for f = 1:3
    close all
    for q = 1:2
        frames_cilindro{q} = [path_datos frame_cilindro{f} '_camara_' num2str(q) '.png'];
    end
    % sin las fronteras en el offset
%     [centro_x, centro_y, r_teorico] = mido_patron(frames_cilindro, id_cilindro{f}, px2mmPol, offset, F, path_datos);
    [centro_x, centro_y, r_teorico] = mido_patron(frames_cilindro, id_cilindro{f}, px2mmPol, offset_fronteras, F, path_datos); % con las fronteras en el offset
    fprintf([id_cilindro{f} ': diámetro %.3f\n'], 2*r_teorico)
end