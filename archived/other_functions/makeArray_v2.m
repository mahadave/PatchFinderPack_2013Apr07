    
function array = makeArray_v2(s1,s2)

array=[];
        for k=1:s1
            array = [array; [k*ones(s2,1) [1:s2]']];         
        end
        
end