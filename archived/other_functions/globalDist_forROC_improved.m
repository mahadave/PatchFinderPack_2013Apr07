function brayCurtisSim=globalDist_forROC_improved(pt,et,imageIndex)

%%This file runs the sift algorithm (http://www.vlfeat.org/overview/sift.html)
% and compares it with the fixation points
% obtained from tilke Judd's dataset
% (http://people.csail.mit.edu/tjudd//WherePeopleLook/index.html<http://peo
% ple.csail.mit.edu/tjudd/WherePeopleLook/index.html)

folder = '../ALLSTIMULI';
users = {'CNG', 'ajs', 'emb', 'ems', 'ff', ...
    'hp', 'jcw', 'jw', 'kae',...
    'krl', 'po', 'tmj', 'tu', 'ya', 'zb'};
color={'m','y','b','w','g','y','w','k','g','b','y','w','k','g','b'};

% Cycle through all images
files = dir(strcat(folder, '/*.jpeg'));
%%
show=0;
mainImg=0;

    i=imageIndex;
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
    
    if(size(siftPoints,1)<=25) % for no sift points
        chi_measure =2; 
        bcMeasure = 2;
        brayCurtisSim = 1-bcMeasure;
        
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
    
    densityFix = densityFix +0.000001;
    densitySift = densitySift + 0.000001;
    
    if show==1
        figure, surf(XSift,YSift,densitySift)
        figure, surf(XFix,YFix,densityFix)
    end
    
    chiMeasure = computeChiSquareDist(densityFix,densitySift);
    
    %disp(chiMeasure);
    %chiVals = [chiVals ; chiMeasure];
    
    bcMeasure = computeBrayCurtisDist(densityFix,densitySift);
    disp(bcMeasure);
    %bcVals = [bcVals ; bcMeasure];
    %pause;
    %close all;

    
    sim=1-bcMeasure;
    brayCurtisSim = sim;


%%

if (show==1)
    figure,
    stem(lowerLim:upperLim,1-chiVals); title('chi-squared distance');
    figure, 
    stem(lowerLim:upperLim,1-bcVals); title('Bray-Curtis similarity');
end
%%







