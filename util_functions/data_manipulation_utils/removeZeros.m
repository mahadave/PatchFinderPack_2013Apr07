function [m]=removeZeros(m)

    
    for i=1:size(m,1)
        for j=1:size(m,2)
            if(m(i,j)<0)
                m(i,j)=0;
            end
        end
    end
    
end




