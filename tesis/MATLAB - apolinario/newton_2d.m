clear variables

directorio = 'C:\Users\60069978\Documents\MATLAB\scan24\';
lut = [directorio 'LUT_paso_5_mm.txt'];

datos = importdata(lut, '\t', 1);
datos = datos.data;

x = datos(:, 1);
y = datos(:, 2);
px = datos(:, 3);
py = datos(:, 4);

%%%%%%%%%%%%%%%% X %%%%%%%%%%%%%%%%


    
px_pedido = 1000;
py_pedido = 500;

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

g = polinomio_py - py_pedido;
f = polinomio_px - px_pedido;

% si transformé las variables, el dato inicial debe estar en [-1, 1]
x0 = 0.5;
y0 = -0.25;

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

%%%%%%%%%%%%%%%%%%%%%% itero %%%%%%%%%%%%%%%%%%%%%%

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

    % recordar que éstas son aún las variables transformadas! En realidad
    % no son x,y, son t_x,t_y
    x0 = x1;
    y0 = y1;

%         sprintf('Iteraciones = %d\tDistancia = %f\tRaíz = (%.2f, %.2f)\n', iteracion, distancia, x1, y1)

    if iteracion == 100
        break
    end

end

%%

%%%%%%%%%%%%%%%%%%%%%% fin de la iteración %%%%%%%%%%%%%%%%%%%%%%

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

%%

% pedir libre deudas

% evalúo los polinomios en la solución que me dio newton
pol_tx_solucion = [1 x1 y1 x1^2 y1^2 x1*y1 x1^3 y1^3 x1^2*y1 x1*y1^2 x1^4 y1^4 x1^3*y1 x1^2*y1^2 x1*y1^3]*coef_px;
pol_ty_solucion = [1 x1 y1 x1^2 y1^2 x1*y1 x1^3 y1^3 x1^2*y1 x1*y1^2 x1^4 y1^4 x1^3*y1 x1^2*y1^2 x1*y1^3]*coef_py;

[pol_tx_solucion, pol_ty_solucion]

% deshago la transformacion
raiz_x = x1*(b_x - a_x)/2 + (a_x + b_x)/2;
raiz_y = y1*(b_y - a_y)/2 + (a_y + b_y)/2;

close all
figure(1)
hold on
grid on
surf(X, Y, PX)
plot3(raiz_x, raiz_y, pol_tx_solucion, '.r')
% surf(T_X, T_Y, PX)
% plot3(x1, y1, px_pedido, '.r')
xlabel('x')
ylabel('y')
zlabel('pixel x')
view(43, 15)