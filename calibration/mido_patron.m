function [centro_x, centro_y, r_teorico, r_individual, centro_individual] = mido_patron(frames_cilindro, id_cilindro, px2mmPol, offset, F, FC, path_plot)

    % id_cilindro es un str tipo '34700530'
    % frames_cilindro es un cell de 2 casilleros que tiene en cada uno el
    % directorio del frame de cada cámara
    
    mc = {'ob', '.r'}; % markers para los cilindros
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

        % desplazar el 2do
        if q == 2
            x = x-offset(1);
            y = y-offset(2);
            
            FC{q} = [FC{q}(:,1)-offset(1), FC{q}(:,2)-offset(2)];
        end

        % ahora que tengo definidos x,y, les aplico las fronteras
        ind1 = inpolygon(x, y, F{q}(:,1), F{q}(:,2));
        ind2 = inpolygon(x, y, FC{q}(:,1), FC{q}(:,2));
%         ind1 = true(size(ind1)); % OJO! esto es para usar calibraciones viejas en las que no lo tengo definido
        
        ind = ind1&ind2;
        
        % para medir con calibraciones viejas necesito ignorar toda
        % frontera
%         ind = true(numel(x),1);
        
% 
        % guardo los datos en una celda que junta las 2 cámaras
        xy = [x(ind), y(ind)];
        XY{q} = xy;
        
        %         plot(x,y,mc{q})
        figure(1)
        plot(XY{q}(:,1),XY{q}(:,2),mc{q})
        plot(F{q}(:,1), F{q}(:,2), mf{q})
        plot(FC{q}(:,1), FC{q}(:,2), mfc{q})
        
        % martín quiere ver cuánto mide el radio calculado con cada cámara
        % por separado
        circulo = TaubinNTN(xy);
        centro_x = circulo(1);
        centro_y = circulo(2);
        r_individual(q) = circulo(3);
        centro_individual{q} = [centro_x, centro_y];
        
        error = r_individual(q) - sqrt((xy(:,1) - centro_x).^2 + (xy(:,2) - centro_y).^2);
        h2=figure(2); hold on, grid on
        plot(xy(:,1), error, '.')
        xlabel('X (mm)')
        ylabel('Error radial (mm)')
        title(['Cámara ' num2str(q)])
        saveas(h2, [path_plot id_cilindro '_error_C' num2str(q) '.png'])
        close(2)

    end

    % convierto la celda a matriz
%     XY = [XY{1}, XY{2}];
    XY = [XY{1}; XY{2}];

    % veo qué tan circular es, y mido el diámetro
    circulo = TaubinNTN(XY);

    centro_x = circulo(1);
    centro_y = circulo(2);
    r_teorico = circulo(3);

    t = linspace(0, 2*pi, 100)';
    x_teorico = r_teorico * cos(t) + centro_x;
    y_teorico = r_teorico * sin(t) + centro_y;

    figure(1)
    plot(centro_x, centro_y, '+r')
    plot(x_teorico, y_teorico, '--r')

    axis equal
    grid on
    xlabel('X (mm)')
    ylabel('Y (mm)')
    title(id_cilindro)
    
    saveas(h1, [path_plot id_cilindro '_medicion.png'])

    % calculo el residuo del ajuste y lo grafico
    error = r_teorico - sqrt((XY(:,1) - centro_x).^2 + (XY(:,2) - centro_y).^2);
    h3=figure(3); hold on, grid on
    plot(XY(:,1), error, '.')
    xlabel('X (mm)')
    ylabel('Error radial (mm)')
    title('2 cámaras combinadas')
    saveas(h3, [path_plot id_cilindro '_error_camaras_combinadas.png'])
    
end
