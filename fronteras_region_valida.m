% script para generar las fronteras de la región donde queremos trabajar
% (rosca determinada por el radio del patrón 630 +- 50 mm).
% Para calcular el centro del patrón necesito primero tener una
% calibración. Uso la del trapecio, que ya la tengo, pero no sé si es lo
% mejor.

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
    
    % ubico índice correspondiente al mínimo en píxels, para quedarme sólo
    % con el arco central
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
    
    plot(x,y,'.')
    axis equal
    grid on
    xlabel('X (mm)')
    ylabel('Y (mm)')
    
    % guardo los datos en una celda que junta las 2 cámaras
    XY{1} = [XY{1}; x];
    XY{2} = [XY{2}; y];
    
%     plot(px,py,'.')
%     plot(px(i), py(i), 'o')

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

plot(x_teorico, y_teorico, '--r')
plot(centro_x, centro_y, '+r')
plot(M{1}(1), M{1}(2), 'og')
plot(M{2}(1), M{2}(2), 'om')

%%

% ahora que tengo la posición del centro del sistema, armo la máscara que
% necesito. Se compone de 2 cosas:
% 1) mirar sólo un rango de ángulos
% 2) mirar sólo un rango de radios

% ángulos:
% para filtrar cada perfil por separado, necesito tenerlos separados
% justamente. O hacer otro loop sobre los perfiles

% calculo el ángulo del segmento central (respecto de la vertical)

close all, figure, hold on, grid on
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
    
%     a = 1/tand(alpha);
    a = tand(alpha+90); % esto lo emparché a mano
    y_recta = a*x + (centro_y - a*centro_x);

%     a = 1/tand(alpha_izq);
    a = tand(alpha_izq+90);
    y_recta_izq = a*x + (centro_y - a*centro_x);

%     a = 1/tand(alpha_der);
    a = tand(alpha_der+90);
    y_recta_der = a*x + (centro_y - a*centro_x);
    
    plot(x, y, '.')
    plot(x, y_recta, '--k')
    plot(M{q}(1), M{q}(2), '+r')
    plot(centro_x, centro_y, '+b')
    plot(x, y_recta_izq, '--b')
    plot(x, y_recta_der, '--r')
    axis equal
    
%     % no es lo mismo si la "derecha" tiene pendiente positiva que
%     % negativa
%     if a < 0
%         flag_a = -1;
%     end
% 
%     if a > 0
%         flag_a = 1;
%     end
% 
%     % me quedo con los puntos que están dentro de los 70º
%     % ATENCIÓN! Esto lo voy a hacer en dos partes: comparo con 1 recta y
%     % guardo, comparo con la otra y guardo en otro lado, y al final junto
%     filtro = y < y_recta_izq & y < y_recta_der;
%     x1 = x(filtro);
%     y1 = y(filtro);
% 
%     if flag_a == -1
%         filtro = y > y_recta_der & y < y_recta_izq;
%     end
% 
%     if flag_a == 1
%         filtro = y < y_recta_der & y < y_recta_izq;
%     end
% 
%     x2 = x(filtro);
%     y2 = y(filtro);
%     
%     x = [x1;x2];
%     y = [y1;y2];
    
end

axis equal
xlim([min(XY(:, 1)) max(XY(:, 1))])
ylim([min(XY(:, 2)) max(XY(:, 2))])

%%

% ahora acoto el rango de radios, y al final genero 2 fronteras combinando
% ambas cosas
% esto ya está hecho, hay que ver dónde