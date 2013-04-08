    
function array = makeArray(s)

array=[];
        for k=1:s
            array = [array; [k*ones(s,1) [1:s]']];         
        end
        
end