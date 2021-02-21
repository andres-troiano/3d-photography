% el esquema es el siguiente:

% * cargo un frame
% * lo convierto a mm
% * usando x_ccd de la LUT y convirtiéndolo a mm, separo en 2 regiones,
% dejando un margen para evitar la punta. Ajusto de cada lado, y me quedo
% con 2 puntos de cada lado
% * con esos 2 pares de puntos, calculo el ángulo como hice en el estudio de
% taubin

clear variables

camara = '1';

% al cargar los frames desde la LUT, ya estoy pasando por alto todos los
% frames que descarté

path = 'C:\Users\60069978\Documents\MATLAB\medicion10\';

% cargo el txt que tiene las coords medidas
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lut = [path 'camara_' camara '\LUT_camara_' camara '.txt'];

datos = importdata(lut, '\t', 1);
datos = datos.data;

x_stage = datos(:, 1);
y_stage = datos(:, 2);
x_ccd = datos(:, 3);
y_ccd = datos(:, 4);

set(0,'DefaultFigureVisible', 'off')

output_file = fopen( [path 'camara_' camara '\angulos\tabla_angulos_camara_' camara '.txt'], 'wt' );
fprintf(output_file, 'x_stage\ty_stage\tx_ccd\ty_ccd\tangulo\n');

for i = 1:numel(x_stage)
% for i = 58

    sprintf('Paso %d de %d', i, numel(x_stage))
    
    % cargo el txt, y de la LUT saco el valor pixel_x de la punta, para separar
    % las regiones
    tag_x = num2str(round(x_stage(i)));
    tag_y = num2str(round(y_stage(i)));
    
    coord_px_punta = x_ccd(i);
    
    % cargo los datos curados
    datos_curados = importdata([path 'camara_' camara '\LUT_camara_' camara '_datos_curados_x_' tag_x '_y_' tag_y '.txt'], '\t', 1);
    datos_curados = datos_curados.data;

    % esto esta en pixels
    datos_curados_x = datos_curados(:, 1);
    datos_curados_y = datos_curados(:, 2);
    
    % convierto a mm
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [x_mm, y_mm] = convertir_px_a_mm_polinomio(datos_curados_x, datos_curados_y, lut);
    
    % identifico 2 puntos de cada recta
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % separo los datos en 2 regiones, dejando un margen de 1 mm alrededor de la
    % punta, porque capaz salió redondeada
    % (dejo afuera 0.5 mm de cada lado)
    
    margen = 0.5;
    coord_x_punta = x_stage(i);
    
    filtro_1 = x_mm < coord_x_punta - margen;
    x_1 = x_mm(filtro_1);
    y_1 = y_mm(filtro_1);
    
    filtro_2 = x_mm > coord_x_punta + margen;
    x_2 = x_mm(filtro_2);
    y_2 = y_mm(filtro_2);
    
    % ojo, acá estoy descartando perfiles sin guardarlos en descarte
    if numel(x_2) == 0
        continue
    end
    
    % ajusto en cada región
    [pol_1, S_1] = polyfit(x_1, y_1, 1);
    [pol_2, S_2] = polyfit(x_2, y_2, 1);

    [recta_1, delta_1] = polyval(pol_1, x_1, S_1);
    [recta_2, delta_2] = polyval(pol_2, x_2, S_2);
    
    % tomo 2 puntos de cada recta
    % P1, P2 pertenecen a la recta 1
    % P3, P4 pertenecen a la recta 2
    P1_x = x_1(1);
    P1_y = recta_1(1);
    
    P2_x = x_1(end);
    P2_y = recta_1(end);
    
    P3_x = x_2(1);
    P3_y = recta_2(1);
    
    P4_x = x_2(end);
    P4_y = recta_2(end);
    
    % calculo el ángulo entre las 2 rectas
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    L1 = [P1_x, P1_y] - [P2_x, P2_y];
    L2 = [P3_x, P3_y] - [P4_x, P4_y];
    angulo = acos(sum(L1.*L2)/(norm(L1)*norm(L2)));
    angulo = rad2deg(angulo);
    
    %%%%%%%%%%%%%% grafico %%%%%%%%%%%%%%
    
    close all
    h = figure(1);
    hold on
    
    plot(x_mm, y_mm, '.-k')
    plot(x_1, y_1, '.r')
    plot(x_2, y_2, '.g')
    plot(x_1, recta_1, '--g')
    plot(x_2, recta_2, '--r')
    plot(P1_x, P1_y, '*b')
    plot(P2_x, P2_y, '*r')
    plot(P3_x, P3_y, '*m')
    plot(P4_x, P4_y, '*c')
    tit = sprintf('Ángulo = %.2f º', angulo);
    title(tit)
    
    grid on
    xlabel('x (mm)')
    ylabel('y (mm)')
    
    fig_name = ['mm_camara_' camara '_x_' tag_x '_y_' tag_y];
    saveas(h, [path 'angulos\camara_' camara '\' fig_name], 'png');
    saveas(h, [path 'angulos\camara_' camara '\' fig_name]);

    fprintf(output_file, '%f\t%f\t%f\t%f\t%f\n', x_stage(i), y_stage(i), x_ccd(i), y_ccd(i), angulo);
    
end

fclose all;
clear output_file;