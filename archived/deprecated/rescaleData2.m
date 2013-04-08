function [resized_image] = rescaleData2(image)

% rescale fixation points ---------------------------------------------
    [X Y]=size(image);
    [nX,nY,alpha]=findResizeParam(X,Y);
%     disp('alpha -->'); disp([alpha]);
    %newFixPoints = imresize(FixPoints,[nX nY]);
%     sc_FixX=FixPoints(:,1).*(nX/X);
%     sc_FixY=FixPoints(:,2).*(nY/Y);
%     

%     sc_FixX=256.*FixPoints(:,1)./size(image,2);
%     sc_FixY=256.*FixPoints(:,2)./size(image,1);
    newX = uint16(round(X*alpha)); newY = uint16(round(Y*alpha));
%     disp([X Y alpha])
%     disp([newX newY])
    resized_image = imresize(image,[newX newY]);
   
    
% disp([FixPoints newFixPoints])
end