function Z=polyval4XY(P,X,Y)
%	Evaluar el polinomio obtenido por polyfit4XY en los puntos X,Y
% Normalizing
X=(X-P.xmin)/(P.xmax/2)-1;
Y=(Y-P.ymin)/(P.ymax/2)-1;
M=[ones(length(X),1) X X.^2 X.^3 X.^4 Y Y.^2 Y.^3 Y.^4 X.*Y X.^2.*Y X.^3.*Y X.*Y.^2 X.*Y.^3 X.^2.*Y.^2];

Z=M*P.coef;
end