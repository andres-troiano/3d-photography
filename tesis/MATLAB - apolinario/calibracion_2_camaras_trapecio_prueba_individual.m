% clear variables

path = 'C:\Users\60069978\Documents\MATLAB\medicion17\';
camara = '2';
dir_camara = ['camara_' camara '\'];

set(0,'DefaultFigureVisible', 'on');

x = 195;
y = 375;

tag_x = num2str(x);
tag_y = num2str(y);

if camara == '2'
    datos = importdata([path 'lista_negra_camara_2.txt'], '\t', 1);
    datos = datos.data;

    x_negro = datos(:, 1);
    y_negro = datos(:, 2);
end

close all
[punta_px, punta_py, datos_x_1, datos_y_1, recta_1, datos_x_2, datos_y_2, recta_2, flag_descarte] = trapecio_individual_funcion(path, camara, tag_x, tag_y, 'on', 0);

% if camara == '2'
%     % si está en la lista negra lo paso de largo
%     for j = 1:numel(x_negro)
%         if x == x_negro(j) && y == y_negro(j)
%             disp('Está en la lista negra')
%         end
%     end
% end