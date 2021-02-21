clear classes
clear all
close all

camara = gigecam(1);

set(camara, 'LightBrightness', 100);
set(camara, 'PixelFormat', 'Mono16');

%%

close all

tiempo_exp = 1;

set(camara, 'LightSource', 'ExposureActive');
set(camara, 'ExposureTime', tiempo_exp);

N = 200;
maximos = [];

for i = 1:N
    disp(sprintf('Iteración %d\n', i));
    
    foto = snapshot(camara);
    %maximos = [maximos max(max(foto))];
    maximos = [maximos max(foto(:))];

% chequeo que no este saturando
end

figure(1);
plot(maximos, '.-');
xlabel('iteracion');
ylabel('valor maximo camara');
title(sprintf('Tiempo exposicion %d ms', tiempo_exp));

% set(camara, 'LightSource', 'On');

for j=1:1000
    foto = snapshot(camara);
    
    figure(1);
    imagesc(foto);
    xlim([300 1700])
    ylim([600 800])
end

set(camara, 'LightSource', 'Off');

% figure(2)
% plot(foto(:, 1000));