clear variables

directorio = 'C:\Users\60069978\Documents\MATLAB\scan24\';

% este es el parámetro que quiero cambiar
% paso = 35;

%for i = 5:5:35
for i = 25
    
    tag_paso = num2str(i);

    lut = [directorio 'LUT_paso_' tag_paso '_mm.txt'];

    datos = importdata(lut, '\t', 1);
    datos = datos.data;

    x = datos(:, 1);
    y = datos(:, 2);
    px = datos(:, 3);
    py = datos(:, 4);
    
    a = unique(x);

    N2 = numel(unique(x));
    N1 = numel(x)/N2;

    X = reshape(x, [N1 N2]);
    Y = reshape(y, [N1 N2]);
    PX = reshape(px, [N1 N2]);
    PY = reshape(py, [N1 N2]);

    % tamaño de mis datos
    N = numel(py);

    % Interpolo px, py a orden 4

    %%%%%%%% x %%%%%%%%

    cant_terminos = 15;

    A = ones(N, cant_terminos);
    A(:, 2:end) = [x y x.^2 y.^2 x.*y x.^3 y.^3 x.^2.*y y.^2.*x x.^4 y.^4 x.^3.*y x.^2.*y.^2 x.*y.^3];

    coef_x = A\px;

    px_parametrizado = A*coef_x;

    %%%%%%%% y %%%%%%%%

    cant_terminos = 15;

    A = ones(N, cant_terminos);
    A(:, 2:end) = [x y x.^2 y.^2 x.*y x.^3 y.^3 x.^2.*y y.^2.*x x.^4 y.^4 x.^3.*y x.^2.*y.^2 x.*y.^3];

    coef_y = A\py;

    py_parametrizado = A*coef_y;

%     cant_terminos = 15;
%     A = ones(numel(x), cant_terminos);
%     A(:, 2:end) = [x y x.^2 y.^2 x.*y x.^3 y.^3 x.^2.*y y.^2.*x x.^4 y.^4 x.^3.*y x.^2.*y.^2 x.*y.^3];
% 
%     coef_x = A\px;
%     px_parametrizado = A*coef_x;

    PX_P = reshape(px_parametrizado, [N1 N2]);

    % una forma piola de tomar puntos intermedios es hacer un meshgrid
    xq = linspace(min(x), max(x), 200);
    yq = linspace(min(y), max(y), 201);

    Nx = numel(xq);
    Ny = numel(yq);

    [XQ, YQ] = meshgrid(xq, yq);

    interpolador_x = scatteredInterpolant(x, y, px_parametrizado, 'linear');

    IXQ = interpolador_x(XQ(:), YQ(:));
    IXQ = reshape(IXQ, [Ny Nx]);

    AQ = ones(numel(XQ), cant_terminos);
    xq = reshape(XQ, [Nx*Ny 1]);
    yq = reshape(YQ, [Nx*Ny 1]);
    AQ(:, 2:end) = [xq yq xq.^2 yq.^2 xq.*yq xq.^3 yq.^3 xq.^2.*yq yq.^2.*xq xq.^4 yq.^4 xq.^3.*yq xq.^2.*yq.^2 xq.*yq.^3];
    pxq_parametrizado = AQ*coef_x;
    PXQ_P = reshape(pxq_parametrizado, [Ny Nx]);

    diff = IXQ - PXQ_P;
    rango_diff = max(max(diff)) - min(min(diff));



    close all
    h = figure(1);
    hold on
    grid on
    surf(XQ, YQ, diff)
    %pcolor(XQ, YQ, diff)
    shading('interp')
    xlabel('x (mm)')
    ylabel('y (mm)')
    %zlabel('p_x(x, y)')
    title('Diferencia entre interpolador y polinomio')
    %view(83, 22)
    dim = [0.6 0.6 .3 .3];
    str = ['Paso LUT = ' tag_paso sprintf(' mm\n') 'p_x^{max} - p_x^{min} = ' sprintf('%.3f', rango_diff)];
    annotation('textbox',dim,'String',str,'FitBoxToText','on');

    %saveas(h, [directorio 'interpolador_vs_polinomio_paso_' tag_paso '_mm'], 'png');

end
% lo que quiero variar no es el paso del query, sino el paso de la
% interpolación. Tampoco quiero variar el paso de la parametrización.
% Como es una simulación, defino una y la tomo por buena
% como siempre tengo que poder hacer la resta, la evaluación del polinomio
% la hago en el mismo dominio query (ya lo estaba haciendo así)

% hay algo que estoy haciendo mal: el interpolador lo estoy calculando con
% los pixels de la tabla, cuando lo que quiero es descartar el elemento
% experimental y usar los px, py dados por el polinomio

%%

% acá hago el gráfico de cómo el error entre interpolador y polinomio
% aumenta al agrandar el paso

% clear variables
% 
% directorio = 'C:\Users\60069978\Documents\MATLAB\scan24\';

paso = [5 10 15 20 25 30];

% ojo, para paso de 5 mm y 25 mm, calculé de nuevo el error, descartando la
% columna de y con valores anómalos. En ambos casos fue la última, y
% calculé el error como la diferencia entre máximo y mínimo de la 1ra
% columna de y (que es en todos los casos la que muestra los valores máximos)
error = [0.041 0.163 0.299 0.567 0.845 0.896];

x = log(paso);
y = log(error);

% p = polyfit(x,y,4);
p = polyfit(x,y,1);

% x1 = linspace(0,2);
% x1 = linspace(min(log_paso), max(log_paso), 100);
x1 = linspace(min(x), max(x), 100);
f1 = polyval(p,x1);

close all
h = figure;
plot(x,y,'o')
hold on
plot(x1,f1,'r--')
legend('datos','ajuste', 'Location', 'best')
grid on
xlabel('log(paso) (mm)')
ylabel('log(error) (mm)')
title(['Pendiente = ' num2str(p(1))])

saveas(h, [directorio 'error_interpolacion_vs_paso'], 'png');