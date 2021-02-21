function coef=polyfit2XY(X,Y,Z)
%	Resolver P(X,Y)=Z donde P es un polinomio de segundo orden en ambas variables. Y
%	devolver el valor de ese polinomio evaluado en x,y
%	Los coeficientes son para evaluar de la siguiente manera: [1 x x^2 y y^2 x*y]*coef
	M=[ones(length(X),1) X X.^2 Y Y.^2 X.*Y];
	coef=M\Z;	% M*coef=Z
end