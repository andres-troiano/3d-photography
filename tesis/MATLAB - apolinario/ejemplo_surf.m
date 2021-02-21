x = [0.5, 0.5, 1, 1];
y = [0.5, 1, 0.5, 1];
z = [66.9052, 57.3591, 76.7805, 66.9052];

%%structured 
xi = unique(x) ; yi = unique(y) ;
[X,Y] = meshgrid(xi,yi) ;
Z = reshape(z,size(X)) ;
figure
surf(X,Y,Z)