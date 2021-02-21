% este script es para testear la calibración midiendo la misma punta con
% las 2 cámaras, ya habiendo calculado el desplazamiento que hay que
% hacerle a una de ellas

clear variables
path_datos = 'C:\Users\60069978\Documents\MATLAB\medicion40\';
path_calibracion = 'C:\Users\60069978\Documents\MATLAB\medicion39\';

creo_directorios_2_camaras(path_datos);

separar_frames_utiles(path_datos, 1);
separar_frames_utiles(path_datos, 2);

%%

% path_datos = 'C:\Users\60069978\Documents\MATLAB\medicion38\';
% path_calibracion = 'C:\Users\60069978\Documents\MATLAB\medicion32\';

% calcular las intersecciones antes de seguir, usando
% "calculateIntersections" y señalando la esquina que corresponda en cada
% cámara

load([path_datos 'intersections.mat']);

% calculateCalibration(C, path_datos)

load([path_calibracion 'calibration.mat']);

% POLINOMIOS

% cámara 1
polinomio_x_camara_1 = px2mmPol{1}(1);
polinomio_y_camara_1 = px2mmPol{1}(2);

indices_x_1 = polinomio_x_camara_1.ind;
indices_y_1 = polinomio_y_camara_1.ind;

indices_calibrados_1 = indices_x_1 == 1 & indices_y_1 == 1;


% cámara 2
polinomio_x_camara_2 = px2mmPol{2}(1);
polinomio_y_camara_2 = px2mmPol{2}(2);

% tomo 1 perfil de cada cámara y los grafico en px y en mm

% PIXELS
% cámara 1
load([path_datos 'camara_1.mat']);

perfiles_1 = Profiles;
x_1 = X;
y_1 = Y;

% cámara 2
load([path_datos 'camara_2.mat']);

perfiles_2 = Profiles;
x_2 = X;
y_2 = Y;

% n2 = 1;
% pixel_y_camara_2 = 1088 - perfiles_2;
% pixel_y_camara_2 = pixel_y_camara_2(:, n2);
% pixel_x_camara_2 = 1:numel(pixel_y_camara_2);
% close all
% figure(1)
% plot(pixel_x_camara_2, pixel_y_camara_2, '.-')



% pixel_y_camara_1 = 1088 - perfiles_1;
% pixel_y_camara_1 = pixel_y_camara_1(:, n1);
% pixel_x_camara_1 = 1:numel(pixel_y_camara_1);
% pixel_x_camara_1 = pixel_x_camara_1.';
% 
% 
% pixel_y_camara_2 = 1088 - perfiles_2;
% pixel_y_camara_2 = pixel_y_camara_2(:, n2);
% pixel_x_camara_2 = 1:numel(pixel_y_camara_2);
% pixel_x_camara_2 = pixel_x_camara_2.';

C1 = C{1};
C2 = C{2};

x_comunes = intersect(x_1, x_2);
y_comunes = intersect(y_1, y_2);

N_x = numel(x_comunes);
N_y = numel(y_comunes);

% punta_mmx_1_array = [];
% punta_mmy_1_array = [];
% 
% punta_mmx_2_array = [];
% punta_mmy_2_array = [];

X = [];
Y = [];

PX = [];
PY = [];

error_x_array = [];
error_y_array = [];

% for i = 1
%     for j = 1
for i = 1:N_x
    for j = 1:N_y
            
        x_pedido = x_comunes(i);
        y_pedido = y_comunes(j);

%         x_pedido = 150;
%         y_pedido = 500;
        
        filtro_x = x_1 == x_pedido;
        filtro_y = y_1 == y_pedido;
        filtro = filtro_x == 1 & filtro_y == 1;

        n1 = find(filtro);

        % encuentro el índice de la cámara 2
        filtro_x = x_2 == x_pedido;
        filtro_y = y_2 == y_pedido;
        filtro = filtro_x == 1 & filtro_y == 1;

        n2 = find(filtro);

        punta_px_1 = C1(n1, 1);
        punta_py_1 = C1(n1, 2);
        punta_px_2 = C2(n2, 1);
        punta_py_2 = C2(n2, 2);
        
        if isnan(punta_px_1) == 1
            disp('NaN 1')
            continue
        end
        
        if isnan(punta_px_2) == 1
            disp('NaN 2')
            continue
        end
        
        if numel(punta_px_1) == 0 || numel(punta_px_2) == 0
            disp('numel = 0')
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
        
        % convierto las puntas a mm
        punta_mm_x_1 = polyval4XY(polinomio_x_camara_1, punta_px_1, punta_py_1);
        punta_mm_y_1 = polyval4XY(polinomio_y_camara_1, punta_px_1, punta_py_1);

        % cámara 2
        punta_mm_x_2 = polyval4XY(polinomio_x_camara_2, punta_px_2, punta_py_2);
        punta_mm_y_2 = polyval4XY(polinomio_y_camara_2, punta_px_2, punta_py_2);

        mm_x_camara_1 = polyval4XY(polinomio_x_camara_1, pixel_x_camara_1, pixel_y_camara_1);
        mm_y_camara_1 = polyval4XY(polinomio_y_camara_1, pixel_x_camara_1, pixel_y_camara_1);
