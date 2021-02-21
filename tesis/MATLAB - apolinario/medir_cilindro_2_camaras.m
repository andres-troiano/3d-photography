% analizo mediciones hechas con el script de barrido habitual

clear variables

patron = '34700030';

path_datos = 'C:\Users\60069978\Documents\MATLAB\medicion26\';
path_calibracion = 'C:\Users\60069978\Documents\MATLAB\medicion23\';

mkdir([path_datos 'camara_1'])
mkdir([path_datos 'camara_2'])

separar_frames_utiles(path_datos, 1);
separar_frames_utiles(path_datos, 2);

% mkdir([path_datos patron])

movefile([path_datos 'camara_1'], [path_datos patron '\camara_1']);
movefile([path_datos 'camara_2'], [path_datos patron '\camara_2']);

path_datos = ['C:\Users\60069978\Documents\MATLAB\medicion26\' patron '\'];

%%

clear variables
patron = '34700030';

path_datos = ['C:\Users\60069978\Documents\MATLAB\medicion26\' patron '\'];
path_calibracion = 'C:\Users\60069978\Documents\MATLAB\medicion23\';

% convertir a dot mat antes de seguir

load([path_calibracion 'calibration.mat']);

polinomio_x_camara_1 = px2mmPol{1}(1);
polinomio_y_camara_1 = px2mmPol{1}(2);

polinomio_x_camara_2 = px2mmPol{2}(1);
polinomio_y_camara_2 = px2mmPol{2}(2);

load([path_datos 'camara_1.mat']);

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

for i = 4;
    for j = 4;

% for i = 1:N_x
%     for j = 1:N_y
            
        x_pedido = x_comunes(i);
        y_pedido = y_comunes(j);

%         x_pedido = 100;
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
        
        if numel(n1) == 0
            disp('Punto no medido CAM 1')
            continue
        end
        
        if numel(n2) == 0
            disp('Punto no medido CAM 2')
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
        
        mm_x_camara_1 = polyval4XY(polinomio_x_camara_1, pixel_x_camara_1, pixel_y_camara_1);
        mm_y_camara_1 = polyval4XY(polinomio_y_camara_1, pixel_x_camara_1, pixel_y_camara_1);

        % cámara 2
        mm_x_camara_2 = polyval4XY(polinomio_x_camara_2, pixel_x_camara_2, pixel_y_camara_2);
        mm_y_camara_2 = polyval4XY(polinomio_y_camara_2, pixel_x_camara_2, pixel_y_camara_2);

        offset_x = -0.0144;
        offset_y = 0.0324;

        delta_x = 51.986 + offset_x;
        delta_y = 29.924 + offset_y;
        % 
        mm_x_camara_2_trasladado = mm_x_camara_2 - delta_x;
        mm_y_camara_2_trasladado = mm_y_camara_2 - delta_y;
        
        close all
        figure(1)
        hold on
        grid on
        
        plot(mm_x_camara_1, mm_y_camara_1, '.-b')
%         plot(mm_x_camara_2, mm_y_camara_2, '.-r')

        plot(mm_x_camara_2_trasladado, mm_y_camara_2_trasladado, '.-r')

%         plot(pixel_x_camara_1, pixel_y_camara_1, '.-b')
%         plot(pixel_x_camara_2, pixel_y_camara_2, '.-r')

    end
end