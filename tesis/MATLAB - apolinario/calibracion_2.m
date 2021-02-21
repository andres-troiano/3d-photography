% calibración con el trapecio.
% Modificación del original que calcula el offset a partir de la
% discrepancia en los centros de círculos ajustados con las 2 cámaras
% Otra diferencia es que calcula el +-35 ANTES de calcular el offset, lo
% cual permite que el offset se calcule sólo en la zona válida, lo cual en
% el caso del hexágono se vio que elimina una estructura apreciable del
% offset en función de x,y

clear variables
%datos nuevos
path_calibracion = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion42\';
path_offset = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion43\';

%%

% clasifico los datos, eliminando aquellas capturas en las que no se vio
% nada
creo_directorios_2_camaras(path_calibracion);
separar_frames_utiles(path_calibracion, 1);
separar_frames_utiles(path_calibracion, 2);
% acá estaría bueno eliminar los archivos originales, para no tenerlos
% duplicados
convertFiles2DotMatPath(path_calibracion);

%%

% encuentro la posición de las esquinas del patrón
% calculateIntersectionsPath(path_calibracion);

% además de la zona de interés, genero fronteras de la
% zona que efectivamente pude calibrar (en caso de no haber llenado
% la zona de interés)
% fronteraZonaEfectiva(path_calibracion);

load([path_calibracion 'intersections.mat']);
% teniendo las coordenadas de cada esquina en mm y en pixels, calibro el
% sistema
calculateCalibration(C, path_calibracion);

%% calculo las fronteras antes del offset

clear variables

path_datos= 'C:\Users\Norma\Downloads\datos_calibraciones\medicion48\';
path_calibracion = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion42\';

load([path_calibracion 'calibration.mat']);

% determinar el centro del cilindro 630
frames = {'patron_34700630_camara_1.png', 'patron_34700630_camara_2.png'};

close all,figure(1),hold on
XY = {[], []}; % acá habría que prealocar
% coordenadas de los puntos centrales de cada perfil, en mm. En columnas:
% xc;yc
M = {nan(2,1), nan(2,1)};
% este valor me sirve para separar los datos de cada cámara después de
% haberlos juntado en XY, así no los tengo que volver a procesar
s = nan; 
R = {nan(200,2), nan(200,2)};
F = {nan(1e3,2),nan(1e3,2)};
for q = 1:2
    
    I=imread(fullfile(path_datos, frames{q}));
    Iinfo=imfinfo(fullfile(path_datos, frames{q}));
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
    
    if q == 1
        s = numel(py);
    end
    
    % ubico índice correspondiente al máximo en píxels, que corresponde al
    % punto central del arco
    [m,i] = max(py);
    
    x = polyval4XY(px2mmPol{q}(1), px, py);
    y = polyval4XY(px2mmPol{q}(2), px, py);
    
    % guardo los puntos centrales de cada perfil
    xc = x(i);
    yc = y(i);
    M{q}(:) = [xc;yc];
    
    if q == 1
        plot(x,y,'ob')
    end
    
    if q == 2
        plot(x,y,'.r')
    end
    
    axis equal
    grid on
    xlabel('X (mm)')
    ylabel('Y (mm)')
    
    XY = [x,y];
    
    circulo = TaubinNTN(XY);

    centro_x = circulo(1);
    centro_y = circulo(2);
    r_teorico = circulo(3);
    
    t = linspace(0, 2*pi, 100)';
    x_teorico = r_teorico * cos(t) + centro_x;
    y_teorico = r_teorico * sin(t) + centro_y;
    
    plot(x_teorico, y_teorico, '--k')
    plot(centro_x, centro_y, '+r')
    
    r_int = r_teorico - 40;
    r_ext = r_teorico + 40;

    t = {linspace(-1.2,0.1)', linspace(-2.3,-1)'};
    m = {'--b', '--r'}; % markers
    
    x_int = centro_x + r_int*cos(t{q});
    y_int = centro_y + r_int*sin(t{q});

    x_ext = centro_x + r_ext*cos(t{q});
    y_ext = centro_y + r_ext*sin(t{q});

    plot(x_int, y_int, m{q})
    plot(x_ext, y_ext, m{q})

    % flipeo el externo para que vaya en el sentido del recorrido
    x_ext = flipud(x_ext);
    y_ext = flipud(y_ext);
    
    R{q}(:,:) = [[x_int;x_ext], [y_int;y_ext]];
    
    j = 1;
    k = 100; % porque sé que cada parte radial es un linspace de 100
    F{q}(j:k,:) = [R{q}(101:200,1), R{q}(101:200,2)];
    
    alpha = calculo_angulo([0, 0], [0, 1], [M{q}(1), M{q}(2)], [centro_x, centro_y]);
    
    alpha_izq = alpha + 35;
    alpha_der = alpha - 35;
    
    % otro parche horrible xq en la 1 me quedan invertidas las rectas izq y
    % der
    
    if q == 1
        alpha_der = alpha + 35;
        alpha_izq = alpha - 35;
    end
    
    a = tand(alpha+90); % esto está horriblemente emparchado. Debería entenderlo
    if q==2
        a=tand(90-alpha);
    end
    y_recta = a*x + (centro_y - a*centro_x);
    
