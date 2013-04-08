function MI =globalDist_forMI(pt,et)

%%This file runs the sift algorithm (http://www.vlfeat.org/overview/sift.html)
% and compares it with the fixation points
% obtained from tilke Judd's dataset
% (http://people.csail.mit.edu/tjudd//WherePeopleLook/index.html<http://peo
% ple.csail.mit.edu/tjudd/WherePeopleLook/index.html)

disp('starting...');
%clear all
%close all
clc
show=1;
mainImg=1;

installSift();

%decide number of files to run for
lowerLim=10; %replace with 1 for starting file
upperLim=lowerLim+0; %replace with length(files) for last file

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

close all
chiVals=[];
bcVals =[];
for i = lowerLim:upperLim
    
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
        chi_measure =2; 
        bcMeasure = 2;
        chiVals = [chiVals ; chi_measure];
        bcVals = [bcVals ; bcMeasure];
        continue;
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
    [bandwidthFixAndFix,densityFixAndFix,XFixAndFix,YFixAndFix]=kde2d(([Fixed;Sifted]),256,[0 0],[256 256]);
    
    
    for i=1:size(densitySift,1)
        for j=1:size(densitySift,2)
            if(densitySift(i,j)<0)
                densitySift(i,j)=0;
            end
        end
    end
    
    for i=1:size(densityFix,1)
        for j=1:size(densityFix,2)
            if(densityFix(i,j)<0)
                densityFix(i,j)=0;
            end
        end
    end
    
    for i=1:size(densitySiftAndFix,1)
        for j=1:size(densitySiftAndFix,2)
            if(densitySiftAndFix(i,j)<0)
                densitySiftAndFix(i,j)=0;
            end
        end
    end
    
    densityFix  = densityFix  + 0.000001;
    densitySift = densitySift + 0.000001;
    densitySiftAndFix = densitySiftAndFix + 0.000001;
    
    if show==1
        figure, surf(XSift,YSift,densitySift)
        figure, surf(XFix,YFix,densityFix)
        figure, surf(XSiftAndFix,YSiftAndFix,densitySiftAndFix)
    end
    
    
    
    pSift         = densitySift(:)/max(densitySift(:));
    pFix          = densityFix(:)/max(densityFix(:));
    pJoint        = densitySiftAndFix(:)/max(densitySiftAndFix(:));
    pIndependent  = (pSift.*pFix);
    
    %figure,plot(pSift,'--k');
    %hold on;plot(pFix,'--r');
    %hold on;plot(pJoint,'--g');
    
    diffTerm=pJoint.*log2(pJoint./pIndependent);
    figure, plot(diffTerm)
    
    figure, plot(pJoint,'--k')
    hold on, plot(pIndependent,'--r');
    
    MI = sum(diffTerm);
    %MI = mean(diffTerm);
    perMatch = MI/mean([H(pSift) H(pFix)]);
    
    disp(['per Match = ',num2str(perMatch*100)]);
    
    
    
    H_sift  = H(pSift);
    H_fix   = H(pFix);
    H_joint = H(pJoint);
    
    MI = H_sift + H_fix - H_joint;
    
    Rmax = min([H_sift H_fix])/sum([H_sift H_fix]);
    R= MI/sum([H_sift H_fix]);
    
    %disp(['match : ',num2str(R*100/Rmax)]);
    
    disp(['Hs :',num2str(H_sift),' , Hf :',num2str(H_fix),', Hj :',num2str(H_joint)]);
    disp(['mutual information :',num2str(MI),'bits']);
    disp(['R :',num2str(R),' , Rmax :',num2str(Rmax)]);
    
end 

%%

if (show==1)
    figure,
    stem(lowerLim:upperLim,1-chiVals); title('chi-squared distance');
    figure, 
    stem(lowerLim:upperLim,1-bcVals); title('Bray-Curtis similarity');
end
%%

sim=1-bcVals;
brayCurtisList = sim;







