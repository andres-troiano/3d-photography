function [centro_x, centro_y, r_teorico, r_individual, centro_individual] = mido_patron(frames_cilindro, id_cilindro, px2mmPol, offset, F, FC, path_plot)

    % id_cilindro es un str tipo '34700530'
    % frames_cilindro es un cell de 2 casilleros que tiene en cada uno el
    % directorio del frame de cada c�mara
    
    mc = {'ob', '.r'}; % markers para los cilindros
    mf = {'--b', '--r'}; % markers para las fronteras
    mfc = {'--c', '--m'}; % markers para las fronteras de calibracion
        
    %close all
    h1=figure(1);hold on
    XY = {[], []};
    r_individual = nan(2,1);
    centro_individual = {nan(2,1), nan(2,1)};
    
    % acá guardo los segmentos que uso para cada cámara para calcular los
    % span angulares. Una cámara en cada celda, X e Y uno en cada columna.
    % Son 2 segmentos por cámara.
    % Cada segmento tiene 2 puntos, pero hay 1 que es común a los 2
    % segmentos.
    segmentos_2_camaras = {nan(4,2), nan(4,2)};
    
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
        
        % convierto a mm las fronteras dadas por la calibraci�n
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
        % guardo los datos en una celda que junta las 2 c�maras
        xy = [x(ind), y(ind)];
        XY{q} = xy;
        
        %         plot(x,y,mc{q})
        figure(1)
        plot(XY{q}(:,1),XY{q}(:,2),mc{q})
        plot(F{q}(:,1), F{q}(:,2), mf{q})
        plot(FC{q}(:,1), FC{q}(:,2), mfc{q})
        
        % mart�n quiere ver cu�nto mide el radio calculado con cada c�mara
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
        title(['C�mara ' num2str(q)])
        saveas(h2, [path_plot id_cilindro '_error_C' num2str(q) '.png'])
        close(2)
        
        % calculo el �ngulo que ven las c�maras
        P0 = [centro_x, centro_y];
        P1 = [XY{q}(1,1), XY{q}(1,2)];
        P2 = [XY{q}(end,1), XY{q}(end,2)];
        angulo = calculo_angulo(P1, P0, P2, P0);
        fprintf('El �ngulo que ve C%d es %.0f�\n', q, angulo)
        
        % guardo los segmentos para calcular el span angular total
        segmentos_2_camaras{q} = [P1; P0; P2; P0];

    end
    
%     % calculo el �ngulo que ve C1
%     P0 = [centro_x, centro_y];
%     P1 = [XY{1}(1,1), XY{1}(1,2)];
%     P2 = [XY{1}(end,1), XY{1}(end,2)];
%     angulo = calculo_angulo(P1, P0, P2, P0);
%     fprintf('El �ngulo que ve C1 es %.0f�\n', angulo)

    % convierto la celda a matriz
%     XY = [XY{1}, XY{2}];
    XY = [XY{1}; XY{2}];

    % veo qu� tan circular es, y mido el di�metro
    circulo = TaubinNTN(XY);

    centro_x = circulo(1);
    centro_y = circulo(2);
    r_teorico = circulo(3);

    t = linspace(0, 2*pi, 100)';
    x_teorico = r_teorico * cos(t) + centro_x;
    y_teorico = r_teorico * sin(t) + centro_y;

    figure(1)
    plot(centro_x, centro_y, '+r')
    plot(x_teorico, y_teorico, '--k')

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
    title('2 c�maras combinadas')
    saveas(h3, [path_plot id_cilindro '_error_camaras_combinadas.png'])
    
    % grafico los 8 puntos a ver cuáles son los segmentos extremos
%     figure, hold on, grid on
%     plot(segmentos_2_camaras{1}(1:2,1), segmentos_2_camaras{1}(1:2,2), '-b')
%     plot(segmentos_2_camaras{1}(3:4,1), segmentos_2_camaras{1}(3:4,2), '--b')
%     plot(segmentos_2_camaras{2}(1:2,1), segmentos_2_camaras{2}(1:2,2), '-r')
%     plot(segmentos_2_camaras{2}(3:4,1), segmentos_2_camaras{2}(3:4,2), '--r')
%     axis equal
    
    % calculo span angular total
    % defino nuevos Pi
%     x1 = 0; %segmentos_2_camaras{1}(3,1);
%     x2 = 1; %segmentos_2_camaras{1}(4,1);
%     x3 = 0; %segmentos_2_camaras{1}(1,1);
%     x4 = 0; %segmentos_2_camaras{1}(2,1);
%     
%     y1 = 0; %segmentos_2_camaras{1}(3,2);
%     y2 = 0; %segmentos_2_camaras{1}(4,2);
%     y3 = 0; %segmentos_2_camaras{1}(1,2);
%     y4 = 1; %segmentos_2_camaras{1}(2,2);
    
    
    x1 = segmentos_2_camaras{1}(3,1);
    x2 = segmentos_2_camaras{1}(4,1);
    x3 = segmentos_2_camaras{2}(1,1);
    x4 = segmentos_2_camaras{2}(2,1);
    
    y1 = segmentos_2_camaras{1}(3,2);
    y2 = segmentos_2_camaras{1}(4,2);
    y3 = segmentos_2_camaras{2}(1,2);
    y4 = segmentos_2_camaras{2}(2,2);
    
%     figure, hold on, grid on
%     plot([x1, x2], [y1, y2], '--b')
%     plot([x3, x4], [y3, y4], '-r')
%     axis equal
    
    v1=[x2,y2]-[x1,y1];
    v2=[x4,y4]-[x3,y3];
    span_total=acos(sum(v1.*v2)/(norm(v1)*norm(v2)));
    
    % convierto de radianes a grados
    fprintf('El span angular total es %f\n', span_total*57.296)
    
end
