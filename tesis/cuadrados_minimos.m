% script para comparar lo que pasa al ajustar los polinomios al derecho y
% al revés.

path_calibracion = '/home/andres/Documents/MATLAB/medicion42/';
load([path_calibracion 'intersections.mat']);

% éste es el método habitual, que ajusta px en función de mm y después
% invierte
c_minimos_al_derecho(C, path_calibracion);
close all

% este directamente ajusta los mm en función de los px (quizás a éste
% debería llamarlo "derecho")
c_minimos_al_reves(C, path_calibracion);
close all