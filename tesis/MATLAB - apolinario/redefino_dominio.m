function[datos_x, datos_y] = redefino_dominio(perfil_x, perfil_y, datos_x, datos_y, datos_x_1, datos_y_1, datos_x_2, datos_y_2, punta_x, punta_y, a1, a2, camara)    

% esto estaba pensado solo para el trapecio?

    if camara == '1'
        
        if punta_x > datos_x_1(end) + 50 && punta_y < datos_y_1(end) - 50
            disp('cond. 1')
            
            datos_x = datos_x_1;
            datos_y = datos_y_1;
                
        
%         elseif punta_x < datos_x_2(1) - 10 && punta_y < datos_y_2(1) - 10
        elseif punta_x < datos_x_2(1) - 5 || punta_y < datos_y_2(1) - 5
%             
            disp('cond. 2')
%             
            filtro = perfil_x > datos_x_1(1) & perfil_x < datos_x_2(1) + 100;
            
            datos_x = perfil_x(filtro);
            datos_y = perfil_y(filtro);

        elseif punta_x > datos_x_1(end) + 8 && punta_y < datos_y_1(end) - 8
%             
            disp('cond. 3')
%             
            filtro = datos_x < punta_x + 100;
            
            datos_x = datos_x(filtro);
            datos_y = datos_y(filtro);
        
        % si agarré la punta de la derecha
        elseif (datos_y_2(end) - datos_y_2(1))/(datos_x_2(end) - datos_x_2(1)) > 0
            disp('Cond. 4')

            filtro = perfil_x > datos_x(1) & perfil_x < punta_x;
            
            datos_x = perfil_x(filtro);
            datos_y = perfil_y(filtro);

%         elseif abs(a2) > 
            
        else
            datos_x = [datos_x_1, datos_x_2];
            datos_y = [datos_y_1, datos_y_2];
        end
        
    end



    if camara == '2'
        if a2 < 0
            disp('Cond. 1')
            
%             datos_x = datos_x_2;
%             datos_y = datos_y_2;

            % me quedo con la región 2 y un poco más
            filtro = perfil_x > datos_x_2(1) & perfil_x < datos_x_2(end) + 100;
            datos_x = perfil_x(filtro);
            datos_y = perfil_y(filtro);

        elseif a1>0
            disp('Cond. 2')
            
%             datos_x = datos_x_1;
%             datos_y = datos_y_1;

            % me quedo con la región 1 y un poco más
            filtro = perfil_x > datos_x_1(1) - 100 & perfil_x < datos_x_1(end);
            datos_x = perfil_x(filtro);
            datos_y = perfil_y(filtro);
            
        elseif a2>0.1
            disp('Cond. 3')
            
            datos_x = datos_x_1;
            datos_y = datos_y_1;
        
        % si tengo basura a la izq, me tira la punta para adentro de la
        % región 1. Si no tengo ese ruido, aplicar esta función es riesgoso
        % porque me tira datos buenos
        elseif punta_x < datos_x_1(end) - 5
            disp('Cond. 4')
            [datos_x, datos_y] = filtro_basura_izquierda_absoluto(datos_x, datos_y);
            
        else
            datos_x = [datos_x_1, datos_x_2];
            datos_y = [datos_y_1, datos_y_2];
        end
    end




    
%     close all
%     figure
%     hold on
%     grid on
%     
%     plot(datos_x_1, datos_y_1, '.-g')
%     plot(datos_x_2, datos_y_2, '.-y')
%     plot(datos_x, datos_y, '--b')
        
end