% script para generar las fronteras de la regi�n donde queremos trabajar
% (rosca determinada por el radio del patr�n "630" +- 50 mm).
% Para calcular el centro del patr�n necesito primero tener una
% calibraci�n.
% Se arm� usando el trapecio, la idea es que sirva para el hex�gono tambi�n

clear variables

path_datos= '/home/andres/DIRECTORIO TESIS/2021/resultados_base/medicion48_base/';

% trapecio
path_calibracion = '/home/andres/DIRECTORIO TESIS/2021/resultados_base/medicion42_base/';
path_offset = '/home/andres/DIRECTORIO TESIS/2021/resultados_base/medicion43_base/';

% acá cargo la calibracion con fronteras, porque esto lo quiero para
% calcular el offset con fronteras
load([path_calibracion 'calibration_con_fronteras.mat']);

% trapecio
load([path_offset 'offset.mat']);

% determinar el centro del cilindro 630
frames = {'patron_34700630_camara_1.png', 'patron_34700630_camara_2.png'};

close all,figure(1),hold on
XY = {[], []}; % ac� habr�a que prealocar
% coordenadas de los puntos centrales de cada perfil, en mm. En columnas:
% xc;yc
M = {nan(2,1), nan(2,1)};
% este valor me sirve para separar los datos de cada c�mara despu�s de
% haberlos juntado en XY, as� no los tengo que volver a procesar
s = nan; 
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
    
    % ubico �ndice correspondiente al m�ximo en p�xels, que corresponde al
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
    
    % guardo los datos en una celda que junta las 2 c�maras
    XY{1} = [XY{1}; x];
    XY{2} = [XY{2}; y];

end

% convierto la celda a matriz
XY = [XY{1}, XY{2}];

% veo qu� tan circular es, y mido el di�metro
circulo = TaubinNTN(XY);

centro_x = circulo(1);
centro_y = circulo(2);
r_teorico = circulo(3);

t = linspace(0, 2*pi, 100)';
x_teorico = r_teorico * cos(t) + centro_x;
y_teorico = r_teorico * sin(t) + centro_y;

% plot(x_teorico, y_teorico, '--r')
plot(centro_x, centro_y, '+r')
plot(M{1}(1), M{1}(2), 'og')
plot(M{2}(1), M{2}(2), 'og')

%%

% ahora que tengo la posici�n del centro del sistema, armo la m�scara que
% necesito. Se compone de 2 cosas:
% 1) mirar s�lo un rango de radios
% 2) mirar s�lo un rango de �ngulos

% primero acoto el rango de radios, y al final genero 2 fronteras combinando
% ambas cosas

r_int = r_teorico - 40;
r_ext = r_teorico + 40;

% necesito tener separadas las partes de cada c�mara. Ya s� que la parte
% interna son los 1ros 100 y la externa los 2dos
% parte radial
R = {nan(200,2), nan(200,2)};

for q = 1:2

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

end

%%

% frontera total de una.
F = {nan(1e3,2),nan(1e3,2)};

for q = 1:2
    
    % Arranco con el x_ext y voy clockwise (aprovechando el orden en que se
    % calculan las rectas, y el hecho de que los radios no los tengo
    % sobreescritos)
    
    % marcadores que dicen en qu� indices quedamos en la concatenaci�n
    j = 1;
    k = 100; % porque s� que cada parte radial es un linspace de 100
    F{q}(j:k,:) = [R{q}(101:200,1), R{q}(101:200,2)];
    
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
    
    % otro parche horrible xq en la 1 me quedan invertidas las rectas izq y
    % der
    
    if q == 1
        alpha_der = alpha + 35;
        alpha_izq = alpha - 35;
    end
    
    a = tand(alpha+90); % esto est� horriblemente emparchado. Deber�a entenderlo
    if q==2
        a=tand(90-alpha);
    end
    y_recta = a*x + (centro_y - a*centro_x);
    
%     % ajusto finamente las rectas para armar la m�scara
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
        x_izq=linspace(13,62)';
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
        x_der=linspace(112,156)';
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
    
    plot(x, y_recta, '--k')
    
    % elimino los nan
    ind2 = ~isnan(F{q}(:,1));
    F{q} = F{q}(ind2, :);
    
end

axis equal
margen = 50;
xlim([min(XY(:, 1))-margen max(XY(:, 1))+margen])
ylim([min(XY(:, 2))-margen max(XY(:, 2))+margen])

% figure(2),hold on, grid on
% for q = 1:2
%     plot(F{q}(:,1), F{q}(:,2), '--')
% end
% 
% axis equal

%%

% chequeo que lo estoy haciendo bien con datos de prueba
% path_calibracion = '/home/andres/DIRECTORIO TESIS/2021/resultados_base/medicion42_base/';
load([path_calibracion 'intersections.mat']);

% ind_fronteras = {nan(1e3,1),nan(1e3,1)};

figure(1), hold on, grid on
for q = 1:2

    % esto lo omito para que la dimensi�n de ind_fronteras coincida con la
    % cantidad de puntos que recibe calculateCalibration_con_fronteras.
    % Total el descarte de los puntos mal ajustados lo hace �l mismo
    
%     ind1=C{q}(:,6)>.4;
%     ind2=C{q}(:,8)>.4;
%     ind3=C{q}(:,7)<100;
%     ind4=C{q}(:,9)<100;
% 
%     ind1=~ind1 & ~ind2 & ~ind3 & ~ind4 & ~isnan(C{q}(:,1));
% 
%     grilla_mmx = C{q}(ind1,3);
%     grilla_mmy = C{q}(ind1,4);

    grilla_mmx = C{q}(:,3);
    grilla_mmy = C{q}(:,4);

    if q == 2
        grilla_mmx = grilla_mmx-offset(1);
        grilla_mmy = grilla_mmy-offset(2);
    end
    
%     % le tiro un inpolygon a ver si as� nom�s anda. No creo
%     % para la parte radial, en la interior hay que negar que est� adentro
    ind = inpolygon(grilla_mmx, grilla_mmy, F{q}(:,1), F{q}(:,2));
    
    if q == 1
%         plot(grilla_mmx,grilla_mmy,'.c')
        plot(grilla_mmx(ind),grilla_mmy(ind),'.c')
    end
    
    if q == 2
%         plot(grilla_mmx,grilla_mmy,'.m')
        plot(grilla_mmx(ind),grilla_mmy(ind),'.m')
    end
    
%     ind_fronteras{q}(1:numel(ind)) = ind;
    ind_fronteras{q} = ind;
    
%     % elimino los nan
%     ind2 = ~isnan(ind_fronteras{q});
%     ind_fronteras{q} = ind_fronteras{q}(ind2);
%     whos ind2
%     a=ind_fronteras{q};
%     whos a
    
end
axis equal

%%

% guardo la matriz de fronteras (para graficarla) y los �ndices de los
% puntos que est�n adentro, para pasarselos a calculateCalibration
save(fullfile(path_calibracion, 'fronteras_con_fronteras'),'F');
save(fullfile(path_calibracion, 'ind_fronteras_con_fronteras'),'ind_fronteras');