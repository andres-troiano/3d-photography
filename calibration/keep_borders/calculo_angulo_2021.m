function[angulo] = calculo_angulo(P1, P2, P3, P4)

    % calcula el ángulo entre 2 segmentos, en grados. Recibe 4 puntos para que sirva
    % en caso de que uno no tenga la intersección
    % los 1ros dos puntos dan la 1er recta, los 2dos dos la 2da

    P1_x = P1(1);
    P1_y = P1(2);
    
    P2_x = P2(1);
    P2_y = P2(2);
    
    P3_x = P3(1);
    P3_y = P3(2);
    
    P4_x = P4(1);
    P4_y = P4(2);

    L1 = [P1_x, P1_y] - [P2_x, P2_y];
    L2 = [P3_x, P3_y] - [P4_x, P4_y];
    
    angulo = acos(sum(L1.*L2)/(norm(L1)*norm(L2)));
    angulo = rad2deg(angulo); % ésta está en 2015b. No la tengo, pero la
%     programé
%     angulo = radtodeg(angulo); % tampoco anda
    
end