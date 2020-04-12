clear variables
path_1 = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion44\';
path_2 = 'C:\Users\Norma\Downloads\datos_calibraciones\medicion45\';

load([path_1 'radio1/intersecciones.mat']);


% plot(intersecciones{2}(:,1), intersecciones{2}(:,2), '.r')


% promedio los z
% px_avg = {[], []};
% py_avg = {[], []};
C={[],[]}; % px_promedio, py_promedio
t = [9,9]; % con radio 1 ambos t son 9
close all
figure(1), hold on, grid on, title('Cámara 1')
figure(2), hold on, grid on, title('Cámara 2')
for i=1:6
    load([path_2 'radio' num2str(i) '/intersecciones.mat']);
    for q=1:2
        figure(q)
        plot(intersecciones{q}(:,1), intersecciones{q}(:,2), '.b')
        P_avg = nan(t(q),2); % coordenadas en pixels promediadas, para 1 radio
        for k = 1:t(q)
            px = intersecciones{q}(k:t(q):end-k,1);
            py = intersecciones{q}(k:t(q):end-k,2);

    %         plot(px,py,'.g')

%             px_avg(k) = mean(px);
%             py_avg(k) = mean(py);
            P_avg(k,:)=[mean(px)', mean(py)'];
        end
        plot(P_avg(:,1), P_avg(:,2), '+r')
        C{q} = [C{q}; P_avg];
        
        axis equal
    end
end

% está faltando loopear sobre los radios

%%

% para calibrar hago una modificacion mínima de calculateCalibration,
% porque C tiene otras dimensiones y no hace falta filtrar por mal ajuste

