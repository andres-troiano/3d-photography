function[x0, y0] = interseccion_2_rectas(L1, L2)
    % las rectas L tienen la estructura L = [pendiente;ordenada]
    x0 = (L2(2) - L1(2))/(L1(1) - L2(1));
    y0 = L1(1)*(L2(2) - L1(2))/(L1(1) - L2(1)) + L1(2);
end