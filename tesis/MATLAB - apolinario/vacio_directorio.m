function[] = vacio_directorio(dir_medicion, camara)

    % dir_medicion es un directorio 'medicionXX'
    % camara es un str que vale '1' o '2'
    
    delete([dir_medicion 'camara_' camara '\*.txt'])
    delete([dir_medicion 'camara_' camara '\plot*'])
    delete([dir_medicion 'camara_' camara '\descarte\*'])
end