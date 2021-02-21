imaqreset
clear variables
close all

% directorio donde voy a guardar los frames
path = 'C:\Users\60069978\Documents\MATLAB\scan\';

camara = videoinput('gige', 1);

src = getselectedsource(camara);

%%

set(src, 'CameraMode', 'CenterOfGravity');
set(src, 'ReverseY', 'True');
set(src, 'ExposureTime', 300);
set(src, 'EnableDC2', 'True');
set(src, 'EnableDC0', 'False');
set(src, 'EnableDC0Shift', 'False');
set(src, 'EnableDC1', 'False');
set(src, 'FramePeriod', 3000);
set(src, 'AoiThreshold', 120);
set(src, 'LightDevice0LightBrightness', 100);
set(src, 'LightDevice0LightSource', 'ExposureActive');
set(src, 'ProfilesPerFrame', 50);
set(src, 'PacketSize', 5000);

%%

pause on

m = 1;

for k = 1:m

    frame = getsnapshot(camara);

    perfil = median(frame);
    perfil = double(perfil)/2^4;

    datos_x = [];
    datos_y = [];

    for i = 1:numel(perfil)
        if perfil(i) ~= 0
            datos_x = [datos_x i];
            datos_y = [datos_y perfil(i)];
        end
    end



    % digo que la mesa está a más de 300 más arriba del mínimo
    dist_trapecio_mesa = 300;

    datos_x_temp = [];
    datos_y_temp = [];

    for i = 1:numel(datos_x)
        if datos_y(i) < min(datos_y) + dist_trapecio_mesa
            datos_x_temp = [datos_x_temp datos_x(i)];
            datos_y_temp = [datos_y_temp datos_y(i)];
        end
    end

    datos_x = datos_x_temp;
    datos_y = datos_y_temp;

    % tiro unos pocos puntos al final, que pertenecen al flanco que va del
    % trapecio a la mesa
    % Podría verlos al ppio también
    datos_x = datos_x(1:end-3);
    datos_y = datos_y(1:end-3);
    
    %%%%%%%%%% acá empieza la minimización

    % elección inicial
    X0 = [-0.6000, 0.0250, 0.7450, 1000, 500 - datos_x(1), 1172 - datos_x(1)];

    options = optimset('MaxFunEvals', 1e6);
    
    f = @(x)cuadrados_trapecio(x, datos_x, datos_y);
    [x, fval] = fminsearch(f, X0, options);
    
    [trap_x, trap_y] = cuadrados_trapecio_plot_3(x, datos_x);

    [esq_x, esq_y] = esquinas_trapecio(x(1), x(2), x(3), x(4), x(5), x(6));
    [esq_x_real, esq_y_real] = convertir_a_unidades_reales(esq_x, esq_y);
    medida_precision = norma(esq_x_real, esq_y_real);
    
    close all
    figure(1)
    hold on
    plot(datos_x, datos_y, '.-b')
    plot(trap_x, trap_y, '.-r')
    plot(esq_x(1), esq_y(1), '*g')
    plot(esq_x(2), esq_y(2), '*y')

%     [x_ajuste, y_ajuste] = cuadrados_trapecio_plot(x);
%     [x_ajuste_real, y_ajuste_real] = convertir_a_unidades_reales(x_ajuste, y_ajuste);

%     medida = norma(x_ajuste, y_ajuste);
%     medida_real = norma(x_ajuste_real, y_ajuste_real);
    
    % ahora pruebo de medir usando la función que me daría más precisión, a
    % ver si es así
    
%     [esq_x, esq_y] = esquinas_trapecio(x(1), x(2), x(3), x(4), x(5));
%     
%     medida_precision = norma(esq_x, esq_y);
%     [medida, medida_precision]
    
    %[medida, medida_real]
    
    pause(0.5);

end