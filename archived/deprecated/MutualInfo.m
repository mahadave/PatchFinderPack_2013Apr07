function [MI] = MutualInfo(IM1,IM2)
    
    IM1=abs(IM1)*255/max(max(IM1));
    IM2=abs(IM2)*255/max(max(IM2));
  
    rows=size(IM1,1);
    cols=size(IM2,2);
    N=256;
    
    h=zeros(N,N);
    
    size(IM1)
    size(IM2)
    
    for i=1:rows;    %  col 
        for j=1:cols;   %   rows
            %h(IM1(i,j)+1,IM2(i,j)+1)= h(IM1(i,j)+1,IM2(i,j)+1)+1;
            h(i,j)=(IM1(i,j)*IM2(i,j))./2;
        end
    end
    
    
    
    figure,
    imagesc(h); title('avg');
    
    
    [r,c] = size(h);
    b= h./(r*c); % normalized joint histogram
    y_marg=sum(b); %sum of the rows of normalized joint histogram
    x_marg=sum(b');%sum of columns of normalized joint histogran
    
    Hy=0;
    for i=1:c;    %  col
        if( y_marg(i)==0 )
            %do nothing
        else
            Hy = Hy + -(y_marg(i)*(log2(y_marg(i)))); %marginal entropy for image 1
        end
    end
    
    Hx=0;
    for i=1:r;    %rows
        if( x_marg(i)==0 )
            %do nothing
        else
            Hx = Hx + -(x_marg(i)*(log2(x_marg(i)))); %marginal entropy for image 2
        end   
    end
    h_xy = -sum(sum(b.*(log2(b+(b==0))))); % joint entropy
    
    MI = -(Hx+Hy-h_xy);% Mutual information
    %x
end