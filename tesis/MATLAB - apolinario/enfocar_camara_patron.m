clear classes
clear all
close all

camara = gigecam(1);

%%

set(camara, 'LightSource', 'Off');
set(camara, 'LightBrightness', 100);
set(camara, 'ExposureTime', 100000);
set(camara, 'PixelFormat', 'Mono16');

%%

close all

h=figure(2);
for i=1:1000
    
    foto = snapshot(camara);

%     figure(1);
%     imagesc(foto);
    if ishandle(h)
        figure(h);
        perfil = median(foto(:, 1200:1250), 2);
        plot(perfil);
        v=sort(perfil(300:400));
        ma=v(90);
        mi=v(10);
        title(sprintf('max=%f, min=%f,diff=%f',ma,mi,ma-mi))
        ylim([100 350]);
        xlim([250 450]);
        grid on;
        drawnow
    else
        break
    end

end
