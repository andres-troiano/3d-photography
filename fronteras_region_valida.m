% script para generar las fronteras de la región donde queremos trabajar
% (rosca determinada por el radio del patrón "630" +- 50 mm).
% Para calcular el centro del patrón necesito primero tener una
% calibración. Uso la del trapecio.

clear variables

path_calibracion = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion42\';
path_offset = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion43\';
path_datos= 'C:\Users\Norma\Downloads\datos_calibraciones\medicion48\';

load([path_calibracion 'calibration.mat']);
load([path_offset 'offset.mat']);

% determinar el centro del cilindro 630
frames = {'patron_34700630_camara_1.png', 'patron_34700630_camara_2.png'};

close all,figure,hold on
XY = {[], []};
% coordenadas de los puntos centrales de cada perfil, en mm. En columnas:
% xc;yc
M = {nan(2,1), nan(2,1)};
% este valor me sirve para separar los datos de cada cámara después de
% haberlos juntado en XY, así no los tengo que volver a procesar
s = nan; 
for q = 1:2
    frame = imread(fullfile(path_datos, frames{q}));
    
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
    
    % desplazar el 2do
    if q == 2
        x = x-offset(1);
        y = y-offset(2);
    end
    
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
    
    % guardo los datos en una celda que junta las 2 cámaras
    XY{1} = [XY{1}; x];
    XY{2} = [XY{2}; y];

end

% convierto la celda a matriz
XY = [XY{1}, XY{2}];

% veo qué tan circular es, y mido el diámetro
circulo = TaubinNTN(XY);

centro_x = circulo(1);
centro_y = circulo(2);
r_teorico = circulo(3);

t = linspace(0, 2*pi, 100);
x_teorico = r_teorico * cos(t) + centro_x;
y_teorico = r_teorico * sin(t) + centro_y;

% plot(x_teorico, y_teorico, '--r')
plot(centro_x, centro_y, '+r')
plot(M{1}(1), M{1}(2), 'og')
plot(M{2}(1), M{2}(2), 'om')

%%

% ahora que tengo la posición del centro del sistema, armo la máscara que
% necesito. Se compone de 2 cosas:
% 1) mirar sólo un rango de ángulos
% 2) mirar sólo un rango de radios

for q = 1:2
    
    if q == 1
        x = XY(1:s, 1);
        y = XY(1:s, 2);
    end
    
    if q == 2
        x = XY(s+1:end, 1);
        y = XY(s+1:end, 2);
    end
    
    alpha = calculo_angulo([0, 0], [0, 1], [M{q}(1), M{q}(2)], [centro_x, centro_y]);

    alpha_izq = alpha + 35;
    alpha_der = alpha - 35;
    
    a = tand(alpha+90); % esto lo emparché a mano
    y_recta = a*x + (centro_y - a*centro_x);

    a = tand(alpha_izq+90);
    y_recta_izq = a*x + (centro_y - a*centro_x);

    a = tand(alpha_der+90);
    y_recta_der = a*x + (centro_y - a*centro_x);
    
    plot(centro_x, centro_y, '+b')
    
    if q == 1
        plot(x, y_recta_izq, '--b')
        plot(x, y_recta_der, '--b')
    end
    
    if q == 2
        plot(x, y_recta_izq, '--r')
        plot(x, y_recta_der, '--r')
    end
    
end

axis equal
margen = 50;
xlim([min(XY(:, 1))-margen max(XY(:, 1))+margen])
ylim([min(XY(:, 2))-margen max(XY(:, 2))+margen])

%%

% ahora acoto el rango de radios, y al final genero 2 fronteras combinando
% ambas cosas

r_int = r_teorico - 50;
r_ext = r_teorico + 50;

x_int = centro_x + r_int*cos(t);
y_int = centro_y + r_int*sin(t);

x_ext = centro_x + r_ext*cos(t);
y_ext = centro_y + r_ext*sin(t);

plot(x_int, y_int, '--k')
plot(x_ext, y_ext, '--k')

%%

% ahora genero la frontera con todo
% chequeo que lo estoy haciendo bien con datos de prueba

load([path_calibracion 'intersections.mat']);

for q = 1:2

    ind1=C{q}(:,6)>.4;
    ind2=C{q}(:,8)>.4;
    ind3=C{q}(:,7)<100;
    ind4=C{q}(:,9)<100;

    ind1=~ind1 & ~ind2 & ~ind3 & ~ind4 & ~isnan(C{q}(:,1));

    grilla_mmx = C{q}(ind1,3);
    grilla_mmy = C{q}(ind1,4);

    if q == 2
        grilla_mmx = grilla_mmx-offset(1);
        grilla_mmy = grilla_mmy-offset(2);
    end
    
    if q == 1
        plot(grilla_mmx,grilla_mmy,'.c')
    end
    
    if q == 2
        plot(grilla_mmx,grilla_mmy,'.m')
    end
    
end
