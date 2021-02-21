function[suma_cuadrados] = cuadrados_para_minimizar(modelo, datos)
    
    diferencia = datos - modelo;
    
    suma_cuadrados = 0;
    
    for i = numel(datos)
        suma_cuadrados = suma_cuadrados + diferencia(i)^2;
    end
    
end