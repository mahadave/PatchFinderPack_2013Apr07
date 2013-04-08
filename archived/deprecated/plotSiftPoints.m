function [] = plotSiftPoints(I,f)
% Plot sift key points
% Inputs:
%   I - image (grayscale)
%   f - frame computed from vl_sift

    imshow(I);
    perm = randperm(size(f,2)) ; 
    sel = perm(1:size(f,2)) ;
    h1 = vl_plotframe(f(:,sel)) ; 
    h2 = vl_plotframe(f(:,sel)) ; 
    set(h1,'color','k','linewidth',3) ;
    set(h2,'color','g','linewidth',2) ;

end