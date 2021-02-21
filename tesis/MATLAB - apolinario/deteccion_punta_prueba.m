path = 'C:\Users\60069978\Documents\MATLAB\scan\';

filename = [path 'LUT_frame_x_390_y_570.png'];

X0 = 1500;
f = @(x)ajuste_punta_1_param_2(x, filename, 0);
[x, fval] = fminsearch(f, X0);

ajuste_punta_1_param_2(x, filename, 1);