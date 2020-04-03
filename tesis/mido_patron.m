function [centro_x, centro_y, r_teorico] = mido_patron(frames_cilindro, id_cilindro, px2mmPol, offset, F, path_plot)

    % id_cilindro es un str tipo '34700530'
    % frames_cilindro es un cell de 2 casilleros que tiene en cada uno el
    % directorio del frame de cada cámara
    
    mc = {'ob', '.r'}; % markers para los cilindros
    mf = {'--b', '--r'}; % markers para las fronteras
        
    %close all
    h=figure;hold on
    XY = {[], []}; % acá habría que prealocar
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

        % desplazar el 2do
        if q == 2
            x = x-offset(1);
            y = y-offset(2);
        end

        % ahora que tengo definidos x,y, les aplico las fronteras
        ind = inpolygon(x, y, F{q}(:,1), F{q}(:,2));

%         plot(x,y,mc{q})
        plot(x(ind),y(ind),mc{q})
        plot(F{q}(:,1), F{q}(:,2), mf{q})
% 
        % guardo los datos en una celda que junta las 2 cámaras
        XY{1} = [XY{1}; x(ind)];
        XY{2} = [XY{2}; y(ind)];

    end

    % convierto la celda a matriz
    XY = [XY{1}, XY{2}];

    % veo qué tan circular es, y mido el diámetro
    circulo = TaubinNTN(XY);

    centro_x = circulo(1);
    centro_y = circulo(2);
    r_teorico = circulo(3);

    t = linspace(0, 2*pi, 100)';
    x_teorico = r_teorico * cos(t) + centro_x;
    y_teorico = r_teorico * sin(t) + centro_y;

    plot(centro_x, centro_y, '+r')
    plot(x_teorico, y_teorico, '--r')

    axis equal
    grid on
    xlabel('X (mm)')
    ylabel('Y (mm)')
    title(id_cilindro)
    
    saveas(h, [path_plot 'medicion\'  id_cilindro '_medicion.png'])
    
end