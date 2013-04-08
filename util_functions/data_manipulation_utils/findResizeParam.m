function [nX,nY,alpha] = findResizeParam(X,Y)

    nPix = X*Y;
    target = 256*256;
    alpha =1;
    while (nPix>target)
        alpha= alpha - 0.1;
        nX = round(alpha*X);
        nY = round(alpha*Y);
        nPix=nX*nY;
    end
     
    %disp('alpha = '); disp(alpha);
    
end

