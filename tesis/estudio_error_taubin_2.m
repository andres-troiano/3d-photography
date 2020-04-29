% versión para la tesis, con 1 sólo error de calibración

clear variables

% las unidades son mm
iteraciones = 1000;

error_pos = 0.1;
angulo_barrido = [30:10:180 360];

% me hago una matriz que en cada columna tiene la tira de error promedio
% (en el diámetro) para cada error de posicionamiento

% matriz de errores en el diámetro
% cada columna corresponde a un error de posicionamiento
E = zeros(numel(angulo_barrido), numel(error_pos));

% matrices de centros
Cx = zeros(numel(angulo_barrido), numel(error_pos));
Cy = zeros(numel(angulo_barrido), numel(error_pos));

k = 1;
    
for j = 1:numel(angulo_barrido)
    
    fprintf('Paso %d de %d\n', j, numel(angulo_barrido))

    diametro_real = 178;
    centro_x_real = 100;
    centro_y_real = 100;
    r_real = diametro_real/2;

    diametro_teorico_dist = zeros(1, iteraciones);
    centro_x_dist = zeros(1, iteraciones);
    centro_y_dist = zeros(1, iteraciones);

    tag_global = ['estudio_error_taubin_diametro_' num2str(2*r_real) '_mm_centro_' num2str(centro_x_real) '_' num2str(centro_y_real) '_mm_error_calibracion_' num2str(1000*error_pos(k)) '_um_' num2str(angulo_barrido(j)) '_grados'];

    for i = 1:iteraciones

        % cantidad de datos
        N = 1000;
        t = linspace(0, deg2rad(angulo_barrido(j)), N);

        %%%%%%%%%%% usando distribución normal %%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % a cada valor de x,y le sumo un error tomado de una
        % distribución normal centrada en 0 con sigma igual al error de
        % calibración
        mu = 0;
        sigma = error_pos(k);
        dist_error = mu + sigma.*randn(1, N);
%             dist_error = randn(0, error_pos(k), [1, N]);
        x = centro_x_real + r_real*cos(t) + dist_error;

        dist_error = mu + sigma.*randn(1, N);
%             dist_error = normrnd(0, error_pos(k), [1, N]);
        y = centro_y_real + r_real*sin(t) + dist_error;

        % matrix con x, y como columnas
        XY = [x; y];    % así están como filas
        XY = XY.';

        circulo = TaubinNTN(XY);

        centro_x = circulo(1);
        centro_y = circulo(2);
        r_teorico = circulo(3);
%             diametro_teorico = 2*r_teorico;

        x_teorico = r_teorico * cos(t) + centro_x;
        y_teorico = r_teorico * sin(t) + centro_y;

        diametro_teorico_dist(i) = 2*r_teorico;
        centro_x_dist(i) = centro_x;
        centro_y_dist(i) = centro_y;

    end
    % sprintf('Radio sin error = %d\nRadio con error = %.2f', r, r_teorico)

    close all

    % estadística del diámetro
%     h1 = figure(1);
%     histogram(1000*(diametro_teorico_dist - diametro_real))
%     grid on
%     label_x = sprintf('Diámetro dado por el ajuste menos diámetro real (\\mum)');
%     xlabel(label_x)
%     ylabel('Frecuencia')
%     tit = sprintf('Error de calibración = %d \\mum', 1000*error_pos(k));
%     leg = sprintf('N = %d', iteraciones);
%     legend(leg)
%     title(tit)

    %tag1 = ['histograma_estudio_error_taubin_dist_normal_diametro_' num2str(2*r) '_mm_error_' num2str(1000*error_pos(k)) '_um_' num2str(angulo_barrido(j)) '_grados'];
    tag1 = ['estadistica_diametro_' tag_global];

    % estadística de centro x
%     h4 = figure(4);
%     histogram(1000*(centro_x_dist - centro_x_real))
%     grid on
%     label_x = sprintf('Coord. x del centro dada por el ajuste menos la real (\\mum)');
%     xlabel(label_x)
%     ylabel('Frecuencia')
%     tit = sprintf('Error de calibración = %d \\mum', 1000*error_pos(k));
%     leg = sprintf('Centro x = %d', centro_x_real);
%     legend(leg)
%     title(tit)

