clear variables

% cargo la medicion del cilindro

filename = 'C:\Users\60069978\Documents\MATLAB\scan26\frame_cilindro_34700730_x_410_y_550_z_16.png';
frame = imread(filename);

perfil = median(frame);
perfil = double(perfil)/2^4;

datos_x = [];
datos_y = [];

for i = 1:numel(perfil)
    if perfil(i) ~= 0
        datos_x = [datos_x i];
        datos_y = [datos_y perfil(i)];
    end
end

[y_min, indice_min] = min(datos_y);
x_min = datos_x(indice_min);

% uso que el reflejo de la base está a más de 300 pixels de lo más que
% alcanzo a ver del cilindro

dist = 300;

datos_x_temp = [];
datos_y_temp = [];

for i = 1:numel(datos_x)
    if datos_y(i) < min(datos_y) + dist
        datos_x_temp = [datos_x_temp datos_x(i)];
        datos_y_temp = [datos_y_temp datos_y(i)];
    end
end

datos_x = datos_x_temp;
datos_y = datos_y_temp;

%%

% calibro

directorio = 'C:\Users\60069978\Documents\MATLAB\scan24\';
lut = [directorio 'LUT_paso_5_mm.txt'];

datos = importdata(lut, '\t', 1);
datos = datos.data;

x = datos(:, 1);
y = datos(:, 2);
px = datos(:, 3);
py = datos(:, 4);

% calculo un polinomio
% en 2 variables esto es distinto!
N = numel(px);

% transformo las variables. Centrar y escalar
a_x = x(1);
b_x = x(end);
t_x = (x - (a_x + b_x)/2)/((b_x - a_x)/2);

a_y = y(1);
b_y = y(end);
t_y = (y - (a_y + b_y)/2)/((b_y - a_y)/2);

% cálculo del polinomio
% cant_terminos = 10;
% A = ones(N, cant_terminos);
% A(:, 2:end) = [t_x t_y t_x.^2 t_y.^2 t_x.*t_y t_x.^3 t_y.^3 t_x.^2.*t_y t_x.*t_y.^2];

% a orden 4
cant_terminos = 15;
A = ones(N, cant_terminos);
A(:, 2:end) = [t_x t_y t_x.^2 t_y.^2 t_x.*t_y t_x.^3 t_y.^3 t_x.^2.*t_y t_y.^2.*t_x t_x.^4 t_y.^4 t_x.^3.*t_y t_x.^2.*t_y.^2 t_x.*t_y.^3];

coef_px = A\px;
coef_py = A\py;

% yo quiero el polinomio en forma funcional, para calcular las derivadas
% parciales de f,g
polinomio_px = A*coef_px;
polinomio_py = A*coef_py;

% tengo que saber distinguir a qué variables acompaña cada coeficiente. Eso
% está en la definición de A
% con lo cual no lo puedo hacer para orden genérico
% lo único que necesito es saber el orden de las variables
% me conviene hacerlo de manera simbólica? hace falta un toolbox


% pixel X
a_00 = coef_px(1);
a_10 = coef_px(2);
a_01 = coef_px(3);
a_20 = coef_px(4);
a_02 = coef_px(5);
a_11 = coef_px(6);
a_30 = coef_px(7);
a_03 = coef_px(8);
a_21 = coef_px(9);
a_12 = coef_px(10);
% a partir de orden 4
a_40 = coef_px(11);
a_04 = coef_px(12);
a_31 = coef_px(13);
a_22 = coef_px(14);
a_13 = coef_px(15);

% pixel Y
b_00 = coef_py(1);
b_10 = coef_py(2);
b_01 = coef_py(3);
b_20 = coef_py(4);
b_02 = coef_py(5);
b_11 = coef_py(6);
b_30 = coef_py(7);
b_03 = coef_py(8);
b_21 = coef_py(9);
b_12 = coef_py(10);
% a partir de orden 4
b_40 = coef_py(11);
b_04 = coef_py(12);
b_31 = coef_py(13);
b_22 = coef_py(14);
b_13 = coef_py(15);

x_en_mm = zeros(1, numel(datos_x));
y_en_mm = zeros(1, numel(datos_y));

