basepath = 'C:\Users\60069978\Documents\MATLAB\medicion46\'; % para el hexágono
files=dir(fullfile(basepath,'*.png'));

for q = 1:2
    L=length(files)/2;   %porque tengo dos capturas de cada radio
    radio=nan(L,1);
    Profiles=nan(2048,L);
    k=0;
    for f = files'
        I=imread(fullfile(basepath,f.name));
        % esta parte es dependiente del nombre que se le haya dado al
        % archivo
        if str2num(f.name(28)) == q % para el hexagono
            Iinfo=imfinfo(fullfile(basepath,f.name));
            if ~isempty(Iinfo.SignificantBits)
                I=bitshift(I,Iinfo.SignificantBits-16);
            elseif ~isempty(Iinfo.BitDepth)
                I=double(I)/Iinfo.BitDepth;
            end
            I=double(I);
            k=k+1;
            Profiles(:,k)=median(I);
        end
    end
    fname = sprintf(['PerfilesScanContinuo' num2str(q) '.mat']); % para el hexágono
    save(fullfile(basepath, fname),'Profiles') % para el hexágono
end
