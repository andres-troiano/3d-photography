clear variables
imaqreset

% camara1 = videoinput('gige', 1);
% camara2 = videoinput('gige', 2);
% 
% src1 = getselectedsource(camara1);
% src2 = getselectedsource(camara2);

camara = videoinput('gige', 2, 'Mono16');
src = getselectedsource(camara);

%%

% pruebo de dispararlas de manera externa

triggerconfig(camara, 'hardware', 'DeviceSpecific', 'DeviceSpecific');
src.ProfileTriggerMode = 'CameraInput2';
set(src)

for i = 1:1000
    foto = getsnapshot(camara);
    imagesc(foto);
end

%%

% P1 = [663 891];
% P2 = [1949 245];

P1 = [1055 1];
P2 = [1033 999];

x = [P1(1) P2(1)];
y = [P1(2) P2(2)];
    
for i = 1:1000

    foto1 = getsnapshot(camara2);

    improfile(foto1, x, y)
    grid on
%     xlim([200 300])
%     ylim([0 250])

%     perfil = foto1(:, 1041);
%     plot(perfil)
%     grid on

end

%%

set(src, 'CameraMode', 'Image');
% set(src, 'LightDevice0LightSource', 'ExposureActive');
set(src, 'LightDevice0LightSource', 'Off');
set(src, 'PacketSize', 5000);
set(src, 'ExposureTime', 100000);

%preview(camara)