%     % ajusto finamente las rectas para armar la máscara
%     % primero el X izquierdo

    a = tand(alpha_izq+90);
    if q==2
        a=tand(90-alpha_izq);
    end
    
    if q==1
        x_izq=linspace(107,142)';
        x_izq = flipud(x_izq);
    end
    
    if q==2
        x_izq=linspace(64,114)';
    end
    y_izq = a*x_izq + (centro_y - a*centro_x);
    
    % agrego a las fronteras
    j = k+1;
    k = k + numel(x_izq);
    F{q}(j:k,:) = [x_izq, y_izq];
    
    j = k+1;
    k = k + 100;
    F{q}(j:k,:) = [R{q}(1:100,1), R{q}(1:100,2)];
    
    % ahora la recta derecha
    if q==1
        x_der=linspace(132,213)';
    end
    
    if q==2
        x_der=linspace(164,208)';
    end

    a = tand(alpha_der+90);
    if q==2
        a=tand(90-alpha_der);
    end
    y_der = a*x_der + (centro_y - a*centro_x);
    
    % agrego a la frontera
    j = k+1;
    k = k + numel(x_der);
    F{q}(j:k,:) = [x_der, y_der];
    
    plot(centro_x, centro_y, '+b')
    
    if q == 1
        plot(x_izq, y_izq, '--b')
        plot(x_der, y_der, '--b')
    end
    
    if q == 2
        plot(x_izq, y_izq, '--r')
        plot(x_der, y_der, '--r')
    end
    
%     plot(x, y_recta, '--k')
    
    % elimino los nan
    ind2 = ~isnan(F{q}(:,1));
    F{q} = F{q}(ind2, :);

end

plot(M{1}(1), M{1}(2), 'og')
plot(M{2}(1), M{2}(2), 'og')

save(fullfile(path_calibracion, 'fronteras_2'),'F');

%% calculo el offset a partir de los círculos, usando sólo las zonas válidas

% ya que estoy, calculo el offset con los 3 cilindros, a ver si cambia
% mucho o no

clear variables, clc

% para trabajar con datos nuevos:
path_datos = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion48\';
path_fronteras = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion42\';
path_calibracion = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion42\';

load([path_calibracion 'calibration.mat']);
load([path_fronteras 'fronteras_2.mat']);
load([path_calibracion 'FC.mat']);

mc = {'ob', '.r'}; % markers para los cilindros
mf = {'--b', '--r'}; % markers para las fronteras
mfc = {'--c', '--m'}; % markers para las fronteras de calibracion

frame_cilindro = {'patron_34700530', 'patron_34700630', 'patron_34700730'};
id_cilindro={'34700530', '34700630', '34700730'};

% convierto a mm las fronteras dadas por la calibración
for q = 1:2
    temp_x = polyval4XY(px2mmPol{q}(1), FC{q}(:,1), FC{q}(:,2));
    temp_y = polyval4XY(px2mmPol{q}(2), FC{q}(:,1), FC{q}(:,2));
    FC{q} = [temp_x, temp_y];
end

