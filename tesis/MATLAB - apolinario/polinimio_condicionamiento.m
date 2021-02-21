clear variables
directorio = 'C:\Users\60069978\Documents\MATLAB\scan24\';

lut = [directorio 'LUT_paso_5_mm.txt'];

datos = importdata(lut, '\t', 1);
datos = datos.data;

x = datos(:, 1);
y = datos(:, 2);
px = datos(:, 3);
py = datos(:, 4);

N2 = numel(unique(x));
N1 = numel(x)/N2;

X = reshape(x, [N1 N2]);
Y = reshape(y, [N1 N2]);
PX = reshape(px, [N1 N2]);
PY = reshape(py, [N1 N2]);

% tamaño de mis datos
N = numel(py);

% Interpolo px, py a orden 4

%%%%%%%%%%%%%%%% x %%%%%%%%%%%%%%%%
% condiciono mejor el problema
% centro las variables xy, y las escaleo entre -1 y 1
a_x = x(1);
b_x = x(end);
t_x = (x - (a_x + b_x)/2)/((b_x - a_x)/2);

a_y = y(1);
b_y = y(end);
t_y = (y - (a_y + b_y)/2)/((b_y - a_y)/2);

% calculo el polinomio
% ORDEN 4
cant_terminos = 15;
A = ones(N, cant_terminos);
A(:, 2:end) = [t_x t_y t_x.^2 t_y.^2 t_x.*t_y t_x.^3 t_y.^3 t_x.^2.*t_y t_y.^2.*t_x t_x.^4 t_y.^4 t_x.^3.*t_y t_x.^2.*t_y.^2 t_x.*t_y.^3];
coef_t_x = A\px;
px_parametrizado_4 = A*coef_t_x;

PX_P_4 = reshape(px_parametrizado_4, [N1 N2]);
T_X = reshape(t_x, [N1 N2]);
T_Y = reshape(t_y, [N1 N2]);

% calculo qué tan diferente es de los datos
D4 = PX_P_4 - PX;

d4 = reshape(D4, [1 size(D4, 1)*size(D4, 2)]);

mu = mean(d4);
sigma = std(d4);
dist_normal = normal_distribution(d4, mu, sigma);

% % evalúo
% xq = linspace(min(x), max(x), 200);
% yq = linspace(min(y), max(y), 201);
% 
% Nx = numel(xq);
% Ny = numel(yq);
% 
% [XQ, YQ] = meshgrid(xq, yq);
% 
% AQ = ones(numel(XQ), cant_terminos);
% xq = reshape(XQ, [Nx*Ny 1]);
% yq = reshape(YQ, [Nx*Ny 1]);
% AQ(:, 2:end) = [xq yq xq.^2 yq.^2 xq.*yq xq.^3 yq.^3 xq.^2.*yq yq.^2.*xq xq.^4 yq.^4 xq.^3.*yq xq.^2.*yq.^2 xq.*yq.^3];
% pxq_parametrizado = AQ*coef_x;
% PXQ_P = reshape(pxq_parametrizado, [Ny Nx]);

% plot

% close all
% figure(1);
% hold on
% grid on
% surf(T_X, T_Y, D4)
% xlabel('x escaleado (mm)')
% ylabel('y escaleado (mm)')
% zlabel('Polinomio menos datos')
% view(83, 22)
% title('Orden 4')

% figure(2)
% hold on
% histogram(D4)
% plot(d4, dist_normal, '--r')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% tengo datos px, py, y tengo un pol que depende de x,y
% cuáles son los x,y para obtener px,py?

% qué es F?
% F es lo que llamé D4 o D5
F = D4;
whos F

% DF es la matriz diferencial

%%

% X,Y EN FUNCION DE PIXELS
%%%%%%%%%%%%%%%%%%%%%%%%%%

% esto no es lo que más interesa. Puede estar bueno para comparar, para
% engrosar la tesis

