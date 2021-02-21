basepath='C:\Users\60069978\Documents\MATLAB\medicion37\radio6\';
files=dir(fullfile(basepath,'*.png'));

for q = 1:2
    L=length(files)/2;   %porque tengo dos capturas de cada radio
    radio=nan(L,1);
    Profiles=nan(2048,L);
    k=0;
    for f = files'
        I=imread(fullfile(basepath,f.name));
        if str2num(f.name(21)) == q
            Iinfo=imfinfo(fullfile(basepath,f.name));
            if ~isempty(Iinfo.SignificantBits)
                I=bitshift(I,Iinfo.SignificantBits-16);
            elseif ~isempty(Iinfo.BitDepth)
                I=double(I)/Iinfo.BitDepth;
            end
            I=double(I);
            k=k+1;
            Profiles(:,k)=median(I);
            % quiero identificar el radio
            string = strsplit(f.name, 'z_');
            string = strsplit(string{2}, '.png');
            radio(k) = str2num(string{1});
        end
    end
    fname = sprintf(['PerfilesCoronaCamara' num2str(q) '.mat']);
    save(fullfile(basepath,fname),'Profiles','radio');
end