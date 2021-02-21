% este anda mejor que enfocar_laser.m

clear classes
clear all
close all

camara = gigecam(1);

set(camara, 'LightBrightness', 100);
set(camara, 'PixelFormat', 'Mono16');
set(camara, 'ExposureTime', 300);

%%

set(camara, 'LightSource', 'ExposureActive');

h=figure(1);

for i=1:1000
    
    foto = snapshot(camara);

    if ishandle(h)
        
        figure(h);
        
        perfil = median(foto(:, 1200:1250), 2);
        
%         plot(perfil, '.-');
%          xlim([680 720]);
%          ylim([50 500]);
%         grid on;

        imagesc(foto)
         ylim([600 800]);
         xlim([100 1700]);
        
        % raya horizontal
        % hold all        
        % plot([0 2000],[770 770],'-r')
        drawnow
        
    else
        break
        
    end
end

set(camara, 'LightSource', 'Off');

% set(camara, 'LightBrightness', 5);
% set(camara, 'LightSource', 'On');