offset_distinto_radio = nan(3,2);
for k=2%1:3

    for q = 1:2
        frames_cilindro{q} = [path_datos frame_cilindro{k} '_camara_' num2str(q) '.png'];
    end

    close all
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

        % ahora que tengo definidos x,y, les aplico las fronteras
        ind1 = inpolygon(x, y, F{q}(:,1), F{q}(:,2));
        ind2 = inpolygon(x, y, FC{q}(:,1), FC{q}(:,2));

        ind = ind1&ind2;

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

    offset_centros = centro_individual{2} - centro_individual{1};
    offset_distinto_radio(k,:) = offset_centros;
    fprintf('Patrón %s, offset = (%.3f, %.3f)\n', id_cilindro{k}, offset_centros(1), offset_centros(2))

    centro_individual{2} = centro_individual{2};
    XY{2} = [XY{2}(:,1), XY{2}(:,2)];

    % corrijo el cálculo de los errores individuales ahora que hice
    % coincidir los centros
    error_individual = {[], []};
    error_individual{1} = r_individual(1) - sqrt((XY{1}(:,1) - centro_individual{1}(1)).^2 + (XY{1}(:,2) - centro_individual{1}(2)).^2);
    error_individual{2} = r_individual(2) - sqrt((XY{2}(:,1) - centro_individual{2}(1)).^2 + (XY{2}(:,2) - centro_individual{2}(2)).^2);

    for q = 1:2
        h2=figure(q); hold on, grid on
        plot(XY{q}(:,1), error_individual{q}, '.')
        xlabel('X (mm)')
        ylabel('Error radial (mm)')
        title(['Cámara ' num2str(q)])
    end
    
    h1=figure(3); hold on, grid on
    t = linspace(0, 2*pi, 100)';
    for q = 1:2
        x_teorico = r_individual(q) * cos(t) + centro_individual{q}(1);
        y_teorico = r_individual(q) * sin(t) + centro_individual{q}(2);
        plot(x_teorico, y_teorico, '--k')
    end

    % ojo, esto no se puede hacer después de concatenar los 2 perfiles
    
    plot(XY{1}(:,1),XY{1}(:,2),'.b')
    plot(F{1}(:,1), F{1}(:,2), mf{1})
    plot(FC{1}(:,1), FC{1}(:,2), mfc{1})
    plot(XY{2}(:,1),XY{2}(:,2),mc{2}) % ahora esto va a estar corrido
    plot(F{2}(:,1), F{2}(:,2), mf{2})
    plot(FC{2}(:,1), FC{2}(:,2), mfc{2})

    % convierto la celda a matriz
    XY = [XY{1}; XY{2}];

    figure(3)
    plot(centro_individual{1}(1), centro_individual{1}(2), '+b')
    plot(centro_individual{2}(1), centro_individual{2}(2), '+r')

    axis equal
    grid on
    xlabel('X (mm)')
    ylabel('Y (mm)')
    title(id_cilindro{k})
%     title('Cámara 2')

%     saveas(h1, [path_plot 'centros_coincidentes\'  id_cilindro '_medicion.png'])
%     saveas(h1, 'C:\Users\Norma\Downloads\imagenes tesis\zona_valida_C2.png')

end

% calculo el offset promedio y lo guardo
offset = [mean(offset_distinto_radio(:,1)), mean(offset_distinto_radio(:,2))];
% save(fullfile(path_calibracion, 'offset'),'offset');
    
%% ahora mido los patrones

clear variables, clc

% para trabajar con datos nuevos:
path_datos = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion48\';
path_calibracion = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion42\';

load([path_calibracion 'calibration.mat']);
load([path_calibracion 'offset.mat']);
load([path_calibracion 'fronteras.mat']);
load([path_calibracion 'FC.mat']);

frame_cilindro = {'patron_34700530', 'patron_34700630', 'patron_34700730'};
id_cilindro = {'34700530', '34700630', '34700730'};
nominales = [139.707, 168.310, 177.805];

frames_cilindro = {[], []};

for f = 1:3
    close all
    for q = 1:2
        frames_cilindro{q} = [path_datos frame_cilindro{f} '_camara_' num2str(q) '.png'];
    end
    [centro_x, centro_y, r_teorico, r_individual, centro_individual] = mido_patron(frames_cilindro, id_cilindro{f}, px2mmPol, offset, F, FC, path_datos); % haciendo coincidir los 2 centros
    fprintf([id_cilindro{f} '\nError 2 cámaras: %.3f mm\nError C1: %.3f mm, Error C2: %.3f mm\nCentro global: (%.3f, %.3f)\nCentro C1: (%.3f, %.3f)\nCentro C2: (%.3f, %.3f)\n\n'], 2*r_teorico - nominales(f), 2*r_individual(1) - nominales(f), 2*r_individual(2) - nominales(f), centro_x, centro_y, centro_individual{1}(1), centro_individual{1}(2), centro_individual{2}(1), centro_individual{2}(2))
end