% 
%         % cámara 2
        mm_x_camara_2 = polyval4XY(polinomio_x_camara_2, pixel_x_camara_2, pixel_y_camara_2);
        mm_y_camara_2 = polyval4XY(polinomio_y_camara_2, pixel_x_camara_2, pixel_y_camara_2);

%         punta_mm_x_2_trasladado = punta_mm_x_2 - delta_x;
%         punta_mm_y_2_trasladado = punta_mm_y_2 - delta_y;    
        
%         punta_mmx_1_array = [punta_mmx_1_array punta_mm_x_1];
%         punta_mmy_1_array = [punta_mmy_1_array punta_mm_y_1];
%         
%         punta_mmx_2_array = [punta_mmx_2_array punta_mm_x_2];
%         punta_mmy_2_array = [punta_mmy_2_array punta_mm_y_2];
        
%         mm_x_camara_2_trasladado = mm_x_camara_2 - delta_x;
%         mm_y_camara_2_trasladado = mm_y_camara_2 - delta_y;

        error_x = punta_mm_x_2 - punta_mm_x_1;
        error_y = punta_mm_y_2 - punta_mm_y_1;
        
        error_x_array = [error_x_array error_x];
        error_y_array = [error_y_array error_y];
        
        X = [X x_pedido];
        Y = [Y y_pedido];
        
        PX = [PX punta_px_1];
        PY = [PY punta_py_1];
        
%         close all
%         figure(1)
%         hold on
%         grid on
%         
%         plot(mm_x_camara_1, mm_y_camara_1, '.-b')
%         plot(mm_x_camara_2, mm_y_camara_2, '.-r')
% 
%         plot(punta_mm_x_1, punta_mm_y_1, '*g')
%         plot(punta_mm_x_2, punta_mm_y_2, 'og')
    
    end
end
% 

for i = 1:2

    mean_x = mean(error_x_array);
    mean_y = mean(error_y_array);
    sigma_x = std(error_x_array);
    sigma_y = std(error_y_array);

    filtro_x = error_x_array > mean_x - 3*sigma_x & error_x_array < mean_x + 3*sigma_x;
    filtro_y = error_y_array > mean_y - 3*sigma_y & error_y_array < mean_y + 3*sigma_y;

    filtro = filtro_x == 1 & filtro_y == 1;

    error_x_array = error_x_array(filtro);
    error_y_array = error_y_array(filtro);
    X = X(filtro);
    Y = Y(filtro);
    PX = PX(filtro);
    PY = PY(filtro);
    
end

% [mean(error_x_array), std(error_x_array)]
% [mean(error_y_array), std(error_y_array)]

[median(error_x_array), median(error_y_array)]

% corrijo desplazando uno de los polinomios
delta_x = median(error_x_array);
delta_y = median(error_y_array);

incerteza_delta_x = std(error_x_array);
incerteza_delta_y = std(error_y_array);

sprintf('Error en X = %.3f\nError en Y = %.3f', incerteza_delta_x, incerteza_delta_y)

error_x_desplazado = error_x_array - delta_x;
error_y_desplazado = error_y_array - delta_y;

close all
figure(1)
hold on
grid on

plot3(X, Y, error_x_desplazado, '.b')

xlabel('x (mm)')
ylabel('y (mm)')
zlabel('Error en X (mm)')
view(31, 19)


figure(2)
hold on
grid on

plot3(PX, PY, error_y_desplazado, '.b')

xlabel('x (mm)')
ylabel('y (mm)')
zlabel('Error en Y (mm)')
view(31, 19)
% 
% figure(2)
% hold on
% grid on
% 
% plot3(PX, PY, error_x_array, '.b')
% plot3(PX, PY, error_y_array, '.r')
% 
% xlabel('px1')
% ylabel('py1')
% zlabel('Error (mm)')
% 
% view(31, 19)

% guardo las coordenadas de las puntas en px
puntas = {[punta_px_1, punta_py_1], [punta_px_2, punta_py_2]};
save(fullfile(path_datos, 'puntas'),'puntas')

% exporto las deltas para usar en el futuro
deltas = [delta_x, delta_y];
save(fullfile(path_datos, 'deltas'),'deltas');

%%
% 
% clear variables
path_datos = 'C:\Users\60069978\Documents\MATLAB\medicion34\';
path_calibracion = 'C:\Users\60069978\Documents\MATLAB\medicion32\';

load([path_datos 'intersections.mat']);
load([path_calibracion 'calibration.mat']);

