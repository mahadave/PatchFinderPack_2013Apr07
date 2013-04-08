function [ nr,ng,nb  ] = extractColourHists(I)
%input I - the image
%   Detailed explanation goes here

    r=double(I(:,1));
    g=double(I(:,2));
    b=double(I(:,3));
    
    NB=20;
    
    [nr,rhist]=hist(r,NB);
    nr=nr./sum(nr);
    [ng,ghist]=hist(g,NB);
    ng=ng./sum(ng);
    [nb,bhist]=hist(b,NB);
    nb=nb./sum(nb);
%     
%     figure; bar(rhist,nr);
%     figure; bar(bhist,nb);
%     figure; bar(ghist,ng);
%    
    
end

