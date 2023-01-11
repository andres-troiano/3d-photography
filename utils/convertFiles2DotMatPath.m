function [] = convertFiles2DotMatPath(basepath)

    foldername={'camara_1','camara_2'};
    for fd=foldername
        files=dir(fullfile(basepath,fd{1},'*.png'));
        fprintf('%d\n',length(files))
        X=nan(length(files),1);
        Y=X;
        Profiles=nan(2048,length(files));
        k=0;
        for f=files'
            I=imread(fullfile(basepath,fd{1},f.name));
            Iinfo=imfinfo(fullfile(basepath,fd{1},f.name));
            if ~isempty(Iinfo.SignificantBits)
                I=bitshift(I,Iinfo.SignificantBits-16);
            elseif ~isempty(Iinfo.BitDepth)
                I=double(I)/Iinfo.BitDepth;
            end
            I=double(I);
            k=k+1;
            Profiles(:,k)=median(I);
            xy=sscanf(f.name,sprintf('LUT_%s_frame_x_%%d_y_%%d.png',fd{1}));
            X(k)=xy(1);
            Y(k)=xy(2);
        end
        save(fullfile(basepath,fd{1}),'Profiles','X','Y')
    end

    fprintf('END\n')
    
end