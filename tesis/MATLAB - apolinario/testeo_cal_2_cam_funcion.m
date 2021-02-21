function[punta_px, punta_py, datos_x_1, datos_y_1, recta_1, datos_x_2, datos_y_2, recta_2] = testeo_cal_2_cam_funcion(directorio, camara, tag_x, tag_y, graficos, guardar)

    % graficos vale 'on', 'off'
    % guardar vale 1 o 0

    dir_camara = ['camara_' camara '\'];

    set(0,'DefaultFigureVisible', graficos);

    filename = [directorio dir_camara 'LUT_camara_' camara '_frame_x_' tag_x '_y_' tag_y '.png'];

    frame = imread(filename);

    y_original = median(frame);
    y_original = double(y_original)/2^4;

    x_original = 1:1:numel(y_original);

    [x, y] = tiro_datos_nulos_perfil(x_original, y_original);

    [x, y] = filtro_ruido_basico(x, y);

%     x = x(3:end-2);
%     y = y(3:end-2);       

    [datos_x, datos_y] = tiro_mitad_datos_opuestos(x, y, camara);
 
% tenía 2
    for j = 1:2

        [datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2, delta_1, delta_2] = receta_tuerca_inclinada(datos_x, datos_y, camara);
        [punta_px, punta_py] = calculo_punta_dados_parametros(a1, b1, a2, b2);

        if numel(datos_y_1) == 0
            continue
        end
        
        [datos_x_1, datos_y_1, datos_x_2, datos_y_2, a1, b1, a2, b2] = recupero_datos_validos_calculo_punta(x, y, datos_x_1, datos_y_1, datos_x_2, datos_y_2, recta_1, recta_2, delta_1, delta_2, punta_px, punta_py, a1, a2, b1, b2);
        
    end
    
    

%     close all
%     figure
%     hold on
%     grid on
%     
%     plot(x, y, '.-b')
%     plot(datos_x, datos_y, '.r')
%     plot(datos_x_1, datos_y_1, '.g')
%     plot(datos_x_2, datos_y_2, '.y')
%     
%     [datos_x_1, datos_y_1, datos_x_2, datos_y_2, a1, b1, a2, b2] = recupero_datos_validos_calculo_punta(x, y, datos_x_1, datos_y_1, datos_x_2, datos_y_2, recta_1, recta_2, delta_1, delta_2, punta_px, punta_py, a1, a2, b1, b2);
%     [punta_px, punta_py] = calculo_punta_dados_parametros(a1, b1, a2, b2);

    %%%%%%%%%%%%%%%%%%%%%%% gráfico %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    close all
    h = figure(1);
    hold on
    grid on

    plot(x_original, y_original, '.-c')
    plot(x, y, '.k')
    plot(datos_x, datos_y, '.b')
    plot(datos_x_1, datos_y_1, '.g')
    plot(datos_x_2, datos_y_2, '.y')
    plot(punta_px, punta_py, '*r')

    xlabel('pixel x')
    ylabel('pixel y')

    margen = 100;

    datos_x = [datos_x_1, datos_x_2];
    datos_y = [datos_y_1, datos_y_2];

    if numel(datos_x) > 0
        xlim([min(datos_x)-margen max(datos_x)+margen])
        ylim([min(datos_y)-margen max(datos_y)+margen])
    end

%     xlim([min(x) max(x)])
%     ylim([min(y) max(y)])

    % xlim([min([datos_x_1, datos_x_2])-margen max([datos_x_1, datos_x_2])+margen])
    % ylim([min([datos_y_1, datos_y_2])-margen max([datos_y_1, datos_y_2])+margen])

    fig_name = ['plot_camara_' camara '_x_' tag_x '_y_' tag_y];
    
    if guardar == 1
        saveas(h, [directorio dir_camara fig_name], 'png');
    end

    
    
    % guardo el perfil en txt
    output_datos_curados = fopen( [directorio dir_camara 'testeo_cal_camara_' camara '_datos_curados_x_' tag_x '_y_' tag_y '.txt'], 'wt' );
    fprintf(output_datos_curados, 'datos_x\tdatos_y\n');

    for j = 1:numel(x)
        fprintf(output_datos_curados, '%f\t%f\n', x(j), y(j));
    end

    fclose all;
    clear output_datos_curados;
    
    
    % guardo un txt adicional con las coords de la punta
    output_datos_curados = fopen( [directorio dir_camara 'testeo_cal_camara_' camara '_coords_punta_x_' tag_x '_y_' tag_y '.txt'], 'wt' );
    
    fprintf(output_datos_curados, 'punta_px\tpunta_py\n');
    fprintf(output_datos_curados, '%f\t%f\n', punta_px, punta_py);

    fclose all;
    clear output_datos_curados;
    
end