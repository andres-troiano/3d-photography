camara = '2';

path = 'C:\Users\60069978\Documents\MATLAB\medicion18\';

% % radio del hexágono, medido con un calibre
% % tuerca de fundición
% r = 40.075/2;

% tuerca maquinada
r = 21.325/2;

% lut = [path 'camara_' camara '\LUT_camara_' camara '.txt'];
lut = [path 'camara_' camara '\LUT_curada_camara_' camara '.txt'];

set(0,'DefaultFigureVisible', 'on');

% acá cargo los datos de x_ccd, y_ccd, ángulo, y grafico

datos = importdata([path 'camara_' camara '\angulos_camara_' camara '.txt'], '\t', 1);
datos = datos.data;

x_ccd = datos(:, 3);
y_ccd = datos(:, 4);
angulos = datos(:, 5);
gamma_array = datos(:, 6);

%%%%%%%%%%%%%%%%%%%

datos = importdata(lut, '\t', 1);
datos = datos.data;

tag_x_array = datos(:, 1);
tag_y_array = datos(:, 2);
x_stage = datos(:, 3);
y_stage = datos(:, 4);

close all

% % figure(1)
% % plot3(x_ccd, y_ccd, angulos, '.b')
% % grid on

for i = 1:6
    [tag_x_array, tag_y_array, x_ccd, y_ccd, angulos, gamma_array, mediana, sigma] = filtro_angulos_inusuales(tag_x_array, tag_y_array, x_ccd, y_ccd, angulos, gamma_array, 3);   
end

figure(2)
plot3(x_ccd, y_ccd, angulos, '.b')
grid on
view(0, 90)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% hago una simulación de cuánto impacta el ángulo en las coord del centro
% del hexágono

% % simulo ángulos medidos. Le doy un +- 10 grados
% alfa = linspace(110, 130, 100);

% lo calculo en particular para la dispersión que tengo
angulo_medio = mean(angulos);
angulo_min = angulo_medio - sigma;
angulo_max = angulo_medio + sigma;

alfa = linspace(angulo_min, angulo_max, 100);
alfa_0 = 120;

% por la cuenta que hice en papel, la variación de x,y debida al
% apartamiento del ángulo teórico es:

% esto está en mm
x = r*cosd(alfa/2) - r*cosd(alfa_0/2);
y = r*sind(alfa/2) - r*sind(alfa_0/2);

% close all
% figure(3)
% hold on
% plot(alfa, x, '.-b')
% plot(alfa, y, '.-r')
% grid on
% xlabel('ángulo (º)')
% ylabel('delta x (mm)')

delta_x = max(x) - min(x);
delta_y = max(y) - min(y);

sprintf('Valor medio ángulo = %.2f\nDispersión ángulo = %.2fº\nDelta x = %.3f mm\nDelta y = %.3f mm', angulo_medio, sigma, delta_x, delta_y)

%%

%%%%%%%%%%%% a partir de la punta calculo las coords del centro del hexágono
% esto lo hago para cada x,y filtrados

set(0,'DefaultFigureVisible', 'off');

N = numel(gamma_array);
% N = 1;

centro_x_array = zeros(N, 1);
centro_y_array = zeros(N, 1);

for i = 1:N
% for i = 1
    
    sprintf('Paso %d de %d', i, N)
    
    tag_x = num2str(tag_x_array(i));
    tag_y = num2str(tag_y_array(i));
    alfa = alfa_0;
%     alfa = angulos(i);
    gamma = gamma_array(i);
    
    % cargo un perfil y lo grafico en mm con el centro del hexágono
    datos_curados = importdata([path 'camara_' camara '\LUT_camara_' camara '_datos_curados_x_' tag_x '_y_' tag_y '.txt'], '\t', 1);
    datos_curados = datos_curados.data;

    % esto esta en pixels
    perfil_px = datos_curados(:, 1);
    perfil_py = datos_curados(:, 2);
    
    % transformo el perfil y la punta a mm
    [perfil_x, perfil_y] = convertir_px_a_mm_polinomio(perfil_px, perfil_py, lut);
    [punta_x, punta_y] = convertir_px_a_mm_polinomio(x_ccd(i), y_ccd(i), lut);
    
    % calculo la posición del centro
    % esto cambia según de qué cámara se trate
    % pensar si puedo hacer algo que en general funcione para ambas
    
    if camara == '1'
        centro_x = punta_x - r*cosd(alfa/2 - gamma);
        centro_y = punta_y + r*sind(alfa/2 - gamma);
    end
    
    if camara == '2'        
        centro_x = punta_x - r*cosd(alfa/2 + gamma);
        centro_y = punta_y + r*sind(alfa/2 + gamma);
    end
    
    centro_x_array(i) = centro_x;
    centro_y_array(i) = centro_y;
    
    % grafico
    
    close all
    
    h = figure(1);
    hold on
    grid on

    plot(perfil_x, perfil_y, '.-k')
    plot(punta_x, punta_y, '*r')
    plot(centro_x, centro_y, '*b')
    
    xlabel('x (mm)')
    ylabel('y (mm)')
    
    axis equal
    
    fig_name = ['centro_hexagono_camara_' camara '_x_' tag_x '_y_' tag_y];
    
    saveas(h, [path 'camara_' camara '\centro_hexagono\' fig_name], 'png');
    saveas(h, [path 'camara_' camara '\centro_hexagono\' fig_name]);
    
end

% hago una nueva tabla que relaciona coordenadas en ccd con las coordenadas
% del centro del hexágono

output_file = fopen( [path 'camara_' camara '\centro_hexagono\LUT_centro_hexagono_camara_' camara '.txt'], 'wt' );
fprintf(output_file, 'tag_x\ttag_y\tcentro_x\tcentro_y\tx_ccd\ty_ccd\n');

for i = 1:N
    fprintf(output_file, '%d\t%d\t%f\t%f\t%f\t%f\n', tag_x_array(i), tag_y_array(i), centro_x_array(i), centro_y_array(i), x_ccd(i), y_ccd(i));
end

fclose all;
clear output_file;