%         tag4 = ['histograma_estudio_error_taubin_estadistica_centro_x_diametro_' num2str(2*r) '_mm_error_' num2str(1000*error_pos(k)) '_um_' num2str(angulo_barrido(j)) '_grados'];
    tag4 = ['estadistica_centro_x_' tag_global];

    % estadística de centro y
%     h5 = figure(5);
%     histogram(1000*(centro_y_dist - centro_y_real))
%     grid on
%     label_x = sprintf('Coord. y del centro dada por el ajuste menos la real (\\mum)');
%     xlabel(label_x)
%     ylabel('Frecuencia')
%     tit = sprintf('Error de calibración = %d \\mum', 1000*error_pos(k));
%     leg = sprintf('Centro y = %d', centro_y_real);
%     legend(leg)
%     title(tit)

%         tag5 = ['histograma_estudio_error_taubin_estadistica_centro_y_diametro_' num2str(2*r) '_mm_error_' num2str(1000*error_pos(k)) '_um_' num2str(angulo_barrido(j)) '_grados'];
    tag5 = ['estadistica_centro_y_' tag_global];

    % gráfico del perfil
%     h2 = figure(2);
%     hold on
%     plot(x, y, '.-')
%     plot(x_teorico, y_teorico, '--r')
%     grid on
%     xlabel('x (mm)')
%     ylabel('y (mm)')
%     tit = sprintf('Error de calibración = %d \\mum', 1000*error_pos(k));
%     title(tit)
%     legend('Datos simulados', 'Ajuste', 'Location', 'Best')

%         tag2 = ['plot_estudio_error_taubin_dist_normal_diametro_' num2str(2*r) '_mm_error_' num2str(1000*error_pos(k)) '_um_' num2str(angulo_barrido(j)) '_grados'];
    tag2 = ['plot_perfil_' tag_global];

    error_promedio = mean(diametro_teorico_dist) - diametro_real;
    centro_x_promedio = mean(centro_x_dist);
    centro_y_promedio = mean(centro_y_dist);

    E(j, k) = error_promedio;
    Cx(j, k) = centro_x_promedio;
    Cy(j, k) = centro_y_promedio;

end

%%

% grafico E en tantas curvas como errores de posicionamiento tengo, en
% función del ángulo

set(0,'DefaultFigureVisible', 'on');

close all

