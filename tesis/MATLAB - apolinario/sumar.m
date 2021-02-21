function [s,j,i] = sumar(a,t)
    
    for k=1:numel(a)
        s=0;
        i=k;
        j=k;
        for i=k:numel(a)
            s=s+a(i);
%             disp('Sumando')
%             [a(i), s]
            if s == t
                fprintf('Los elementos entre (%d,%d) suman %d\n', j, i, s)
                break
            end

            if s-t>0
                for j=k:numel(a)
                    s = s-a(j);
%                     disp('Restando')
%                     [a(j), s]
                    if s < t
                        j=j+1;
                        break
                    end
                end
            end
        end
    end

end