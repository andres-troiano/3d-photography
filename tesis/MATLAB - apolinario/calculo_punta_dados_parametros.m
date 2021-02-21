function[punta_px, punta_py] = calculo_punta_dados_parametros(a1, b1, a2, b2)

    punta_px = (b2 - b1)/(a1 - a2);
    punta_py = a1*(b2 - b1)/(a1 - a2) + b1;

end