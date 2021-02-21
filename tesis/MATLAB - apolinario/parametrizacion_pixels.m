clear variables

lut = 'C:\Users\60069978\Documents\MATLAB\scan24\LUT_paso_5_mm.txt';

datos = importdata(lut, '\t', 1);
datos = datos.data;

x = datos(:, 1);
y = datos(:, 2);
px = datos(:, 3);
py = datos(:, 4);

X = reshape(x, [27 21]);
Y = reshape(y, [27 21]);
PX = reshape(px, [27 21]);
PY = reshape(py, [27 21]);

N = numel(py);

%%

% a orden 2

cant_terminos = 6;

A = ones(N, cant_terminos);
A(:, 2:end) = [x y x.^2 y.^2 x.*y];

% A*coef = px

coef = A\px;

px_parametrizado = A*coef;
PX_parametrizado = reshape(px_parametrizado, [27 21]);

% por qué esto no da cero??
diff = PX_parametrizado - PX;

close all
figure(1)
surf(X, Y, diff)
title('Orden 2')

%%

% a orden 3

cant_terminos = 10;

A = ones(N, cant_terminos);
A(:, 2:end) = [x y x.^2 y.^2 x.*y x.^3 y.^3 x.^2.*y y.^2.*x];

coef = A\px;

px_parametrizado = A*coef;
PX_parametrizado = reshape(px_parametrizado, [27 21]);

diff = PX_parametrizado - PX;

close all
figure(1)
surf(X, Y, diff)
title('Orden 3')

%%

% a orden 4

cant_terminos = 15;

A = ones(N, cant_terminos);
A(:, 2:end) = [x y x.^2 y.^2 x.*y x.^3 y.^3 x.^2.*y y.^2.*x x.^4 y.^4 x.^3.*y x.^2.*y.^2 x.*y.^3];

B = [x.^4 y.^4 x.^3.*y x.^2.*y.^2 x.*y.^3];

% aca no entiendo bien que pasa. Lo que agrego a orden 4 tiene componente
% LD con la parte de orden 3, pero no entiendo que columnas son las que se
% superponen. Igualmente parece que lo puede calcular a pesar del warning

coef = A\px;

px_parametrizado = A*coef;
PX_parametrizado = reshape(px_parametrizado, [27 21]);

diff = PX_parametrizado - PX;

close all
figure(1)
surf(X, Y, diff)
title('Orden 4')