function [iGuess]=GuessNextCornerCorona(x,y,L,i,estd,sentido)
    % i es el índice a partir del cual comparar recta y datos (para la izq
    % o der según corresponda)
    e=y-polyval(L,x);
    ind1=abs(e)>4*estd; % con 3 tuve algún problema
    if sentido == 0
        ind2=x>i;
        ind=ind1&ind2;
        % mi candidato es el primer x para el cual el error supera 3
        % desviaciones estándar
        iGuess=find(ind,1);
    end
    if sentido == 1
        ind2=x<i;
        ind=ind1&ind2;
        iGuess=find(ind,1,'last');
    end
    
%     figure
%     hold on
%     plot(x,e,'.-b')
%     plot(x(i),e(i),'.r')
%     plot(x(iGuess),e(iGuess),'*g')
    
end