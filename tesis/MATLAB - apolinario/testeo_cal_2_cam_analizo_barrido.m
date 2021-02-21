% clear variables

directorio_datos = 'C:\Users\60069978\Documents\MATLAB\medicion19\';
directorio_lut = 'C:\Users\60069978\Documents\MATLAB\medicion18\';

% camara = '1';

% dir_camara = ['camara_' camara '\'];

% close all
% set(0,'DefaultFigureVisible', 'on');

% x = 190;
% y = 290;

x = 170:5:190;
y = 290:5:310;

N = numel(x);

for i = 1:N
    
    for j = 1:N

        tag_x = num2str(x(i));
        tag_y = num2str(y(j));

        % close all
        % [punta_px, punta_py, datos_x_1, datos_y_1, recta_1, datos_x_2, datos_y_2, recta_2] = testeo_cal_2_cam_funcion(path, camara, tag_x, tag_y, 'on', 1);

        testeo_cal_2_cam_funcion_global(directorio_datos, directorio_lut, tag_x, tag_y, 'off', 1);
        
    end
    
end