for i = 1:numel(datos_x)
    
    px_pedido = datos_x(i);
    py_pedido = datos_y(i);

    %%%%%%%%%%%%%%%%%%%%%% itero %%%%%%%%%%%%%%%%%%%%%%

    g = polinomio_py - py_pedido;
    f = polinomio_px - px_pedido;

    % si transformé las variables, el dato inicial debe estar en [-1, 1]
    x0 = 0.5;
    y0 = -0.25;

    distancia = 1e6;
    iteracion = 1;

    while distancia > 0.001

        X0 = [x0; y0];

        f_x0y0 = [1 x0 y0 x0^2 y0^2 x0*y0 x0^3 y0^3 x0^2*y0 x0*y0^2 x0^4 y0^4 x0^3*y0 x0^2*y0^2 x0*y0^3]*coef_px - px_pedido;
        g_x0y0 = [1 x0 y0 x0^2 y0^2 x0*y0 x0^3 y0^3 x0^2*y0 x0*y0^2 x0^4 y0^4 x0^3*y0 x0^2*y0^2 x0*y0^3]*coef_py - py_pedido;

        % esto está evaluado en x0,y0
        F = [f_x0y0; g_x0y0];

        % esto está evaluado en x0,y0. No lo escribo para no cargar la notación
        df_dx = a_10 + 2*a_20*x0 + a_11*y0 + 3*a_30*x0^2 + 2*a_21*x0*y0 + a_12*y0^2 + 4*a_40*x0 + 3*a_31*x0^2*y0 + 2*a_22*x0*y0^2 + a_13*y0^3;
        df_dy = a_01 + 2*a_02*y0 + a_11*x0 + 3*a_03*y0^2 + 2*a_21*x0^2 + a_12*x0*y0 + 4*a_04*y0^3 + a_31*x0^3 + 2*a_22*x0^2*y0 + 3*a_13*x0*y0^2;

        dg_dx = b_10 + 2*b_20*x0 + b_11*y0 + 3*b_30*x0^2 + 2*b_21*x0*y0 + b_12*y0^2 + 4*b_40*x0 + 3*b_31*x0^2*y0 + 2*b_22*x0*y0^2 + b_13*y0^3;
        dg_dy = b_01 + 2*b_02*y0 + b_11*x0 + 3*b_03*y0^2 + 2*b_21*x0^2 + b_12*x0*y0 + 4*b_04*y0^3 + b_31*x0^3 + 2*b_22*x0^2*y0 + 3*b_13*x0*y0^2;

        % esto es el jacobiano
        % hay una función de matlab que calcula el jacobiano, pero lo hace
        % simbólicamente. Yo necesito hacerlo de manera numérica

        % esto también está evaluado en x0,y0
        DF = [df_dx df_dy; dg_dx dg_dy];

        ETA = -DF\F;

        X1 = ETA + X0;
        x1 = X1(1);
        y1 = X1(2);

        % evalúo f,g en el nuevo punto
        f_x1y1 = [1 x1 y1 x1^2 y1^2 x1*y1 x1^3 y1^3 x1^2*y1 x1*y1^2 x1.^4 y1.^4 x1.^3.*y1 x1.^2.*y1.^2 x1.*y1.^3]*coef_px - px_pedido;
        g_x1y1 = [1 x1 y1 x1^2 y1^2 x1*y1 x1^3 y1^3 x1^2*y1 x1*y1^2 x1.^4 y1.^4 x1.^3.*y1 x1.^2.*y1.^2 x1.*y1.^3]*coef_py - py_pedido;

        distancia = norma([x0 x1], [y0 y1]);
        iteracion = iteracion + 1;

        x0 = x1;
        y0 = y1;

%             sprintf('Iteraciones = %d\tDistancia = %f\tRaíz = (%.2f, %.2f)\n', iteracion, distancia, x1, y1)

        if iteracion == 100
            break
        end

    end
    sprintf('Paso %d de %d', i, numel(datos_x))
    
    % deshago la transformacion
    raiz_x = x1*(b_x - a_x)/2 + (a_x + b_x)/2;
    raiz_y = y1*(b_y - a_y)/2 + (a_y + b_y)/2;
    
    x_en_mm(i) = raiz_x;
    y_en_mm(i) = raiz_y;

end

%%

nominal = 177.806;

x = x_en_mm;
y = y_en_mm;

% matriz con x, y como columnas
XY = [x; y];    % así están como filas
XY = XY.';

circulo = TaubinNTN(XY);

centro_x = circulo(1);
centro_y = circulo(2);
radio = circulo(3);
diametro = 2*radio;

th = 0:pi/50:2*pi;
circulo_x = radio * cos(th) + centro_x;
circulo_y = radio * sin(th) + centro_y;

error = abs(nominal - diametro);

% filtro datos malos
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

error_radial = radio - sqrt((x - centro_x).^2 + (y - centro_y).^2);

