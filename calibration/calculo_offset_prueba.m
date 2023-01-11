path_calibracion = '/home/andres/Documents/MATLAB/medicion42/';
path_offset = '/home/andres/Documents/MATLAB/medicion43/';

path_datos = path_offset;

load([path_datos 'intersections.mat']);
load([path_calibracion 'calibration.mat']);

filename = {'camara_1.mat', 'camara_2.mat'};

% camara_1 = load(fullfile(path_datos, filename{1}));
% camara_2 = load(fullfile(path_datos, filename{2}));

% armo una estructura que tiene los perfiles de ambas c�maras
perfiles = {load(fullfile(path_datos, filename{1})), load(fullfile(path_datos, filename{2}))};

% identifico los pares (x, y) para los cuales se encontr� la misma esquina
% en ambas c�maras
x_comunes = intersect(perfiles{1}.X, perfiles{2}.X);
y_comunes = intersect(perfiles{1}.Y, perfiles{2}.Y);

N = numel(x_comunes)*numel(y_comunes);
esquinas = {nan(N,4), nan(N, 4)};

k=0;
for i = 1:numel(x_comunes)
    for j = 1:numel(y_comunes)
        k=k+1;

        % recorro las c�maras
        for q = 1:2
            % encuentro el �ndice que corresponde al (x, y) com�n que estoy
            % mirando ahora. Los �ndices van a ser diferentes para cada
            % c�mara

            % par (x, y) en el que estoy parado
            x_pedido = x_comunes(i);
            y_pedido = y_comunes(j);

            ind_x = perfiles{q}.X == x_pedido;
            ind_y = perfiles{q}.Y == y_pedido;
            ind_comun = ind_x & ind_y;

            % el indice que busco
            n = find(ind_comun);

            % para este n guardo las coordenadas de la punta
            % podr�a graficar los perfiles junto con las puntas para
            % chequear que todo est� bien, pero por ahora no lo incluyo

            % coordenadas en pixels de las puntas
            punta_px = C{q}(n, 1);
            punta_py = C{q}(n, 2);

            % va a haber casos en los que la punta no se encontr� (vale
            % NaN), as� que esos los salteo
            if isnan(punta_px) == 1
%                 disp('### No se encontr� la punta ###')
                continue
            end

            if numel(punta_px) == 0
%                 disp('### numel = 0 ###')
                continue
            end

            % convierto a mm
            punta_mm_x = polyval4XY(px2mmPol{q}(1), punta_px, punta_py);
            punta_mm_y = polyval4XY(px2mmPol{q}(2), punta_px, punta_py);

            % guardo en la estructura
%             esquinas{q}(k, :) = [punta_mm_x, punta_mm_y];
            esquinas{q}(k, :) = [punta_mm_x, punta_mm_y, C{q}(n, 3), C{q}(n, 4)];

        end
    end
end

ind1 = ~isnan(esquinas{1}(:, 1));
ind2 = ~isnan(esquinas{2}(:, 1));
ind = ind1 & ind2;

close all
figure, hold on, grid on
plot(esquinas{1}(ind, 3), esquinas{1}(ind, 4), '.b')
plot(esquinas{2}(ind, 3), esquinas{2}(ind, 4), 'or')

%% grafico el perfil que me interesa

clear variables

path_calibracion = '/home/andres/Documents/MATLAB/medicion42/';
path_offset = '/home/andres/Documents/MATLAB/medicion43/';

path_datos = path_offset;

filename = {'camara_1.mat', 'camara_2.mat'};

% armo una estructura que tiene los perfiles de ambas c�maras
perfiles = {load(fullfile(path_datos, filename{1})), load(fullfile(path_datos, filename{2}))};

load([path_calibracion 'calibration.mat']);

x_pedido = 100;
y_pedido = 480;

close all

h = figure; hold on, grid on
for q = 1:2

    ind_x = perfiles{q}.X == x_pedido;
    ind_y = perfiles{q}.Y == y_pedido;
    ind_comun = ind_x & ind_y;

    % el indice que busco
    n = find(ind_comun);
    
    temp = perfiles{q}.Profiles;
    
    perfil_y_px = temp(:,n);
    perfil_x_px = 1:1:numel(perfil_y_px);
    perfil_x_px = perfil_x_px.';
    
    ind = perfil_y_px~=0;
    
    perfil_y_px = 1088 - perfil_y_px;

    % convierto el perfil a mm
    perfil_x_mm = polyval4XY(px2mmPol{q}(1), perfil_x_px, perfil_y_px);
    perfil_y_mm = polyval4XY(px2mmPol{q}(2), perfil_x_px, perfil_y_px);

    lab = ['Cámara ' num2str(q)];
    plot(perfil_x_mm(ind), perfil_y_mm(ind), '.-')
    
end

axis equal
xlabel('X (mm)')
ylabel('Y (mm)')
legend('Cámara 1', 'Cámara 2')
saveas(h, '/home/andres/Documents/MATLAB/grafico_offset_perfiles.png')