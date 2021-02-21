clear variables

path = 'C:\Users\60069978\Documents\MATLAB\scan10\';
    
list = dir([path 'LUT_frame_*.png']);
fnames = {list.name};

output_file = fopen( [path 'LUT.txt'], 'wt' );
fprintf(output_file, 'x_stage\ty_stage\tx_ccd\ty_ccd\n');

%N = 4;
N = numel(fnames);
% tomo un archivo cada 151
%for i = 1:151:2000
for i = 1
    
    filename = [path fnames{i}];
    frame = imread(filename);
    
    tag = strsplit(filename, '.');
    tag = tag{1};
    tag = strsplit(tag, 'frame_');
    tag = tag{2};
    tag = strsplit(tag, '_');
    
    x_stage = str2double(tag{2});
    y_stage = str2double(tag{4});
    
    X0 = 120;
    
    f = @(x)ajuste_punta_1_param(x, frame);
    [x, fval] = fminsearch(f, X0);
    
    x = round(x);
    
    [x_ccd, y_ccd] = punta_1_param(x, filename);
    fprintf(output_file, '%.2f\t%.2f\t%.2f\t%.2f\n', x_stage, y_stage, x_ccd, y_ccd);
    
    sprintf('archivo %d de %d procesado', i, N)
    
end

fclose all;