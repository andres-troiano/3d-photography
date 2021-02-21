function [] = sumar2(a,t)  
    for i = 1:numel(a)
        s=0;
        for j = i:numel(a)
            s=s+a(j);            
            if s==t
                fprintf('Los elementos entre (%d,%d) suman %d\n', i, j, s)
                break
            end

            if s>t
                break
            end
        end
    end
end