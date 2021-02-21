function[angulos_array, gamma_array] = calculo_angulo_perfil(lut, path, output_file)

    % no confundir con la funcion "calculo_angulo". Esa otra lo que hace es
    % calcular el ángulo entre 2 rectas. Esta analiza un perfil y te dice
    % el ángulo de la punta
    
    % camara es un str que vale '1' o '2' (o lo que sea)
    
    % output_file es la dirección del archivo donde guardo la tabla con los
    % ángulos

    % lo hago más fácil: tomo los 3 puntos que guardé en la lut y los
    % transformo
    % lo que grafico es la transformación

%     clear variables

%     camara = '1';
    set(0,'DefaultFigureVisible', 'off');

    camara = strsplit(lut, '.');
    camara = camara{1};
    camara = strsplit(camara, 'camara_');
    camara = camara{3};

    datos = importdata(lut, '\t', 1);
    datos = datos.data;

    tag_x_array = datos(:, 1);
    tag_y_array = datos(:, 2);
    x_stage = datos(:, 3);
    y_stage = datos(:, 4);
    x_ccd = datos(:, 5);
    y_ccd = datos(:, 6);
    x_P1 = datos(:, 7);
    y_P1 = datos(:, 8);
    x_P2 = datos(:, 9);
    y_P2 = datos(:, 10);

    N = numel(x_stage);

    % acá voy a guardar los ángulos
    
    % obs: "ángulos" es alpha (120). Le quedó ese nombre porque
    % históricamente era el único ángulo que calculaba
    angulos_array = zeros(N, 1);
    gamma_array = zeros(N, 1);
    
    file = fopen(output_file, 'wt' );
    fprintf(file, 'tag_x\ttag_y\tx_ccd\ty_ccd\talfa\tgamma\n');
    
%     N = 30;
    for i = 1:N
%     for i = 700
        
        
        
%         % esto no me gusta mucho. Cómo lo podría mejorar?
%         tag_x = num2str(round(x_stage(i)));
%         tag_y = num2str(round(y_stage(i)));
        
        tag_x = num2str(tag_x_array(i));
        tag_y = num2str(tag_y_array(i));

        % todo esto está en pixels
        punta = [x_ccd(i) y_ccd(i)];
        P1 = [x_P1(i) y_P1(i)];
        P2 = [x_P2(i) y_P2(i)];
        
        % cargo los datos curados
        datos_curados = importdata([path 'camara_' camara '\LUT_camara_' camara '_datos_curados_x_' tag_x '_y_' tag_y '.txt'], '\t', 1);
        datos_curados = datos_curados.data;
        
        % esto esta en pixels
        datos_curados_x = datos_curados(:, 1);
        datos_curados_y = datos_curados(:, 2);

        % transformo el perfil
         [x_mm, y_mm] = convertir_px_a_mm_polinomio(datos_curados_x, datos_curados_y, lut);

         % transformo los 3 puntos
         [x_ccd_mm, y_ccd_mm] = convertir_px_a_mm_polinomio(punta(1), punta(2), lut);
         [x_P1_mm, y_P1_mm] = convertir_px_a_mm_polinomio(P1(1), P1(2), lut);
         [x_P2_mm, y_P2_mm] = convertir_px_a_mm_polinomio(P2(1), P2(2), lut);

         punta_mm = [x_ccd_mm, y_ccd_mm];
         P1_mm = [x_P1_mm, y_P1_mm];
         P2_mm = [x_P2_mm, y_P2_mm];

        % calculo el ángulo entre las 2 rectas
        [angulo] = calculo_angulo(P1_mm, punta_mm, P2_mm, punta_mm);
        
        % calculo el ángulo "gamma" que da la inclinación del hexágono
        % para eso necesito darle 3 puntos (ver dibujo)
        % los llamo G1, G2, G3 (por gamma)
        
        % esto está en mm
        G1 = P1_mm;
        G2 = [punta_mm(1), P1_mm(2)];
        G3 = punta_mm;
        
        gamma = calculo_angulo(G1, G3, G1, G2);
        
        % con estos 3 puntos armo 2 rectas cuyo ángulo calculo con la
        % función que ya tengo:

        %%%%%%%%%%%%%% grafico en px %%%%%%%%%%%%%%

        close all

        % figure(1);
        % hold on
        % grid on
        % 
        % plot(datos_curados_x, datos_curados_y, '.-k')
        % plot(punta(1), punta(2), '*r')
        % plot(P1(1), P1(2), '*g')
        % plot(P2(1), P2(2), '*b')

        %%%%%%%%%%%%%% grafico en mm %%%%%%%%%%%%%%

        h = figure(2);
        hold on

        plot(x_mm, y_mm, '.-k')
        plot(punta_mm(1), punta_mm(2), '*r')
        plot(P1_mm(1), P1_mm(2), '*g')
        plot(P2_mm(1), P2_mm(2), '*b')
        tit = sprintf('Ángulo = %.2f º', angulo);
        title(tit)

        grid on
        xlabel('x (mm)')
        ylabel('y (mm)')
        
        % guardo el gráfico
        fig_name = ['angulos_camara_' camara '_x_' tag_x '_y_' tag_y];
        saveas(h, [path 'camara_' camara '\angulos\' fig_name], 'png');
        saveas(h, [path 'camara_' camara '\angulos\' fig_name]);
        
        %%%%%% escribo los datos en un file
        fprintf(file, '%d\t%d\t%f\t%f\t%f\t%f\n', tag_x_array(i), tag_y_array(i), x_ccd(i), y_ccd(i), angulo, gamma);
        
        %%%%%% armo un vector con los ángulos para devolver
        angulos_array(i) = angulo;
        gamma_array(i) = gamma;
        
        sprintf('Paso %d de %d, ángulo = %.2f', i, N, angulo)
        
    end
    
end
