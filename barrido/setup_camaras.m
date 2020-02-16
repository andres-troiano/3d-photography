% esta función se conecta a las cámaras, las crea como objetos y define
% varios parámetros de operación

function [camara1, camara2] = setup_camaras()

    % reseteo el estado de las cámaras
    imaqreset

    % camara 1 (a 60º)
    camara1 = videoinput('gige', 1, 'Mono16');
    src1 = getselectedsource(camara1);
    % para disparar las cámaras con el generador de funciones
    triggerconfig(camara1, 'hardware', 'DeviceSpecific', 'DeviceSpecific');
    src1.ProfileTriggerMode = 'CameraInput2';
    % otros parámetros
    set(src1, 'CameraMode', 'CenterOfGravity');
    set(src1, 'ReverseY', 'True');
    set(src1, 'ExposureTime', 200);
    set(src1, 'EnableDC2', 'True');
    set(src1, 'EnableDC0', 'False');
    set(src1, 'EnableDC0Shift', 'False');
    set(src1, 'EnableDC1', 'False');
    set(src1, 'FramePeriod', 3000);
    set(src1, 'LightDevice0LightSource', 'Off');
    set(src1, 'ProfilesPerFrame', 50);
    set(src1, 'PacketSize', 5000);
    set(src1, 'AoiThreshold', 75);

    % camara 2 (vertical)
    % ésta sólo funciona en 16 bits, pero no acepta que se lo pongas
    % en el comando
    camara2 = videoinput('gige', 2);
    src2 = getselectedsource(camara2);
    triggerconfig(camara2, 'hardware', 'DeviceSpecific', 'DeviceSpecific');
    src2.ProfileTriggerMode = 'CameraInput2';
    set(src2, 'CameraMode', 'CenterOfGravity');
    set(src2, 'ReverseY', 'True');
    set(src2, 'ExposureTime', 200);
    set(src2, 'EnableDC2', 'True');
    set(src2, 'EnableDC0', 'False');
    set(src2, 'EnableDC0Shift', 'False');
    set(src2, 'EnableDC1', 'False');
    set(src2, 'FramePeriod', 3000);
    set(src2, 'LightDevice0LightBrightness', 100);
    set(src2, 'LightDevice0LightSource', 'ExposureActive');
    set(src2, 'ProfilesPerFrame', 50);
    set(src2, 'PacketSize', 5000);
    set(src2, 'AoiThreshold', 100);
    
end