% genera las fronteras del +-35º y +-40 mm respecto del radio de
% referencia. Modificación de "fronteras_region_valida". La razón es que
% para definir las fronteras hace falta elegir finamente los límites de
% cada pedazo de frontera, y eso depende de cada calibración.
% "fronteras_region_valida" esta tuneado para medicion42 (trapecio) y esta
% para 47 (hexagono)

clear variables

path_datos= 'C:\Users\Norma\Downloads\datos_calibraciones\medicion48\';

path_calibracion = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion47\';
path_offset = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion47\';

load([path_calibracion 'calibration.mat']);

load([path_offset 'offset_hexagono.mat']);
offset=offset_hexagono;

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
%     XY{1} = [XY{1}; x];
%     XY{2} = [XY{2}; y];
    
    % era muy mala idea lo anterior
    XY{q} = [x,y];

end

% convierto la celda a matriz
XY_individual = XY; % me quedo con los perfiles separados por cámara
% sobreescribo XY para que tenga el formato que necesita taubin
XY = [XY{1}; XY{2}];

% veo qué tan circular es, y mido el diámetro
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

% ahora que tengo la posición del centro del sistema, armo la máscara que
% necesito. Se compone de 2 cosas:
% 1) mirar sólo un rango de radios
% 2) mirar sólo un rango de ángulos

% primero acoto el rango de radios, y al final genero 2 fronteras combinando
% ambas cosas

r_int = r_teorico - 40;
r_ext = r_teorico + 40;

% necesito tener separadas las partes de cada cámara. Ya sé que la parte
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

close all, figure, hold on, grid on

plot(XY_individual{1}(:,1),XY_individual{1}(:,2),'ob')
plot(XY_individual{2}(:,1),XY_individual{2}(:,2),'.r')
plot(centro_x, centro_y, '+r')
plot(M{1}(1), M{1}(2), 'og')
plot(M{2}(1), M{2}(2), 'og')
plot(R{1}(:,1),R{1}(:,2), '--b')
plot(R{2}(:,1),R{2}(:,2), '--r')

% frontera total de una.
F = {nan(1e3,2),nan(1e3,2)};

for q = 1:2
    
    % Arranco con el x_ext y voy clockwise (aprovechando el orden en que se
    % calculan las rectas, y el hecho de que los radios no los tengo
    % sobreescritos)
    
    % marcadores que dicen en qué indices quedamos en la concatenación
    j = 1;
    k = 100; % porque sé que cada parte radial es un linspace de 100
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
        x_izq=linspace(199,234)';
        x_izq = flipud(x_izq);
    end
    
    if q==2
        x_izq=linspace(105,155)';
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
        x_der=linspace(225,305)';
    end
    
    if q==2
        x_der=linspace(204,249)';
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
load([path_calibracion 'intersections.mat']);

% ind_fronteras = {nan(1e3,1),nan(1e3,1)};

figure(1)
for q = 1:2

    % esto lo omito para que la dimensión de ind_fronteras coincida con la
    % cantidad de puntos que recibe calculateCalibration_con_fronteras.
    % Total el descarte de los puntos mal ajustados lo hace él mismo
    
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
    
%     % le tiro un inpolygon a ver si así nomás anda. No creo
%     % para la parte radial, en la interior hay que negar que esté adentro
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

% guardo la matriz de fronteras (para graficarla) y los índices de los
% puntos que están adentro, para pasarselos a calculateCalibration
save(fullfile(path_calibracion, 'fronteras'),'F');
save(fullfile(path_calibracion, 'ind_fronteras'),'ind_fronteras');