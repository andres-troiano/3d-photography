function [] = calculateIntersectionsPath_curvo(basepath)

    foldername={'camara_1.mat','camara_2.mat'}; % para barridos en x,y

    C={[],[]};
    C_curvo={[],[]};
    R = {[],[]}; % ac� guardo las rectas. En cada fila tengo: L1(1), L1(2), L2(1) L2(2)
    
%     Las rectas se llaman L1, L2 (L de línea). A las parábolas les pongo P1, P2.
%     Armo una estructura S que tenga X, Y, L1, L2, P1, P2.
%     Cada fila de S va a tener:
%     [X, Y, L1(1), L1(2), L2(1), L2(2), P1(1), P1(2), P1(3), P2(1), P2(2), P2(3)]
    S = {[],[]};
    
    for q=1:2
        fd=foldername{q};
        load(fullfile(basepath,fd));
        Profiles=1088-Profiles;
        % Encontrar un perfil "bueno"
        Xm=median(X); % Tal vez deber�an ser valores definidos a mano.
        Ym=median(Y);

        % corrijo el c�lculo de las medianas cuando hay n�mero impar de
        % elementos
        distancias = abs(X - Xm);
        closest = X(find(distancias == min(abs(Xm - X))));
        Xm = closest(1);

        distancias = abs(Y - Ym);
        closest = Y(find(distancias == min(abs(Ym - Y))));
        Ym = closest(1);

        km=find(X==Xm & Y==Ym);
        % Mostrar al usuario la figure para que elija la posici�n aproximada de la intersecci�n. 
        nfig=figure();plot(Profiles(:,km)),hold all,title({sprintf('x=%d, y=%d',X(km),Y(km)),'Elija la intersecci�n aproximada o cierre la ventana'})
        
%         iniciales={734,987}; % medicion 47
%         iniciales={734,909}; % medicion 49
        try
            p=ginput(1)
%             p=iniciales{q};
        catch E
        end

        close(nfig)
        % Ordenar los perfiles en funci�n de su distancia a la posici�n del perfil definido arriba.
        [~,ind]=sort((X-Xm).^2+(Y-Ym).^2);
        %%
        clc
        C{q}=nan(size(X,1),9); %xc,yc,X,Y,k,estd1,n1,estd2,n2
        C_curvo{q}=nan(size(X,1),9); %xc_parabolas,yc_parabolas,X,Y,k,estd1,n1,estd2,n2
        xguess=round(p(1));
        o=0;
        show=false;
        if show==true
            nfig=figure();hold on
            plot(X(km),Y(km),'xr'),xlim([min(X) max(X)]),ylim([min(Y) max(Y)])
        end
        for k=ind'
            if show==true
                figure(nfig),plot(X(k),Y(k),'xr'),
            end
            o=o+1;
            fprintf('Perfil %d, X=%d, Y=%d',o,X(k),Y(k))
            ind1=(xguess-40:xguess)';
            x=(1:size(Profiles,1))';
            y=Profiles(:,k);
            
            % AJUSTE DE UNA RECTA
            [L1,estd1,n1]=fitStraightLine(x,y,ind1);
            % polinomio de orden 2. No lo uso para calcular intersecciones,
            % pero lo guardo para comparar con el lineal.
            [P1,estd1,n1]=fitCurvedLine(x,y,ind1);
            fprintf(', std1=%.2f, n1=%d',estd1,n1)
            if isempty(L1) || n1<30 || estd1>1.5
    %			figure,plot(Profiles(:,k),'.-'),title(sprintf('o=%d, error en L1 ',o))
                if o<length(X)
                    [xguess,mi,shift]=guessNextCorner(Profiles,C{q},ind(o+1),xguess,X(ind(o+1)),Y(ind(o+1)));
                    fprintf(', xc=NaN, xguess=%d, shift=%d, mi=%.2f',xguess,shift,mi)
                end
                fprintf('  ### DESCARTADO por mal ajuste L1 ###\n')
                continue
            end
            ind1=(xguess:xguess+40)';
            if ind1(end)>2048
                if o<length(X)
                    [xguess,mi,shift]=guessNextCorner(Profiles,C{q},ind(o+1),xguess,X(ind(o+1)),Y(ind(o+1)));
                    fprintf(', xc=NaN, xguess=%d, shift=%d, mi=%.2f',xguess,shift,mi)
                end
                fprintf('  ### DESCARTADO por llegar al extremo\n')
                figure,plot(Profiles(:,k),'.-')
                continue
            end
            % AJUSTE DE LA OTRA RECTA
            [L2,estd2,n2]=fitStraightLine(x,y,ind1);
            [P2,estd1,n1]=fitCurvedLine(x,y,ind1);
            fprintf(', std2=%.2f, n2=%d',estd2,n2)
            if isempty(L2) || n2<30 || estd2>1.5
    %			figure,plot(Profiles(:,k),'.-'),title(sprintf('o=%d, error en L2 ',o))
                if o<length(X)
                    [xguess,mi,shift]=guessNextCorner(Profiles,C{q},ind(o+1),xguess,X(ind(o+1)),Y(ind(o+1)));
                    fprintf(', xc=NaN, xguess=%d, shift=%d, mi=%.2f',xguess,shift,mi)
                end
                fprintf('  ### DESCARTADO por mal ajuste L2 ###\n')
                continue
            end
