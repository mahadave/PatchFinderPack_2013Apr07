%%This file runs the sift algorithm (http://www.vlfeat.org/overview/sift.html)
% and compares it with the fixation points
% obtained from tilke Judd's dataset
% (http://people.csail.mit.edu/tjudd//WherePeopleLook/index.html<http://peo
% ple.csail.mit.edu/tjudd/WherePeopleLook/index.html)

disp('starting...');
clear all
close all
clc
installSift();

%decide number of files to run for
lowerLim=1; %replace with 1 for starting file
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
show=0;

D=[];
sizeList=[];
indexList=[0 1];
close all

for imgIndex = lowerLim:upperLim
    
    filename = files(imgIndex).name;
    disp(filename);
    disp(imgIndex);
    % Get image
    
    image = readGray(folder, filename);
    disp(['opened : ',filename]);
    
    if show==1
        figure;
        imshow(image); 
        hold on;

    end
    
    %%sift computation
    
    peakThreshold=10;
    edgeThreshold=5;
    [f,d] = produceSiftPoints(image,peakThreshold,edgeThreshold);
    
    d=d';
    D = [D;d]; % store index along with the sift pts extracted
    
    indexList =[indexList; [imgIndex size(D,1)]];
    
    
    %%fixation points
    FixPoints= [];
    for j = 1:length(users) % for all users find Fixation Points
        user = users{j};
        Pts = getFixationPointsAcrossUsers(filename,user);
        FixPoints = [FixPoints ; Pts];
    end    

        
    FixPoints = round(FixPoints);

    if (show==1)
            %visualize Fix Points
            for k = 1:length(FixPoints)
                text ((FixPoints(k, 1)), (FixPoints(k, 2)), ['{\color{red}\bf', num2str(k), '}'], 'FontSize', 5, 'BackgroundColor', 'y');
            end     
    end


    scale=256;
    sc_FixX=256.*FixPoints(:,1)./size(image,2);
    sc_FixY=256.*FixPoints(:,2)./size(image,1);
    Fixed=[sc_FixX sc_FixY];
        
        
    resized_image = imresize(image,[256 256]);
    
    if show==1
        figure,imshow(resized_image);
        for k = 1:length(FixPoints)
            text ((Fixed(k, 1)), (Fixed(k, 2)), ['{\color{red}\bf', num2str(k), '}'], 'FontSize', 5, 'BackgroundColor', 'y');
        end
    end

      
    [bandwidthFix,densityFix,XFix,YFix]=kde2d(Fixed,256,[0 0],[256 256]); % estimate kernel density


    densityFix = removeZeros(densityFix);
        
    if show==1
        figure, surf(XFix,YFix,densityFix)
    end

    [y x] = find(densityFix==max(densityFix(:)));
    disp([x y])
    
    s=8; % initial box size=10x10 px
    growth=8;
    f=0.2; % percentage of max for threshold
    maxProb = max(densityFix(:));
    threshold = f*maxProb;
    %clc;
    for i=s:growth:size(resized_image,1)
       
        lowerX = (x-i);
        upperX = (x+i);
        
        lowerY = (y-i);
        upperY = (y+i);
        
        if(lowerX<=0)
            lowerX = (1);
        end
        if(upperX>size(resized_image,1))
            upperX = (size(resized_image,1));
        end
        if(lowerY<=0)
            lowerY =  (1);
        end
        if (upperY>size(resized_image,1))
            upperY = (size(resized_image,2));
        end
        
        box=densityFix(lowerX:upperX,lowerY:upperY);
        meanVal = mean(box(:));
        
        
        if(meanVal<(threshold))
            break;
        end
        %disp(box)
    end
    
    if(i>s)
        boxSize=(i-growth);
    else
        boxSize=(i);
    end
    
    
    
    disp('boxSize : ');disp(boxSize);
    
    lowerX = (x-boxSize);
    upperX = (x+boxSize);

    lowerY = (y-boxSize);
    upperY = (y+boxSize);

    if(lowerX<=0)
        lowerX = (1);
    end
    if(upperX>size(resized_image,1))
        upperX = (size(resized_image,1));
    end
    if(lowerY<=0)
        lowerY =  (1);
    end
    if (upperY>size(resized_image,1))
        upperY = (size(resized_image,2));
    end
    
    
    
    % box size for each image is 2*boxSize
    
    box = densityFix(lowerX:upperX,lowerY:upperY);
    boxRect=[x-boxSize y-boxSize boxSize*2 boxSize*2]; % xStart,yStart,boxSize
    
    
    patchesListImage =[];
    index=1;
    for i=1:2*boxSize:(size(resized_image,1))
        for j=1:2*boxSize:(size(resized_image,2))
            
            upperX = i+2*boxSize-1;
            lowerX=i;
            lowerY=j; 
            upperY=j+2*boxSize-1;
            
            if(upperY>size(resized_image,2))
                upperY = size(resized_image,2);
            end
            
            if(upperX>size(resized_image,1))
                upperX=size(resized_image,2);
            end
            
            patch = resized_image(lowerX:upperX,lowerY:upperY);
            patchDensity = densityFix(lowerX:upperX,lowerY:upperY);
            
            meanDensity = mean(patchDensity(:));
            
            disp([lowerX upperX lowerY upperY]);
            patchesListImage(:,:,(index)) = patch;
            
            index=index+1;
        end
        
    end
    
    disp('h2')
    sizeList = [sizeList; boxSize*2]; % box size
    
    % visualize box - fix region
    if show==1
        figure,imagesc(densityFix)
        rectangle('Position', boxRect, 'FaceColor','k')
    end
    
    
    
end

D = double(D);
boxSizeForTest = ceil(mean(sizeList(:)));

%%
    k=5;
    gmm = gmdistribution.fit((D), k, 'covtype','diagonal',...
                                            'regularize',1e-8);
    
%%
    L = indexList(:,2); % keeps track of ending position of each images sift
    fischers = [];
for i = 1:(numel(L)-1)%lowerLim:upperLim
    
    range=L(i):L(i+1);
    F = extract_fisher_vector(D(range,:), gmm); 
    fischers = [fischers ; F'];
end

    