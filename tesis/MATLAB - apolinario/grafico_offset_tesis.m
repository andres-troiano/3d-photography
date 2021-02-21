function [centro_x, centro_y, r_teorico, r_individual, centro_individual] = grafico_offset_tesis(frames_cilindro, id_cilindro, px2mmPol, offset, F, FC, path_plot)

    % modificación de "mido_patron", para correr una de las cámaras de
    % manera que los centros de las circunferencias medidas por las 2
    % cámaras individualmente coincidan
    
    mc = {'.b', '.r'}; % markers para los cilindros
    mf = {'--b', '--r'}; % markers para las fronteras
    mfc = {'--c', '--m'}; % markers para las fronteras de calibracion
        
    %close all
    h1=figure(1);hold on
    XY = {[], []};
    r_individual = nan(2,1);
    centro_individual = {nan(2,1), nan(2,1)};
    for q = 1:2

        I=imread(frames_cilindro{q});
        Iinfo=imfinfo(frames_cilindro{q});
        if ~isempty(Iinfo.SignificantBits)
            I=bitshift(I,Iinfo.SignificantBits-16);
        elseif ~isempty(Iinfo.BitDepth)
            I=double(I)/Iinfo.BitDepth;
        end
        I=double(I);
        frame = I;

        py = median(frame);
        px = 1:size(py,2);
        [px, py] = tiro_datos_nulos_perfil(px, py);
        px = px.';
        py = py.';

        py = 1088-py;

        x = polyval4XY(px2mmPol{q}(1), px, py);
        y = polyval4XY(px2mmPol{q}(2), px, py);
        
        % convierto a mm las fronteras dadas por la calibración
        temp_x = polyval4XY(px2mmPol{q}(1), FC{q}(:,1), FC{q}(:,2));
        temp_y = polyval4XY(px2mmPol{q}(2), FC{q}(:,1), FC{q}(:,2));
        FC{q} = [temp_x, temp_y];
        
        % para medir con calibraciones viejas necesito ignorar toda
        % frontera
        ind = true(numel(x),1);
        
% 
        % guardo los datos en una celda que junta las 2 cámaras
        xy = [x(ind), y(ind)];
        XY{q} = xy;
        
        % martín quiere ver cuánto mide el radio calculado con cada cámara
        % por separado
        circulo = TaubinNTN(xy);
        centro_x = circulo(1);
        centro_y = circulo(2);
        r_individual(q) = circulo(3);
        centro_individual{q} = [centro_x, centro_y];

    end
    
    % corrijo el cálculo de los errores individuales ahora que hice
    % coincidir los centros
    error_individual = {[], []};
    error_individual{1} = r_individual(1) - sqrt((XY{1}(:,1) - centro_individual{1}(1)).^2 + (XY{1}(:,2) - centro_individual{1}(2)).^2);
    error_individual{2} = r_individual(2) - sqrt((XY{2}(:,1) - centro_individual{2}(1)).^2 + (XY{2}(:,2) - centro_individual{2}(2)).^2);

    % ojo, esto no se puede hacer después de concatenar los 2 perfiles
    
    plot(XY{1}(:,1),XY{1}(:,2),mc{1})
    plot(XY{2}(:,1),XY{2}(:,2),mc{2}) % ahora esto va a estar corrido
    
    % las fronteras no me molesto en correrlas porque de acá en más no las
    % uso más

    % convierto la celda a matriz
    XY = [XY{1}; XY{2}];

    % veo qué tan circular es, y mido el diámetro
    circulo = TaubinNTN(XY); % ahora estoy ajustando con la parte 2 corrida

    centro_x = circulo(1);
    centro_y = circulo(2);
    r_teorico = circulo(3);

    t = linspace(0, 2*pi, 100)';
    x_teorico = r_teorico * cos(t) + centro_x;
    y_teorico = r_teorico * sin(t) + centro_y;

    figure(1)
    plot(centro_individual{1}(1), centro_individual{1}(2), '*b')
    plot(centro_individual{2}(1), centro_individual{2}(2), '*r')

    axis equal
    grid on
    xlabel('X (mm)')
    ylabel('Y (mm)')
    title(id_cilindro)
    
    saveas(h1, [path_plot id_cilindro '_calculo_offset_trapecio.png'])
    [path_plot id_cilindro '_calculo_offset_trapecio.png']

end