%     		figure,plot(Profiles(:,k),'.-'),hold all,plot(1:1000,polyval(L1,1:1000),'-'),plot(1:1000,polyval(L2,1:1000),'o')
    
            % guardo los términos cuadráticos de las 2 rectas en P2.
            % tengo que hacerlo acá, después de haber chequeado que tanto
            % L1 como L2 sean no nulos
            % En el caso de que L1, L2 sean no nulos, pero P2 sí sea nulo,
            % reemplazo P2 por un vector de NaN:
            if isempty(P1) || isempty(P2)
                P1 = nan(3,1);
                P2 = nan(3,1);
            end
            S_row = [X(k), Y(k), L1(1), L1(2), L2(1), L2(2), P1(1), P1(2), P1(3), P2(1), P2(2), P2(3)];
            S{q} = [S{q}; S_row];

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % ACÁ CALCULA LA INTERSECCIÓN
            % si quisiera intersecar otro tipo de curvas, esta sección la
            % tengo que cambiar.
            
            % por ahora dejo que siga intersecando rectas para que el
            % algoritmo pueda avanzar. Me limito a calcular el ajuste
            % cuadrático a ver si tiene término cuadrático no nulo.
    
            U1=[L1(1) -1 L1(2)];
            U2=[L2(1) -1 L2(2)];
            P=cross(U1,U2);
    % 		if P(3)==0
            PP(o, 1:3) = P;
            if abs(P(3))<0.01
                if o<length(X)
                    [xguess,mi,shift]=guessNextCorner(Profiles,C{q},ind(o+1),xguess,X(ind(o+1)),Y(ind(o+1)));
                    fprintf(', xc=NaN, xguess=%d, shift=%d, mi=%.2f',xguess,shift,mi)
                end
                fprintf('  ### DESCARTADO - Las rectas no se intersectan ###\n')
                figure,plot(Profiles(:,k),'.-'),hold all,plot(500:1500,polyval(L1,500:1500),'-'),plot(500:1500,polyval(L2,500:1500),'-'),title(sprintf('o=%d, rectas no se cortan',o))
                continue
            end
            xc=P(1)/P(3);
            fprintf(', xc=%.2f',xc)
            yc=P(2)/P(3);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % calculo la intersección de las 2 parábolas
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % en el caso que no haya encontrado P1 o P2 (en cuyo caso les
            % di el valor de NaN) roots no puede trabajar, así que a
            % xc_parabolas, yc_parabolas también les asigno NaN:
            if isnan(P1(1)) || isnan(P2(1))
                xc_parabolas = nan;
                yc_parabolas = nan;
                continue
            end
            
            % coordenada x:
            xc_parabolas = roots(P2 - P1);
            % hay 2 intersecciones. La que me interesa es la que se parece a la
            % intersección de las 2 rectas (se llama xc):
            [M,I] = min(abs(xc_parabolas - xc));
            % me quedo sólo con el que me interesa
            xc_parabolas = xc_parabolas(I);

            % teniendo xc_parabolas calculo yc_parabolas:
            yc_parabolas = [xc_parabolas^2 xc_parabolas 1]*P1;
            
%             norm([xc - xc_parabolas, yc - yc_parabolas])
%             xc - xc_parabolas
%             yc - yc_parabolas
%             
%             figure, hold on, grid on
%             plot(Profiles(:,k),'.-b')
%             plot(500:1500,polyval(L1,500:1500),'-g')
%             plot(500:1500,polyval(L2,500:1500),'-g')
%             plot(xc, yc, '+g')
%             plot(500:1500,polyval(P1,500:1500),'--r')
%             plot(500:1500,polyval(P2,500:1500),'--r')
%             plot(xc_parabolas, yc_parabolas, '+r')
%             xlim([xc-100 xc+100])
%             ylim([yc-100 yc+100])

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % las coordenadas de la intersección calculadas con parábolas,
            % las guardo en un C_curvo (el C original lo sigo guardando)
            
            % a C le agrego las coordenadas calculadas con parábolas:
            C{q}(k,:)=[xc yc X(k) Y(k) k estd1 n1 estd2 n2]; % C original
            C_curvo{q}(k,:)=[xc_parabolas yc_parabolas X(k) Y(k) k estd1 n1 estd2 n2]; % C_curvo
            if o<length(ind) % Hay que estimar el siguiente xguess (coordenada de la siguiente intersecci�n de l�neas)
                [xguess,mi,shift]=guessNextCorner(Profiles,C{q},ind(o+1),xc,X(ind(o+1)),Y(ind(o+1)));
                fprintf(', xguess=%d, shift=%d, mi=%.2f\n',xguess,shift,mi)
            end
            if show==true
                figure(nfig),plot(X(k),Y(k),'xb')
                drawnow limitrate
            end
    %		figure,plot(Profiles(:,k),'.-'),hold all,plot(500:1500,polyval(L1,500:1500),'-'),plot(500:1500,polyval(L2,500:1500),'-'),xlim([xc-100 xc+100]),ylim([yc-100 yc+100]),title(sprintf('o=%d, rectas no se cortan',o))
            R{q}(k,:)=[L1', L2'];
            
        end
    % 	figure,plot(X,Y,'xr'),hold all,plot(C{q}(:,3),C{q}(:,4),'xb'),legend('corner not found','corner found cam1')

    end
    f1 = figure;
    subplot(221),plot3(C{1}(:,3),C{1}(:,4),C{1}(:,1),'.'),title('C�mara 1')
    xlabel('X (mm)')
    ylabel('Y (mm)')
    zlabel('Pixel X esquina')
    subplot(222),plot3(C{1}(:,3),C{1}(:,4),C{1}(:,2),'.'),title('C�mara 1')
    xlabel('X (mm)')
    ylabel('Y (mm)')
    zlabel('Pixel Y esquina')
    subplot(223),plot3(C{2}(:,3),C{2}(:,4),C{2}(:,1),'.'),title('C�mara 2')
    xlabel('X (mm)')
    ylabel('Y (mm)')
    zlabel('Pixel X esquina')
    subplot(224),plot3(C{2}(:,3),C{2}(:,4),C{2}(:,2),'.'),title('C�mara 2')
    xlabel('X (mm)')
    ylabel('Y (mm)')
    zlabel('Pixel Y esquina')
    
