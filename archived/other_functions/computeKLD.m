function KLD = computeKLD(p,q)
%%
    s1=0;
    s2=0;
    %q=q+0.00000000000001;
    %p=p+0.00000000000001;
    for i=1:numel(p,1)
     
        if(p(i)>0 && q(i)>0)
           s1 = s1 + p(i)*log(p(i)/q(i));
        
           s2 = s2 + q(i)*log(q(i)/p(i));
        end
       
        
    end
    
    KLD = (s1+s2)/2;
end