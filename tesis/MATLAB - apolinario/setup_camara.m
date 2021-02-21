function[camara, src] = setup_camara(threshold, id)
    % id vale 1, 2, etc

    imaqreset

    camara = videoinput('gige', id);

    src = getselectedsource(camara);

    set(src, 'CameraMode', 'CenterOfGravity');
    set(src, 'ReverseY', 'True');
    set(src, 'ExposureTime', 300);
    set(src, 'EnableDC2', 'True');
    set(src, 'EnableDC0', 'False');
    set(src, 'EnableDC0Shift', 'False');
    set(src, 'EnableDC1', 'False');
    set(src, 'FramePeriod', 3000);
    % 100 parece ser un buen valor para la punta negra
    % para el patrón plateado en cambio es mejor 120
    set(src, 'AoiThreshold', threshold);
    set(src, 'LightDevice0LightBrightness', 100);
    set(src, 'LightDevice0LightSource', 'ExposureActive');
    set(src, 'ProfilesPerFrame', 50);
    set(src, 'PacketSize', 5000);

end