tag_promedios = ['diametro_' num2str(2*r_real) '_mm_centro_' num2str(centro_x_real) '_' num2str(centro_y_real) '_mm'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% curva de promedios diametro
h3 = figure(3);
hold on

leg = cell(numel(error_pos), 1);

for i = 1:numel(error_pos)
    
    % grafico la diferencia entre el diámetro dado por el ajuste y el real,
    % y lo expreso en micrones
    plot(angulo_barrido, (E(:, i))*1000, '.-')
    leg{i} = sprintf('Error de calibración = %d \\mum', 1000*error_pos(i));
end

grid on
xlabel('Ángulo (º)')
ylabel('Error en el diámetro (\mum)')
saveas(h3, 'C:\Users\Norma\Downloads\imagenes tesis\error_taubin.png')

tag3 = ['error_diametro_en_funcion_del_angulo_y_la_calibracion_' tag_promedios];

for i = 1:3
    sprintf('Error calibración = %d um, error diámetro = %f', error_pos(i), E(10, i))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % curva de promedios centro x
% h6 = figure(6);
% hold on
% 
% leg = cell(numel(error_pos), 1);
% 
% for i = 1:numel(error_pos)
%     
%     % grafico la diferencia entre centro x dado por el ajuste y el real,
%     % y lo expreso en micrones
%     plot(angulo_barrido, (Cx(:, i) - centro_x_real)*1000, '.-')
%     leg{i} = sprintf('Error de calibración = %d \\mum', 1000*error_pos(i));
% end
% 
% grid on
% xlabel('Ángulo (º)')
% ylabel('Centro x ajuste menos real (\mum)')
% legend(leg, 'Location', 'Best')
% title('Centro x')
% 
% tag6 = ['error_centro_x_en_funcion_del_angulo_y_la_calibracion_' tag_promedios];
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % curva de promedios centro y
% h7 = figure(7);
% hold on
% 
% leg = cell(numel(error_pos), 1);
% 
% for i = 1:numel(error_pos)
%     
%     % grafico la diferencia entre el diámetro dado por el ajuste y el real,
%     % y lo expreso en micrones
%     plot(angulo_barrido, (Cy(:, i) - centro_y_real)*1000, '.-')
%     leg{i} = sprintf('Error de calibración = %d \\mum', 1000*error_pos(i));
% end
% 
% grid on
% xlabel('Ángulo (º)')
% ylabel('Centro y ajuste menos real (\mum)')
% legend(leg, 'Location', 'Best')
% title('Centro y')
% 
% tag7 = ['error_centro_y_en_funcion_del_angulo_y_la_calibracion_' tag_promedios];

% saveas(h3, [path tag3], 'png');
% saveas(h3, [path tag3]);
% 
% saveas(h6, [path tag6], 'png');
% saveas(h6, [path tag6]);
% 
% saveas(h7, [path tag7], 'png');
% saveas(h7, [path tag7]);

% armo la tabla que pidió Nicolás
% 120 º corresponde a la fila 10
% los errores que me interesan son los 3 primeros, porque 700 no me interesa

%%
% clear variables
% 
% % calculo qué ángulo tuve al medir el patrón de 178 mm
% 
% directorio = 'C:\Users\60069978\Documents\MATLAB\scan26\';
% frame = [directorio 'frame_cilindro_34700730_x_410_y_550_z_21.png'];
% 
% frame = imread(frame);
% perfil = median(frame);
% perfil = double(perfil)/2^4;
% 
% datos_x = [];
% datos_y = [];
% 
% for i = 1:numel(perfil)
%     if perfil(i) ~= 0
%         datos_x = [datos_x i];
%         datos_y = [datos_y perfil(i)];
%     end
% end
% 
% [y_min, indice_min] = min(datos_y);
% x_min = datos_x(indice_min);
% 
% % uso que el reflejo de la base está a más de 300 pixels de lo más que
% % alcanzo a ver del cilindro
% 
% dist = 300;
% 
% datos_x_temp = [];
% datos_y_temp = [];
% 
% for i = 1:numel(datos_x)
%     if datos_y(i) < min(datos_y) + dist
%         datos_x_temp = [datos_x_temp datos_x(i)];
%         datos_y_temp = [datos_y_temp datos_y(i)];
%     end
% end
% 
% datos_x = datos_x_temp;
% datos_y = datos_y_temp;
% 
% % convierto a mm
% %%%%%%%%%%%%%%%%
% lut = 'C:\Users\60069978\Documents\MATLAB\scan24\LUT_paso_5_mm.txt';
% [x, y] = convertir_a_unidades_reales(datos_x, datos_y, lut);
% 
% % matrix con x, y como columnas
% XY = [x; y];    % así están como filas
% XY = XY.';
% 
% circulo = TaubinNTN(XY);
% 
% centro_x = circulo(1);
% centro_y = circulo(2);
% radio = circulo(3);
% diametro = 2*radio;
% 
% th = 0:pi/50:2*pi;
% circulo_x = radio * cos(th) + centro_x;
% circulo_y = radio * sin(th) + centro_y;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % identifico las dos rectas que unen el centro con los 2 extremos del
% % perfil, y calculo el ángulo entre ellas
% 
% x1 = x(1);
% y1 = y(1);
% x2 = x(end);
% y2 = y(end);
% 
% L1 = [x1, y1] - [centro_x, centro_y];
% L2 = [x2, y2] - [centro_x, centro_y];
% angle = acos(sum(L1.*L2)/(norm(L1)*norm(L2)));
% rad2deg(angle)
% 
% set(0,'DefaultFigureVisible', 'on');
% close all
% 
% figure(1)
% hold on
% grid on
% plot(x, y, '.-')
% plot(circulo_x, circulo_y, '--r')
% plot(centro_x, centro_y, '.r')
% plot(x1, y1, '.g')
% plot(x2, y2, '.y')