% acá hago al revés, interpolo x,y en función de los pixels
% para chequear los resultados, calibro con una LUT un poco más gruesa y
% uso los puntos adicionales que tengo en la LUT fina para ver si da bien

clear variables
directorio = 'C:\Users\60069978\Documents\MATLAB\scan24\';

lut_gruesa = [directorio 'LUT_paso_10_mm.txt'];

datos = importdata(lut_gruesa, '\t', 1);
datos = datos.data;

x = datos(:, 1);
y = datos(:, 2);
px = datos(:, 3);
py = datos(:, 4);

N2 = numel(unique(x));
N1 = numel(x)/N2;

X = reshape(x, [N1 N2]);
Y = reshape(y, [N1 N2]);
PX = reshape(px, [N1 N2]);
PY = reshape(py, [N1 N2]);

% tamaño de mis datos
N = numel(py);

% %%%%%%%%% transformando las variables %%%%%%%%%
% centro las variables y las escaleo a [-1, 1]

a_px = px(1);
b_px = px(end);
t_px = (px - (a_px + b_px)/2)/((b_px - a_px)/2);

a_py = py(1);
b_py = py(end);
t_py = (py - (a_py + b_py)/2)/((b_py - a_py)/2);
% 
% calculo el polinomio
% ORDEN 4
cant_terminos = 15;
B = ones(N, cant_terminos);
B(:, 2:end) = [t_px t_py t_px.^2 t_py.^2 t_px.*t_py t_px.^3 t_py.^3 t_px.^2.*t_py t_py.^2.*t_px t_px.^4 t_py.^4 t_px.^3.*t_py t_px.^2.*t_py.^2 t_px.*t_py.^3];
coef_tx = B\x;
% resultado a orden 4
x_parametrizado_4 = B*coef_tx;

X_P_4 = reshape(x_parametrizado_4, [N1 N2]);
T_PX = reshape(t_px, [N1 N2]);
T_PY = reshape(t_py, [N1 N2]);

% calculo la diferencia entre el polinomio y los datos
D4 = X_P_4 - X;

d4 = reshape(D4, [1 size(D4, 1)*size(D4, 2)]);

mu = mean(d4);
sigma = std(d4);
dist_normal = normal_distribution(d4, mu, sigma);

% CREO que en este caso no necesito deshacer la transformación. Vos me das
% un px, yo lo transformo, lo meto en el polinomio y te devuelvo x

% ORDEN 5
cant_terminos = 21;
B = ones(N, cant_terminos);
B(:, 2:end) = [t_px t_py t_px.^2 t_py.^2 t_px.*t_py t_px.^3 t_py.^3 t_px.^2.*t_py t_py.^2.*t_px t_px.^4 t_py.^4 t_px.^3.*t_py t_px.^2.*t_py.^2 t_px.*t_py.^3 t_px.^5 t_py.^5 t_px.^4.*t_py t_px.*t_py.^4 t_px.^3.*t_py.^2 t_px.^2.*t_py.^3];
coef_tx = B\x;
% resultado a orden 5
x_parametrizado_5 = B*coef_tx;
X_P_5 = reshape(x_parametrizado_5, [N1 N2]);

% calculo la diferencia entre el polinomio y los datos
D5 = X_P_5 - X;

d5 = reshape(D5, [1 size(D5, 1)*size(D5, 2)]);

mu = mean(d5);
sigma = std(d5);
dist_normal = normal_distribution(d5, mu, sigma);

close all

% h = figure(1);
% hold on
% grid on
% surf(T_PX, T_PY, D4)
% % surf(PX, PY, D4)
% xlabel('pixel x escaleado')
% ylabel('pixel y escaleado')
% zlabel('Polinomio menos datos (mm)')
% view(33, 15)
% title('Orden 4')

[counts,centers] = hist(D4);

figure(2)
hold on
histogram(D4)
plot(centers, counts, '.r')
% plot(d5, dist_normal, '--r')