%     saveas(f1, [basepath 'figuras_intersecciones/f1'])
    saveas(f1, [basepath 'figuras_intersecciones/f1.png'])

    f2 = figure;plot(X,Y,'xr'),hold all
    plot(C{1}(:,3),C{1}(:,4),'ob','MarkerSize',8)
    plot(C{2}(:,3),C{2}(:,4),'sg','MarkerSize',12)
    set(gca,'Ydir','reverse')
    legend('Esquina no encontrada','Esquina encontrada C1','Esquina encontrada C2')
    xlabel('X (mm)')
    ylabel('Y (mm)')
    axis equal
    
%     saveas(f2, [basepath 'figuras_intersecciones\f2'])
    saveas(f2, [basepath 'figuras_intersecciones/f2.png'])


    f3 = figure;
    subplot(221);plot(C{1}(:,3),C{1}(:,6),'.'),title('cam 1 estd1 vs X')
    subplot(223);plot(C{1}(:,4),C{1}(:,6),'.'),title('cam 1 estd1 vs Y')
    subplot(222);plot(C{1}(:,3),C{1}(:,7),'.'),title('cam 1 n1 vs X')
    subplot(224);plot(C{1}(:,4),C{1}(:,7),'.'),title('cam 1 n1 vs Y')
    
%     saveas(f3, [basepath 'figuras_intersecciones\f3_cam_1'])
    saveas(f3, [basepath 'figuras_intersecciones/f3.png'])

    f4 = figure;
    subplot(221);plot(C{1}(:,3),C{1}(:,8),'.'),title('cam 1 estd2 vs X')
    subplot(223);plot(C{1}(:,4),C{1}(:,8),'.'),title('cam 1 estd2 vs Y')
    subplot(222);plot(C{1}(:,3),C{1}(:,9),'.'),title('cam 1 n2 vs X')
    subplot(224);plot(C{1}(:,4),C{1}(:,9),'.'),title('cam 1 n2 vs Y')
    
%     saveas(f4, [basepath 'figuras_intersecciones\f4_cam_1' ])
    saveas(f4, [basepath 'figuras_intersecciones/f4.png'])


    f5 = figure;
    subplot(221);plot(C{2}(:,3),C{2}(:,6),'.'),title('cam 2 estd1 vs X')
    subplot(223);plot(C{2}(:,4),C{2}(:,6),'.'),title('cam 2 estd1 vs Y')
    subplot(222);plot(C{2}(:,3),C{2}(:,7),'.'),title('cam 2 n1 vs X')
    subplot(224);plot(C{2}(:,4),C{2}(:,7),'.'),title('cam 2 n1 vs Y')
    
%     saveas(f5, [basepath 'figuras_intersecciones\f5_cam_2'])
    saveas(f5, [basepath 'figuras_intersecciones/f5.png'])

    f6 = figure;
    subplot(221);plot(C{2}(:,3),C{2}(:,8),'.'),title('cam 2 estd2 vs X')
    subplot(223);plot(C{2}(:,4),C{2}(:,8),'.'),title('cam 2 estd2 vs Y')
    subplot(222);plot(C{2}(:,3),C{2}(:,9),'.'),title('cam 2 n2 vs X')
    subplot(224);plot(C{2}(:,4),C{2}(:,9),'.'),title('cam 2 n2 vs Y')
    
%     saveas(f6, [basepath 'figuras_intersecciones\f6_cam_2'])
    saveas(f6, [basepath 'figuras_intersecciones/f6.png'])

    save(fullfile(basepath,'intersections.mat'),'C')
    save(fullfile(basepath,'intersections_curvo.mat'),'C_curvo')
    save(fullfile(basepath,'rectas.mat'),'R')
    save(fullfile(basepath,'S.mat'),'S')

end