% cámara 1
load([path_datos 'camara_1.mat']);

perfiles_1 = Profiles;
x_1 = X;
y_1 = Y;

% cámara 2
load([path_datos 'camara_2.mat']);

perfiles_2 = Profiles;
x_2 = X;
y_2 = Y;

C1 = C{1};
C2 = C{2};

polinomio_x_camara_1 = px2mmPol{1}(1);
polinomio_y_camara_1 = px2mmPol{1}(2);

polinomio_x_camara_2 = px2mmPol{2}(1);
polinomio_y_camara_2 = px2mmPol{2}(2);

x_pedido = 100;
y_pedido = 575;

filtro_x = x_1 == x_pedido;
filtro_y = y_1 == y_pedido;
filtro = filtro_x == 1 & filtro_y == 1;

n1 = find(filtro);

% encuentro el índice de la cámara 2
filtro_x = x_2 == x_pedido;
filtro_y = y_2 == y_pedido;
filtro = filtro_x == 1 & filtro_y == 1;

n2 = find(filtro);

punta_px_1 = C1(n1, 1);
punta_py_1 = C1(n1, 2);
punta_px_2 = C2(n2, 1);
punta_py_2 = C2(n2, 2);

pixel_y_camara_1 = 1088 - perfiles_1;
pixel_y_camara_1 = pixel_y_camara_1(:, n1);
pixel_x_camara_1 = 1:numel(pixel_y_camara_1);
pixel_x_camara_1 = pixel_x_camara_1.';


pixel_y_camara_2 = 1088 - perfiles_2;
pixel_y_camara_2 = pixel_y_camara_2(:, n2);
pixel_x_camara_2 = 1:numel(pixel_y_camara_2);
pixel_x_camara_2 = pixel_x_camara_2.';

% convierto las puntas a mm
punta_mm_x_1 = polyval4XY(polinomio_x_camara_1, punta_px_1, punta_py_1);
punta_mm_y_1 = polyval4XY(polinomio_y_camara_1, punta_px_1, punta_py_1);

% cámara 2
punta_mm_x_2 = polyval4XY(polinomio_x_camara_2, punta_px_2, punta_py_2);
punta_mm_y_2 = polyval4XY(polinomio_y_camara_2, punta_px_2, punta_py_2);

mm_x_camara_1 = polyval4XY(polinomio_x_camara_1, pixel_x_camara_1, pixel_y_camara_1);
mm_y_camara_1 = polyval4XY(polinomio_y_camara_1, pixel_x_camara_1, pixel_y_camara_1);

% cámara 2
mm_x_camara_2 = polyval4XY(polinomio_x_camara_2, pixel_x_camara_2, pixel_y_camara_2);
mm_y_camara_2 = polyval4XY(polinomio_y_camara_2, pixel_x_camara_2, pixel_y_camara_2);


% offset_x = -0.0144;
% offset_y = 0.0324;
% 
% delta_x = 51.986 + offset_x;
% delta_y = 29.924 + offset_y;

delta_x = 51.693;
delta_y = 30.627;

punta_mm_x_2_trasladado = punta_mm_x_2 - delta_x;
punta_mm_y_2_trasladado = punta_mm_y_2 - delta_y;    

%         punta_mmx_1_array = [punta_mmx_1_array punta_mm_x_1];
%         punta_mmy_1_array = [punta_mmy_1_array punta_mm_y_1];
%         
%         punta_mmx_2_array = [punta_mmx_2_array punta_mm_x_2];
%         punta_mmy_2_array = [punta_mmy_2_array punta_mm_y_2];

mm_x_camara_2_trasladado = mm_x_camara_2 - delta_x;
mm_y_camara_2_trasladado = mm_y_camara_2 - delta_y;

% 
% 
error_x = punta_mm_x_2_trasladado - punta_mm_x_1;
error_y = punta_mm_y_2_trasladado - punta_mm_y_1;

[error_x, error_y]

% error_x_array = [error_x_array error_x];
% error_y_array = [error_y_array error_y];



% X = [X x_pedido];
% Y = [Y y_pedido];
% 
%         [error_x, error_y]
% 
% close all
figure(3)
hold on
grid on

plot(mm_x_camara_1, mm_y_camara_1, '.-b')
% plot(mm_x_camara_2, mm_y_camara_2, '.-r')

plot(mm_x_camara_2_trasladado, mm_y_camara_2_trasladado, '.-r')

%         plot(pixel_x_camara_1, pixel_y_camara_1, '.-b')
%         plot(pixel_x_camara_2, pixel_y_camara_2, '.-r')

plot(punta_mm_x_1, punta_mm_y_1, '*g')
plot(punta_mm_x_2_trasladado, punta_mm_y_2_trasladado, 'oy')

% plot(punta_px_1, punta_py_1, '*g')
% plot(punta_px_2, punta_py_2, '*y')