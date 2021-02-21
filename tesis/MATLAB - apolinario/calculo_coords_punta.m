function[punta_x, punta_y, recta_1, recta_2] = calculo_coords_punta(x_1, x_2, y_1, y_2)

    [pol_1, S_1] = polyfit(x_1, y_1, 1);
    [pol_2, S_2] = polyfit(x_2, y_2, 1);

    [recta_1, ~] = polyval(pol_1, x_1, S_1);
    [recta_2, ~] = polyval(pol_2, x_2, S_2);
    
    a1 = pol_1(1);
    b1 = pol_1(2);

    a2 = pol_2(1);
    b2 = pol_2(2);
    
    punta_x = (b2 - b1)/(a1 - a2);
    punta_y = a1*(b2 - b1)/(a1 - a2) + b1;
    
%     close all
%     figure(1);
%     hold on
% 
%     plot(x_2, y_2, '.b')
%     plot(x_2, recta_2, '--r')
    
end