clear variables

x = linspace(-5, 5, 100);
px_med = exp(x);

x = x.';
px_med = px_med.';

% calculo un polinomio
N = numel(px_med);
cant_terminos = 4;
A = ones(N, cant_terminos);
A(:, 2:end) = [x x.^2 x.^3];
coef_px = A\px_med;
polinomio = A*coef_px;

% OJO! polyval y polyder leen los coeficientes al revés que como están en coef_px
coef_px_flip = flipud(coef_px);

% tengo que hacer esto para cada pixel dato
pixel_pedido = 10;
f = polinomio - pixel_pedido;

x0 = 1;

%%%%%%%%%%% acá empieza la iteración %%%%%%%%%%%
% pongo un contador para evitar loops infinitos
contador = 0;
% distancia entre las 2 últimas soluciones
distancia = 1e6;

while distancia > 0.001

    f_x0y0 = polyval(coef_px_flip, x0) - pixel_pedido;
    f_prima_x0 = polyval(polyder(coef_px_flip), x0);

    eta = -f_x0y0/f_prima_x0;
    x1 = eta + x0;
    tangente_x0 = f_prima_x0*(x - x0) + f_x0y0;

    distancia = abs(x1 - x0);
    x0 = x1;
    contador = contador + 1;
    
    sprintf('Iteraciones = %d\tx1 = %.2f\tDistancia = %f\n', contador, x1, distancia)
    
    f_x1 = polyval(coef_px_flip, x1) - pixel_pedido;
    
    if contador == 10
        break
    end
    
end

close all

figure(1)
hold on
plot(x, f, '.-b')
plot(x1, f_x1, 'or')
% plot([x1 x1], [min(f) max(f)], '--k')
plot([min(x) max(x)], [0 0], '-g')
plot(x, tangente_x0, '--r')
xlim([min(x) max(x)])
ylim([min(f) max(f)])
xlabel('x')
ylabel('y')
legend('f(x)', 'raíz', 'y = 0', 'tangente a f', 'Location', 'best')
grid on

%%

clear variables

% ahora lo extiendo a 2D

% con los datos simulados, cuando trabajo en 2 variables siempre cuadrados
% mínimos me da rango deficiente. Puede ser porque mis datos no son un
% meshgrid?

% x = linspace(0, 5, 100);
% y = linspace(0, 5, 100);
% x = x.';
% y = y.';
% 
% px_med = exp(x) + 20;
% py_med = tan(2*y) - 30;

directorio = 'C:\Users\60069978\Documents\MATLAB\scan24\';
lut = [directorio 'LUT_paso_5_mm.txt'];

datos = importdata(lut, '\t', 1);
datos = datos.data;

x = datos(:, 1);
y = datos(:, 2);
px_med = datos(:, 3);
py_med = datos(:, 4);

%%%%%%%%%%%%%%%% X %%%%%%%%%%%%%%%%

px_pedido = 1000;
py_pedido = 500;

% calculo un polinomio
% en 2 variables esto es distinto!
N = numel(px_med);

% transformo las variables. Centrar y escalar
a_x = x(1);
b_x = x(end);
t_x = (x - (a_x + b_x)/2)/((b_x - a_x)/2);

a_y = y(1);
b_y = y(end);
t_y = (y - (a_y + b_y)/2)/((b_y - a_y)/2);

% sigo
cant_terminos = 10;
A = ones(N, cant_terminos);
A(:, 2:end) = [t_x t_y t_x.^2 t_y.^2 t_x.*t_y t_x.^3 t_y.^3 t_x.^2.*t_y t_x.*t_y.^2];
coef_px = A\px_med;
polinomio_px = A*coef_px;



% OJO! polyval y polyder leen los coeficientes al revés que como están en coef_px
coef_px_flip = flipud(coef_px);

% tengo que hacer esto para cada pixel dato
f = polinomio_px - px_pedido;

%%%%%%%%%%%%%%%% Y %%%%%%%%%%%%%%%%

% calculo el polinomio
coef_py = A\py_med;
polinomio_py = A*coef_py;

coef_py_flip = flipud(coef_py);
g = polinomio_py - py_pedido;

%%%%%%%%%%%%%%%% aplico el método %%%%%%%%%%%%%%%%

% si transformé las variables, el dato inicial debe estar en [-1, 1]
x0 = 0.5;
y0 = -0.25;

X0 = [x0; y0];

f_x0y0 = [1 x0 y0 x0^2 y0^2 x0*y0 x0^3 y0^3 x0^2*y0 x0*y0^2]*coef_px - px_pedido;
g_x0y0 = [1 x0 y0 x0^2 y0^2 x0*y0 x0^3 y0^3 x0^2*y0 x0*y0^2]*coef_py - py_pedido;

% esto está evaluado en x0,y0
F = [f_x0y0; g_x0y0];

% esto no funciona porque no todos los coef son de x
% df_dx = polyval(polyder(coef_px_flip), x0);
% df_dy
% dg_dx
% dg_dy

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

% esto está evaluado en x0,y0. No lo escribo para no cargar la notación
df_dx = a_10 + 2*a_20*x0 + a_11*y0 + 3*a_30*x0^2 + 2*a_21*x0*y0 + a_12*y0^2;
df_dy = a_01 + 2*a_02*y0 + a_11*x0 + 3*a_03*y0^2 + 2*a_21*x0^2 + a_12*x0*y0;

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

dg_dx = b_10 + 2*b_20*x0 + b_11*y0 + 3*b_30*x0^2 + 2*b_21*x0*y0 + b_12*y0^2;
dg_dy = b_01 + 2*b_02*y0 + b_11*x0 + 3*b_03*y0^2 + 2*b_21*x0^2 + b_12*x0*y0;

% esto es el jacobiano
% hay una función de matlab que calcula el jacobiano, pero lo hace
% simbólicamente. Yo necesito hacerlo de manera numérica

% esto también está evaluado en x0,y0
DF = [df_dx df_dy; dg_dx dg_dy];

% ETA = -F\DF;
ETA = -DF\F;
% está bien que me haya quedado como fila?
% ETA = ETA.';

X1 = ETA + X0;
x1 = X1(1);
y1 = X1(2);

% evalúo f,g en el nuevo punto
f_x1y1 = [1 x1 y1 x1^2 y1^2 x1*y1 x1^3 y1^3 x1^2*y1 x1*y1^2]*coef_px - px_pedido;
g_x1y1 = [1 x1 y1 x1^2 y1^2 x1*y1 x1^3 y1^3 x1^2*y1 x1*y1^2]*coef_py - py_pedido;

%%%%%%%%%%%%%%% como ir viendo la iteracion %%%%%%%%%%%%%%%

N2 = numel(unique(x));
N1 = numel(x)/N2;

X = reshape(x, [N1 N2]);
Y = reshape(y, [N1 N2]);
PX = reshape(px_med, [N1 N2]);
PY = reshape(py_med, [N1 N2]);

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