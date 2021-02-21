function[] = separar_frames_utiles(path, camara)

    % camara es un entero que vale 1 o 2
    camara = num2str(camara);

    list = dir([path 'LUT_camara_' camara '*.png']);
    fnames = {list.name};

    for i = 1:numel(fnames)

        sprintf('Paso %d de %d', i, numel(fnames))

        filename = [path fnames{i}];

        % identificación del frame
        tag = strsplit(filename, '.');
        tag = tag{1};
        tag = strsplit(tag, 'camara_');
        tag = tag{2};
        tag = strsplit(tag, '_');
        camara = tag{1};
        tag_x = tag{4};
        tag_y = tag{6};

        frame = imread(filename);

        [datos_x, ~] = filtro_datos_nulos(frame);

        fig_name = ['camara_' camara '\LUT_camara_' camara '_frame_x_' tag_x '_y_' tag_y '.png'];

        % tiro frames donde no se vio nada, o se vio algún ruido nomás
        if numel(datos_x) <= 10
            continue
        end

        % los buenos los guardo en \camara_1 (o 2)
        imwrite(frame, [path fig_name]);

    end
end