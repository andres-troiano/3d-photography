function[px_1, px_2, py_1, py_2] = tiro_punta(px_1, px_2, py_1, py_2)

    % descarto un margen de 6 pixels de cada lado alrededor de la punta

    filtro_1 = px_1 < px_1(end) - 6;
    filtro_2 = px_2 > px_2(1) + 6;
    
    px_1 = px_1(filtro_1);
    py_1 = py_1(filtro_1);

    px_2 = px_2(filtro_2);
    py_2 = py_2(filtro_2);
    
end