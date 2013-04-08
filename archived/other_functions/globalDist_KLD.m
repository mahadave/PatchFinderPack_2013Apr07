function KLD =globalDist_forMI(pt,et,i)

%%This file runs the sift algorithm (http://www.vlfeat.org/overview/sift.html)
% and compares it with the fixation points
% obtained from tilke Judd's dataset
% (http://people.csail.mit.edu/tjudd//WherePeopleLook/index.html<http://peo
% ple.csail.mit.edu/tjudd/WherePeopleLook/index.html)


show=0;
mainImg=0;

%%

folder = '../ALLSTIMULI';
% Tilke Judd June 26, 2008
% ShowEyeDataForImage should show the eyetracking data for all users in
% 'users' on a specified image.

users = {'CNG', 'ajs', 'emb', 'ems', 'ff', ...
    'hp', 'jcw', 'jw', 'kae',...
    'krl', 'po', 'tmj', 'tu', 'ya', 'zb'};
 
color={'m','y','b','w','g','y','w','k','g','b','y','w','k','g','b'};


% Cycle through all images
files = dir(strcat(folder, '/*.jpeg'));


%%
    
    filename = files(i).name;
    disp(filename);
    disp(i);
    % Get image
    image = readGray(folder, filename);
    disp(['opened : ',filename]);
    
    if (show==1 || mainImg==1)
        figure;
        imshow(image); 
        hold on;
    end

    %%sift computation
    
    %peakThreshold=10;
    %edgeThreshold=5;
    peakThreshold=pt;
    edgeThreshold=et; % set for each experiment
    
    [f,d] = produceSiftPoints(image,peakThreshold,edgeThreshold);
    siftPoints = f(1:2,:,:)'; % siftPoints coordinates are stored here
    siftPoints = round(siftPoints);
    
    
    if (show==1 || mainImg==1)
        plotSiftPoints(image,f);
    end

    
    
    %%fixation points
    FixPoints= [];
    for j = 1:length(users) % for all users find Fixation Points
        user = users{j};
        Pts = getFixationPointsAcrossUsers(filename,user);
        FixPoints = [FixPoints ; Pts];
    end    
    
    FixPoints = round(FixPoints);
    
    if (show==1 || mainImg==1)
        %visualize Fix Points
        for k = 1:length(FixPoints)
            text ((FixPoints(k, 1)), (FixPoints(k, 2)), ['{\color{red}\bf', num2str(k), '}'], 'FontSize', 5, 'BackgroundColor', 'y');
        end     
    end
    
    
    
    if(size(siftPoints,1)<=5) % for no sift points
        KLD = -1;
        return;
    end
    
    
    scale=256;
    sc_FixX=256.*FixPoints(:,1)./size(image,2);
    sc_FixY=256.*FixPoints(:,2)./size(image,1);
    Fixed=[sc_FixX sc_FixY];
    %figure,imshow(imresize(image,[256 256]));
    %for k = 1:length(FixPoints)
    %    text ((Fixed(k, 1)), (Fixed(k, 2)), ['{\color{red}\bf', num2str(k), '}'], 'FontSize', 5, 'BackgroundColor', 'y');
    %end
    
    sc_siftX=256.*siftPoints(:,1)./size(image,2);
    sc_siftY=256.*siftPoints(:,2)./size(image,1);
    Sifted=[sc_siftX sc_siftY];
    %figure,imshow(imresize(image,[256 256]));
    %for k = 1:length(Sifted)
    %    text ((Sifted(k, 1)), (Sifted(k, 2)), ['{\color{red}\bf', num2str(k), '}'], 'FontSize', 5, 'BackgroundColor', 'g');
    %end
    
    
    [bandwidthSift,densitySift,XSift,YSift]=kde2d(Sifted,256,[0 0],[256 256]);
    [bandwidthFix,densityFix,XFix,YFix]=kde2d(Fixed,256,[0 0],[256 256]);    
    %[bandwidthSiftOrFix,densitySiftOrFix,XSiftOrFix,YSiftOrFix]=kde2d(([Fixed;Sifted]),256,[0 0],[256 256]);
    %[bandwidthFixOrFix,densityFixOrFix,XFixOrFix,YFixOrFix]=kde2d(([Fixed;Fixed]),256,[0 0],[256 256]);
    %[bandwidthFixOrFix,densitySiftOrSift,XSiftOrSift,YSiftOrSift]=kde2d(([Sifted;Sifted]),256,[0 0],[256 256]);
    
    densitySift = removeZeros(densitySift);
    densityFix = removeZeros(densityFix);
    %densitySiftOrFix = removeZeros(densitySiftOrFix);
    %densityFixOrFix = removeZeros(densityFixOrFix);
    %densitySiftOrSift = removeZeros(densitySiftOrSift);
    
    
    %densityFixAndFix = 2*densityFix - densityFixOrFix;
    %err1 = -densityFix + densityFixAndFix ;
    %densitySiftAndSift = 2*densitySift - densitySiftOrSift;
    %err2 = -densitySift + densitySiftAndSift ;
    
    %err = err1+err2;
    
    
    
    
    
    %densitySiftOrFix = findUnion(densitySift,densityFix);
    %densitySiftAndFix = densitySift + densityFix - densitySiftOrFix;
    
    %densitySiftAndFix = removeZeros(densitySiftAndFix);
    %densityFix  = densityFix  + 0.000001;
    %densitySift = densitySift + 0.000001;
    %densitySiftOrFix = densitySiftOrFix + 0.000001;
    %err = err + 0.000001;

     
    if show==1
        %figure, surf(XSift,YSift,densitySift)
        %figure, surf(XFix,YFix,densityFix)
        %figure, surf(XSiftOrFix,YSiftOrSift,densitySiftOrFix)
        %figure, surf(XFixOrFix,YFixOrFix,densitySiftAndFix)
        
        %figure, surf(XSiftOrFix,YSiftOrSift,densitySiftOrSift)
        %figure, surf(XFixOrFix,YFixOrFix,2*densityFix)
        %figure, surf(XFixOrFix,YFixOrFix,densityFixOrFix)
        %figure, surf(XFixOrFix,YFixOrFix,densitySiftAndSift)
        %figure, surf(XFixOrFix,YFixOrFix,densityFixAndFix)
        
        %figure, surf(XFixOrFix,YFixOrFix,abs(err1))
        %figure, surf(XFixOrFix,YFixOrFix,err2)
        %figure, surf(XFixOrFix,YFixOrFix,err)
        %figure, surf(XFixOrFix,YFixOrFix,densityFixAndFix-err1)
        %figure, surf(XFixOrFix,YFixOrFix,densitySiftAndSift-err2)
        %figure, surf(XSiftOrFix,YSiftOrFix,densitySiftAndFix-err)
    end
    
    
    
    pSift         = densitySift(:);%/max(densitySift(:));
    pFix          = densityFix(:);%/max(densityFix(:));
    
 %   pJoint        = (densitySiftAndFix(:));%/max(densitySiftAndFix(:)))
    %pJoint        = (densitySiftAndFix(:)-err(:));%/max(densitySiftAndFix(:)))
   % pJoint        = (densitySiftAndFix(:)-err(:))/(max([densitySiftAndFix(:)-err(:)]));
  %  pIndependent  = (pSift.*pFix);
    
    if(show==1)
        figure,plot(pSift,'--k');
        hold on;plot(pFix,'--r');
    end
    
    KLD = computeKLD(pSift,pFix);
    disp(['KLD = ',num2str(KLD),'']);
   
    
end 
