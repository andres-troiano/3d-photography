clear classes
clear all
close all

camara = gigecam(1);

set(camara, 'LightSource', 'ExposureActive');
set(camara, 'LightBrightness', 100);
set(camara, 'ExposureTime', 100);

%%

close all
corrida = 0;

%%

corrida = corrida + 1;

N = 1000;

picos = [];

for i = 1:N
    
    foto = snapshot(camara);

    %imwrite(foto, 'laser.png')

    % tomo 10 perfiles en torno a la columna 1000 y los superpongo:
    % ademas los promedio

    %foto = imread('./laser.png');

    % la convierto a uint16 para que no sature numericamente
    % obs.: al usar enteros no puedo promediar
    foto = uint16(foto);

    col_i = 995;
    col_f = 1005;
    size_perfiles = size(foto, 1);

    perfil_suma = zeros(size_perfiles, 1, 'uint16');
    %cant_perfiles = 0;

    for col = col_i:col_f
        perfil = foto(:, col);
        %plot(perfil)

        perfil_suma = perfil_suma + perfil;
        %cant_perfiles = cant_perfiles + 1;
    end

    % figure(1);
    % hold all
    % legend('-DynamicLegend');
    % plot(perfil_suma, 'DisplayName', sprintf('corrida %d', corrida))
    % xlim([580 660]);

    picos = [picos max(perfil_suma)];
    
end

figure(1);
hold all
legend('-DynamicLegend');
plot(picos, '.-', 'DisplayName', sprintf('corrida %d', corrida))
xlabel('iteracion')
ylabel('valor pico suma de perfiles')