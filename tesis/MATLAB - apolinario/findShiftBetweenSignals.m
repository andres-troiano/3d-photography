function [mi,kmin,shift]=findShiftBetweenSignals(Profiles,xref,k1,k2)
% Encontrar la "separación" en x de los perfiles definidos por k1 y k2.
% El perfil k1 se recorta en +/-40 alrededor de xref y se "barre" con él
% todo el perfil k2 mpara encontrar la mejor "correlación".

ind1=round(xref)+(-40:40); % Se usan al menos 40 puntos para cada lado
m=max(Profiles(ind1,k1));
N=length(ind1);Q=nan(2048-N+1,1);
for q=1:(2048-N+1)
	pp=Profiles(q+(1:N)-1,k2);
    
    % reemplazar por mediana, umbral fijo. Esto es para evitar que el
    % algoritmo falle cuando los 2 perfiles que compara tienen un pico
    pp=reemplazoPicoPorMediana(pp);
    ee=abs(pp-max(pp)+m-reemplazoPicoPorMediana(Profiles(ind1,k1)));
    
% 	ee=abs(pp-max(pp)+m-Profiles(ind1,k1));
	Q(q)=sum(ee(~isnan(ee)));
end
% figure,plot(Q,'.-')
[mi,kmin]=min(Q);
shift=kmin+40-round(xref);

% %%%%%%%%%%% graficos de los pasos intermedios %%%%%%%%%%%
% 
% % paso 1 del barrido
% close all
% f=figure; hold on, grid on
% plot(Profiles(ind1,k1),'.b')
% plot(Profiles(:,k2),'.r')
% xlim([0, 2000])
% xlabel('X (pixels)')
% ylabel('Y (pixels)')
% legend('Perfil anterior','Perfil actual', 'location','best')
% % saveas(f, 'C:\Users\Norma\Downloads\imagenes tesis\guess next corner\correlacion_paso_1.png')
% 
% pp=Profiles(kmin+(1:N)-1,k2);
% p2=reemplazoPicoPorMediana(pp);
% p1=reemplazoPicoPorMediana(Profiles(ind1,k1));
% 
% % figure, hold on, grid on
% % plot(p1, '.b')
% % plot(p2, '.r')
% 
% % el perfil nuevo y la punta del anterior superpuestos
% f=figure; hold on, grid on
% plot(ind1+shift, Profiles(ind1,k1),'.b')
% plot(Profiles(:,k2),'.r')
% % xlim([500, 1200])
% % ylim([200, 600])
% xlabel('X (pixels)')
% ylabel('Y (pixels)')
% legend('Perfil anterior','Perfil actual')
% % saveas(f, 'C:\Users\Norma\Downloads\imagenes tesis\correlacionar_perfiles.png')
% 
% % % perfil de Q, que se hace mínimo donde los perfiles coinciden
% % f2=figure; hold on, grid on
% % plot(Q)
% % xlabel('X (pixels)')
% % ylabel('Q (pixels)')
% % saveas(f2, 'C:\Users\Norma\Downloads\imagenes tesis\perfil_Q.png')
% 
% % calculo la diferencia en el primer paso
% for q=1
% 	pp=Profiles(q+(1:N)-1,k2);
%     pp=reemplazoPicoPorMediana(pp);
%     ee=abs(pp-max(pp)+m-reemplazoPicoPorMediana(Profiles(ind1,k1)));
% end
% 
% % grafico la diferencia sola, porque todo no entra
% close all
% f=figure;hold on, grid on
% plot(ee(~isnan(ee)))
% xlabel('X (pixels)')
% ylabel('Y (pixels)')
% saveas(f, 'C:\Users\Norma\Downloads\imagenes tesis\guess next corner\diferencia_paso_1.png')
%  
%  
% close all
% 
% f3=figure; 
% ax1=subplot(2,1,1);hold on, grid on
% plot(Profiles(ind1,k1),'.b')
% plot(Profiles(:,k2),'.r')
% xlabel('X (pixels)')
% ylabel('Y (pixels)')
% legend('Perfil anterior','Perfil actual', 'location','best')
% 
% ax2=subplot(2,1,2); hold on, grid on
% plot(ee(~isnan(ee)))
% % plot([0, 2500],[sum((ee(~isnan(ee)))),sum((ee(~isnan(ee))))])
% 
% linkaxes([ax1, ax2],'x')
% xlim([0,100])
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end