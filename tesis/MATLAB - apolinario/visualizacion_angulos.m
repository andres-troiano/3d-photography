clear variables

camara = '1';
set(0,'DefaultFigureVisible', 'on')

path = 'C:\Users\60069978\Documents\MATLAB\medicion06\';

file_angulos = [path 'tabla_angulos_camara_' camara '.txt'];

datos = importdata(file_angulos, '\t', 1);
datos = datos.data;

x_stage = datos(:, 1);
y_stage = datos(:, 2);
angulos = datos(:, 3);

% la dificultad es que esto no es una grilla cuadrada, entonces graficar
% una superficie es difícil
figure(1)
plot(x_stage, '.-')

%%

N2 = numel(unique(x_stage));
N1 = numel(x_stage)/N2;

X = reshape(x_stage, [N1 N2]);
Y = reshape(y_stage, [N1 N2]);
A = reshape(angulos, [N1 N2]);

close all
figure(1)
surf(X, Y, A)