clear variables

x_min = 0;
x_max = 300;
y_min = 400;
y_max = 600;

paso = 25;

x = x_min:paso:x_max;
y = y_min:paso:y_max;


m = median(x) + paso/2;
distancias = abs(x - m);
closest = x(find(distancias == min(abs(m - x))));
closest = closest(1);

closest