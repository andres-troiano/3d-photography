% procesamiento punta inclinada

path_datos = 'C:\Users\60069978\Documents\MATLAB\medicion19\';

creo_directorios_2_camaras(path_datos);

separar_frames_utiles(path_datos, 1);
separar_frames_utiles(path_datos, 2);

%%

path_datos = 'C:\Users\60069978\Documents\MATLAB\medicion19\';

camara = '1';

dir_camara = ['camara_' camara '\'];
list = dir([path_datos dir_camara 'LUT_camara*.png']);
fnames = {list.name};

set(0,'DefaultFigureVisible', 'on');

% cargo el txt que tiene las coords medidas
datos = importdata([path_datos 'coord_pedidas_vs_medidas.txt'], '\t', 1);
datos = datos.data;

x_pedido = datos(:, 1);
y_pedido = datos(:, 2);

%%%%%%%%%%%%%%%%%%%

% voy a anotar para cada tag dónde vi la punta
tag_x_array = [];
tag_y_array = [];

x_ccd = [];
y_ccd = [];

set(0,'DefaultFigureVisible', 'off');

N = numel(x_pedido);
    
% for i = 1:N
for i = 1
    
    tag_x = num2str(x_pedido(i));
    tag_y = num2str(y_pedido(i));
    
    [tag_x ' ' tag_y]

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    filename = dir([path_datos dir_camara 'LUT_camara_' camara '_frame_x_' tag_x '_y_' tag_y '.png']);
    filename = {filename.name};
    
    if numel(filename) == 0
        continue
    end
    
    filename = filename{1};
    filename = [path_datos dir_camara filename];
    
%     filename = [path dir_camara '\LUT_camara_' camara '_frame_x_125_y_450.png'];

    frame = imread(filename);
    perfil = median(frame);
    perfil = double(perfil)/2^4;

    perfil_x = 1:1:numel(perfil);

    indices_no_nulos = perfil ~= 0;
    datos_y = perfil(indices_no_nulos);
    datos_x = perfil_x(indices_no_nulos);

%     [datos_x_parcial, datos_y_parcial] = tiro_mitad_datos(datos_x, datos_y, camara);

    [datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2, delta_1, delta_2] = receta_tuerca_inclinada(datos_x, datos_y, camara);

    punta_px = (b2 - b1)/(a1 - a2);
    punta_py = a1*(b2 - b1)/(a1 - a2) + b1;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % creo que acá iría la recuperación de datos válidos
    
    
%     [numel(recta_1), numel(delta_1), tag_x, tag_y]
    [x_definitivo_1, y_definitivo_1, x_definitivo_2, y_definitivo_2, punta_definitiva_px, punta_definitiva_py] = recupero_datos_validos_calculo_punta(perfil_x, perfil, datos_x_1, datos_x_2, recta_1, recta_2, delta_1, delta_2, punta_px, a1, a2, b1, b2);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % guardo los datos que me interesan
    tag_x_array = [tag_x_array x_pedido(i)];
    tag_y_array = [tag_y_array y_pedido(i)];

%     x_ccd = [x_ccd punta_px];
%     y_ccd = [y_ccd punta_py];

    x_ccd = [x_ccd punta_definitiva_px];
    y_ccd = [y_ccd punta_definitiva_py];

    close all
    h = figure;
    hold on
    grid on

    plot(datos_x, datos_y, '.-k')
% %     plot(datos_x_parcial, datos_y_parcial, '.b')
    plot(datos_x_1, datos_y_1, '.g')
    plot(datos_x_2, datos_y_2, '.y')
%     plot(datos_x_1, recta_1, '--r')
%     plot(datos_x_2, recta_2, '--b')
%     plot(punta_px, punta_py, '*r')

    plot(punta_definitiva_px, punta_definitiva_py, '*r')

%     plot(datos_x_2, datos_y_2, '.y')
%     plot(datos_x_2, recta_2, '--r')

    plot(x_definitivo_1, y_definitivo_1, 'og')
    plot(x_definitivo_2, y_definitivo_2, 'oy')
    
    xlabel('px')
    ylabel('py')
    
    fig_name = ['plot_camara_' camara '_x_' tag_x '_y_' tag_y];
    saveas(h, [path_datos dir_camara fig_name], 'png');
    
    % guardo el perfil
    output_datos_curados = fopen( [path_datos dir_camara 'tuerca_torcida_camara_' camara '_datos_curados_x_' tag_x '_y_' tag_y '.txt'], 'wt' );
    fprintf(output_datos_curados, 'datos_x\tdatos_y\n');

    for j = 1:numel(datos_x)
        fprintf(output_datos_curados, '%f\t%f\n', datos_x(j), datos_y(j));
    end

    fclose all;
    clear output_datos_curados;
    
end

output_file = fopen( [path_datos 'tuerca_torcida_camara_' camara '.txt'], 'wt' );
fprintf(output_file, 'tag_x\ttag_y\tpunta_x\tpunta_y\n');

for i = 1:numel(x_ccd)
    fprintf(output_file, '%d\t%d\t%f\t%f\n', tag_x_array(i), tag_y_array(i), x_ccd(i), y_ccd(i));
end

fclose all;
clear output_file;

%%

% veo qué da el caso 190,390
% repito lo que hice la vez pasada con el hexágono, solo que
% ahora voy a ver el mismo punto con las 2 cámaras

% clear variables
path_datos = 'C:\Users\60069978\Documents\MATLAB\medicion14\';
path_lut = 'C:\Users\60069978\Documents\MATLAB\medicion15\';

set(0,'DefaultFigureVisible', 'on');

lut_1 = [path_lut 'camara_1\LUT_camara_1.txt'];
lut_2 = [path_lut 'camara_2\LUT_camara_2.txt'];

% x_pedido = 190;
% y_pedido = 390;

x_pedidos_utiles = [135, 135, 135, 135, 170, 170, 170, 170, 205, 205, 205];
y_pedidos_utiles = [370, 405, 440, 475, 370, 405, 440, 475, 370, 405, 440];

N = numel(x_pedidos_utiles);

error_x_array = zeros(1, N);
error_y_array = zeros(1, N);

for i = 2:N
% for i = 10

%     x_pedido = 205;
%     y_pedido = 440;

    x_pedido = x_pedidos_utiles(i);
    y_pedido = y_pedidos_utiles(i);

    datos1 = importdata([path_datos 'tuerca_torcida_camara_1.txt'], '\t', 1);
    datos1 = datos1.data;

    tag_x_1 = datos1(:, 1);
    tag_y_1 = datos1(:, 2);
    x_ccd_1 = datos1(:, 3);
    y_ccd_1 = datos1(:, 4);

    indice_x_1 = tag_x_1 == x_pedido;
    indice_y_1 = tag_y_1 == y_pedido;

    indice_pedido_1 = indice_x_1 == 1 & indice_y_1 == 1;

    punta_x_1 = x_ccd_1(indice_pedido_1);
    punta_y_1 = y_ccd_1(indice_pedido_1);

    % cargo el perfil 1
    datos_curados = importdata([path_datos 'camara_1\tuerca_torcida_camara_1_datos_curados_x_' num2str(x_pedido) '_y_' num2str(y_pedido) '.txt'], '\t', 1);
    datos_curados = datos_curados.data;

    % esto esta en pixels
    perfil_px = datos_curados(:, 1);
    perfil_py = datos_curados(:, 2);

    % transformo el perfil y la punta a mm
    [perfil_x_1, perfil_y_1] = convertir_px_a_mm_polinomio(perfil_px, perfil_py, lut_1);
    [punta_x_mm_1, punta_y_mm_1] = convertir_px_a_mm_polinomio(punta_x_1, punta_y_1, lut_1);

    % cargo el perfil 2



    datos2 = importdata([path_datos 'tuerca_torcida_camara_2.txt'], '\t', 1);
    datos2 = datos2.data;

    tag_x_2 = datos2(:, 1);
    tag_y_2 = datos2(:, 2);
    x_ccd_2 = datos2(:, 3);
    y_ccd_2 = datos2(:, 4);

    indice_x_2 = tag_x_2 == x_pedido;
    indice_y_2 = tag_y_2 == y_pedido;

    indice_pedido_2 = indice_x_2 == 1 & indice_y_2 == 1;

    punta_x_2 = x_ccd_2(indice_pedido_2);
    punta_y_2 = y_ccd_2(indice_pedido_2);

    datos_curados = importdata([path_datos 'camara_2\tuerca_torcida_camara_2_datos_curados_x_' num2str(x_pedido) '_y_' num2str(y_pedido) '.txt'], '\t', 1);
    datos_curados = datos_curados.data;

    % esto esta en pixels
    perfil_px = datos_curados(:, 1);
    perfil_py = datos_curados(:, 2);

    % transformo el perfil y la punta a mm
    [perfil_x_2, perfil_y_2] = convertir_px_a_mm_polinomio(perfil_px, perfil_py, lut_2);
    [punta_x_mm_2, punta_y_mm_2] = convertir_px_a_mm_polinomio(punta_x_2, punta_y_2, lut_2);

    % close all
    % figure
    % hold on
    % grid on
    % 
    % plot(perfil_x_1, perfil_y_1, '.-b')
    % plot(punta_x_mm_1, punta_y_mm_1, '*g')
    % 
    % plot(perfil_x_2, perfil_y_2, '.-r')
    % plot(punta_x_mm_2, punta_y_mm_2, '*k')
    % 
    % xlabel('x (mm)')
    % ylabel('y (mm)')

    r = 40.075/2;
    alfa = 120;

    % necesito valores de gamma 1,2

    datos1 = importdata([path_lut 'camara_1\angulos_camara_1.txt'], '\t', 1);
    datos1 = datos1.data;

    alfa_array_1 = datos1(:, 5);
    alfa_1 = mean(alfa_array_1);

    gamma_array_1 = datos1(:, 6);
    gamma_1 = mean(gamma_array_1);

    datos2 = importdata([path_lut 'camara_2\angulos_camara_2.txt'], '\t', 1);
    datos2 = datos2.data;

    alfa_array_2 = datos2(:, 5);
    alfa_2 = mean(alfa_array_2);

    gamma_array_2 = datos2(:, 6);
    gamma_2 = mean(gamma_array_2);

    x_desplazado_1 = punta_x_1 + r*cosd(alfa_1/2 - gamma_1);
    y_desplazado_1 = punta_y_1 - r*sind(alfa_1/2 - gamma_1);

    traslacion_x_1 = r*cosd(alfa_1/2 - gamma_1);
    traslacion_y_1 = - r*sind(alfa_1/2 - gamma_1);

    traslacion_x_2 = r*cosd(alfa_2/2 + gamma_2);
    traslacion_y_2 = - r*sind(alfa_2/2 + gamma_2);

%     error_x = abs( (punta_x_mm_1 + traslacion_x_1) - (punta_x_mm_2 + traslacion_x_2) );
%     error_y = abs( (punta_y_mm_1 + traslacion_y_1) - (punta_y_mm_2 + traslacion_y_2) );

    error_x = (punta_x_mm_1 + traslacion_x_1) - (punta_x_mm_2 + traslacion_x_2);
    error_y = (punta_y_mm_1 + traslacion_y_1) - (punta_y_mm_2 + traslacion_y_2);


%     [error_x, error_y]
    fprintf('x = %d, y = %d, error x = %.3f, error y = %.3f\n', x_pedido, y_pedido, error_x, error_y)

    error_x_array(i) = error_x;
    error_y_array(i) = error_y;
    
%     close all
%     h = figure;
%     hold on
%     grid on
% 
%     plot(perfil_x_1, perfil_y_1, '--b')
%     plot(perfil_x_2, perfil_y_2, '--r')
% 
%     % plot(punta_x_mm_1, punta_y_mm_1, '*b')
%     % plot(punta_x_mm_2, punta_y_mm_2, '*r')
% 
%     plot(perfil_x_1 + traslacion_x_1, perfil_y_1 + traslacion_y_1, '.-b')
%     plot(perfil_x_2 + traslacion_x_2, perfil_y_2 + traslacion_y_2, '.-r')
% 
%     plot(punta_x_mm_1 + traslacion_x_1, punta_y_mm_1 + traslacion_y_1, '*b')
%     plot(punta_x_mm_2 + traslacion_x_2, punta_y_mm_2 + traslacion_y_2, '*r')
% 
%     axis equal
    
end



close all
figure
hold on
grid on
plot3(x_pedidos_utiles, y_pedidos_utiles, error_x_array, '.b')
plot3(x_pedidos_utiles, y_pedidos_utiles, error_y_array, '.r')