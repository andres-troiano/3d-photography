lut = importdata('C:\Users\60069978\Documents\MATLAB\scan\LUT.txt');

lut = lut.data;

desde = 26;
hasta = 33;

x = lut(desde:hasta, 3);
y = lut(desde:hasta, 4);

close all
plot(x, y, '.')
xlim([400 1600]);