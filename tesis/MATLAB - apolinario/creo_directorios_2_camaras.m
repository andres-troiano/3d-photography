function[] = creo_directorios_2_camaras(dir)
    mkdir([dir '\camara_1'])
    mkdir([dir '\camara_2'])
    
    mkdir([dir '\camara_1\descarte'])
    mkdir([dir '\camara_2\descarte'])
    
    mkdir([dir '\camara_1\angulos'])
    mkdir([dir '\camara_2\angulos'])
    
    mkdir([dir '\camara_1\centro_hexagono'])
    mkdir([dir '\camara_2\centro_hexagono'])
    
    mkdir([dir '\camara_1\paridad'])
    mkdir([dir '\camara_2\paridad'])
end