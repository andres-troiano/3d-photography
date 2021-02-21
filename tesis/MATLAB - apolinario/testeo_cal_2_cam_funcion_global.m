function[punta_px, punta_py, datos_x_1, datos_y_1, recta_1, datos_x_2, datos_y_2, recta_2] = testeo_cal_2_cam_funcion_global(directorio_datos, directorio_lut, tag_x, tag_y, graficos, guardar)

    % tuerca de funcicion
%     r = 40.075/2;

    % tuerca maquinada
    r = 21.325/2;
%     alfa = 120;

    % calculo la punta de cada cámara. No me interesan los outputs
    testeo_cal_2_cam_funcion(directorio_datos, '1', tag_x, tag_y, 'off', 1);
    testeo_cal_2_cam_funcion(directorio_datos, '2', tag_x, tag_y, 'off', 1);
    
    
    lut_1 = [directorio_lut 'camara_1\LUT_curada_camara_1.txt'];
    lut_2 = [directorio_lut 'camara_2\LUT_curada_camara_2.txt'];
    
    % cargo cada perfil y lo desplazo
    
    % cargo el perfil 1
    datos_curados = importdata([directorio_datos 'camara_1\testeo_cal_camara_1_datos_curados_x_' tag_x '_y_' tag_y '.txt'], '\t', 1);
    datos_curados = datos_curados.data;

    % esto esta en pixels
    perfil_px = datos_curados(:, 1);
    perfil_py = datos_curados(:, 2);
    
    % cargo la punta 1
    datos = importdata([directorio_datos 'camara_1\testeo_cal_camara_1_coords_punta_x_' tag_x '_y_' tag_y '.txt'], '\t', 1);
    datos = datos.data;

    punta_px_1 = datos(:, 1);
    punta_py_1 = datos(:, 2);

    % transformo el perfil y la punta a mm
    [perfil_x_1, perfil_y_1] = convertir_px_a_mm_polinomio(perfil_px, perfil_py, lut_1);
    [punta_x_mm_1, punta_y_mm_1] = convertir_px_a_mm_polinomio(punta_px_1, punta_py_1, lut_1);

    
    
    
    % cargo el perfil 2
    datos_curados = importdata([directorio_datos 'camara_2\testeo_cal_camara_2_datos_curados_x_' tag_x '_y_' tag_y '.txt'], '\t', 1);
    datos_curados = datos_curados.data;

    % esto esta en pixels
    perfil_px = datos_curados(:, 1);
    perfil_py = datos_curados(:, 2);
    
    % cargo la punta 2
    datos = importdata([directorio_datos 'camara_2\testeo_cal_camara_2_coords_punta_x_' tag_x '_y_' tag_y '.txt'], '\t', 1);
    datos = datos.data;

    punta_px_2 = datos(:, 1);
    punta_py_2 = datos(:, 2);

    % transformo el perfil y la punta a mm
    [perfil_x_2, perfil_y_2] = convertir_px_a_mm_polinomio(perfil_px, perfil_py, lut_2);
    [punta_x_mm_2, punta_y_mm_2] = convertir_px_a_mm_polinomio(punta_px_2, punta_py_2, lut_2);
    
    
    
    

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



    % necesito valores de gamma 1,2

    datos1 = importdata([directorio_lut 'camara_1\angulos_camara_1.txt'], '\t', 1);
    datos1 = datos1.data;

    alfa_array_1 = datos1(:, 5);
    alfa_1 = mean(alfa_array_1);

    gamma_array_1 = datos1(:, 6);
    gamma_1 = mean(gamma_array_1);

    datos2 = importdata([directorio_lut 'camara_2\angulos_camara_2.txt'], '\t', 1);
    datos2 = datos2.data;

    alfa_array_2 = datos2(:, 5);
    alfa_2 = mean(alfa_array_2);

    gamma_array_2 = datos2(:, 6);
    gamma_2 = mean(gamma_array_2);

%     x_desplazado_1 = punta_x_1 + r*cosd(alfa_1/2 - gamma_1);
%     y_desplazado_1 = punta_y_1 - r*sind(alfa_1/2 - gamma_1);

    traslacion_x_1 = r*cosd(alfa_1/2 - gamma_1);
    traslacion_y_1 = - r*sind(alfa_1/2 - gamma_1);

    traslacion_x_2 = r*cosd(alfa_2/2 + gamma_2);
    traslacion_y_2 = - r*sind(alfa_2/2 + gamma_2);

%     error_x = abs( (punta_x_mm_1 + traslacion_x_1) - (punta_x_mm_2 + traslacion_x_2) );
%     error_y = abs( (punta_y_mm_1 + traslacion_y_1) - (punta_y_mm_2 + traslacion_y_2) );

    error_x = (punta_x_mm_1 + traslacion_x_1) - (punta_x_mm_2 + traslacion_x_2);
    error_y = (punta_y_mm_1 + traslacion_y_1) - (punta_y_mm_2 + traslacion_y_2);


%     [error_x, error_y]
    fprintf('(%d, %d), error x = %.3f, error y = %.3f\n', str2double(tag_x), str2double(tag_y), error_x, error_y)
    
    set(0,'DefaultFigureVisible', graficos);
    
    close all
    h = figure;
    hold on
    grid on

    plot(perfil_x_1, perfil_y_1, '--b')
    plot(perfil_x_2, perfil_y_2, '--r')

    % plot(punta_x_mm_1, punta_y_mm_1, '*b')
    % plot(punta_x_mm_2, punta_y_mm_2, '*r')

    plot(perfil_x_1 + traslacion_x_1, perfil_y_1 + traslacion_y_1, '.-b')
    plot(perfil_x_2 + traslacion_x_2, perfil_y_2 + traslacion_y_2, '.-r')

    plot(punta_x_mm_1 + traslacion_x_1, punta_y_mm_1 + traslacion_y_1, '*b')
    plot(punta_x_mm_2 + traslacion_x_2, punta_y_mm_2 + traslacion_y_2, '*r')
    
    tit = sprintf('error x = %.3f, error y = %.3f', error_x, error_y);
    title(tit)

    axis equal

    fig_name = ['test_cal_2_cam_hexagono_x_' tag_x '_y_' tag_y];
    
    if guardar == 1
        saveas(h, [directorio_datos fig_name], 'png');
    end

end