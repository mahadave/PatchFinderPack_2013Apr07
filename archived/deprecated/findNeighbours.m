function [neighboursList] = findNeighbours(index,boxSize,img,N)
    
    neighboursList =[];
    W = size(img,1)/boxSize;
    L =  size(img,2)/boxSize;
    
    if(index == 1)
        neighboursList = [index+1 ; index+L ; index+L+1];
        return;
    elseif (index==L)
        neighboursList = [index-1 ; index+L ; index+L-1];
        return;
    elseif (index==N-W+1)
        neighboursList = [index+1 ; index-L ; index-L+1];
        return;
    elseif (index==N)
        neighboursList = [index-1 ; index-L ; index-L-1];
        return;
    end
    
    
    if(mod(index,L)==0) % right edge
        neighboursList = [index-1 ; index-L-1 ; index-L ;  index+L-1 ; index+L];
        return;
    elseif(mod(index-1,L)==0) % left edge
        neighboursList = [index+1 ; index-L+1 ; index-L ;  index+L+1 ; index+L];
        return;
    elseif(index<L) % top edge
        neighboursList = [ (index-1) ; (index+1) ; index+L ;  index+L-1 ; index+L+1];
        return;
    elseif((N-W+1)<index & index<N) % bottom edge
        neighboursList = [index-1 ; index+1 ; index-L ;  index-L-1 ; index-L+1];
        return;
    end
    
    neighboursList = [index-1 ;index+1 ;  index-L ;  index+L ; index+L+1 ; index+L-1; index-L-1 ;  index-L+1 ];
    
end