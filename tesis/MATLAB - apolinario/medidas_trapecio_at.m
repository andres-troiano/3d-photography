% dimensiones del trapecio segun AT

x = [-65.036, -30.004, 30.027, 65.036];
y = [29.986, 59.979, 59.990, 29.986];

close all
figure(1)
hold on
plot(x, y, '*b')
plot(x(2:3), y(2:3), '.r')

norma(x(2:3), y(2:3))