% como criterio de tolerancia uso la std del error
error_avg = mean(error_radial);
sigma = std(error_radial);

filtro = error_avg + 3*sigma;

% me fijo qué datos están dentro de la tolerancia

% usando tolerancia relativa
booleano = abs(error_radial) < filtro;

% usando tolerancia de 1 mm
%booleano = abs(error_radial) < 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% vuelvo a ajustar después del filtrado

x_filtrado = x(booleano);
y_filtrado = y(booleano);

% por qué esto no anda y lo de abajo sí???
%XY = [x_filtrado; x_filtrado];    % así están como filas
XY = [x(booleano); y(booleano)];
XY = XY.';

circulo = TaubinNTN(XY);

centro_x = circulo(1);
centro_y = circulo(2);
radio = circulo(3);
diametro = 2*radio;

th = 0:pi/50:2*pi;
circulo_x = radio * cos(th) + centro_x;
circulo_y = radio * sin(th) + centro_y;

% vuelvo a calcular el error luego de haber filtrado
error_radial_filtrado = radio - sqrt((x_filtrado - centro_x).^2 + (y_filtrado - centro_y).^2);
% error_radial = radio - sqrt((x(booleano) - centro_x).^2 + (y(booleano) - centro_y).^2);

error = abs(nominal - diametro);

% close all
% figure(1)
% hold on
% plot(x_en_mm, y_en_mm, '.-')
% plot(circulo_x, circulo_y, '--r')
% grid on
% xlabel('x (mm)')
% ylabel('y (mm)')

margen = 0;

h = figure(1);

ax(1) = subplot(2, 1, 1);
hold on
grid on
plot(x, y, '.g')
plot(x_filtrado, y_filtrado, '.b')
plot(circulo_x, circulo_y, '--r')
xlabel('x (mm)')
ylabel('y (mm)')
xlim([min(x) - margen max(x) + margen]);
ylim([min(y) - margen max(y) + margen]);
legend('datos filtrados', 'perfil', 'ajuste círculo', 'Location', 'Best');

ax(2) = subplot(2, 1, 2);
hold on
grid on
plot(x, error_radial, '.-g')
plot(x_filtrado, error_radial_filtrado, '.-b')
plot([min(x), max(x)], [filtro, filtro], '--r')
plot([min(x), max(x)], [-filtro, -filtro], '--r')
xlabel('x (mm)')
ylabel('datos - ajuste (mm)')
legend('Pre filtrado', 'Post filtrado', 'Corte del filtro', 'Location', 'Best')

    %%%%%%%%%%%%%%%%%%%%%% fin de la iteración %%%%%%%%%%%%%%%%%%%%%%
%%
N2 = numel(unique(x));
N1 = numel(x)/N2;

X = reshape(x, [N1 N2]);
Y = reshape(y, [N1 N2]);
PX = reshape(px, [N1 N2]);
PY = reshape(py, [N1 N2]);

px_parametrizado = A*coef_px;

PX_P = reshape(px_parametrizado, [N1 N2]);
T_X = reshape(t_x, [N1 N2]);
T_Y = reshape(t_y, [N1 N2]);

py_parametrizado = A*coef_py;
PY_P = reshape(py_parametrizado, [N1 N2]);

close all

figure(1)
hold on
plot3(x0, y0, f_x0y0, 'og')
plot3(x1, y1, f_x1y1, 'or')
% plot3([x0 x0], [y0 y0], [min(min(PX)) - px_pedido max(max(PX)) - px_pedido], '-r')
surf(T_X, T_Y, PX_P - px_pedido)
patch([1 -1 -1 1], [1 1 -1 -1], [0 0 0 0], [1 1 -1 -1])
xlabel('x transf.')
grid on
view(36, 6)
ylabel('y transf.')
zlabel('pixel x')

figure(2)
hold on
plot3(x0, y0, g_x0y0, 'og')
plot3(x1, y1, g_x1y1, 'or')
% plot3([x0 x0], [y0 y0], [min(min(PY)) - py_pedido max(max(PY)) - py_pedido], '-r')
surf(T_X, T_Y, PY_P - py_pedido)
patch([1 -1 -1 1], [1 1 -1 -1], [0 0 0 0], [1 1 -1 -1])
xlabel('x transf.')
grid on
view(57, 17)
ylabel('y transf.')
zlabel('pixel y')

% figure(3)
% surf(T_X, T_Y, PX_P - PX)
% 
% figure(4)
% surf(T_X, T_Y, PY_P - PY)