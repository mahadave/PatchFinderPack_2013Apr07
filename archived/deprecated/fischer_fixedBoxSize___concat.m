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


%--------------------------TRAIN-------------------------------------------
%---
%-
%%

%decide number of files to run for
lowerLim=1; %replace with 1 for starting file
upperLim=lowerLim+11; %replace with length(files) for last file

%%

folder = '../ALLSTIMULI/';
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
boxShow=0;

D=[];
sizeList=[];
indexList=[0 1];
descriptorList=[];

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
    
    %%---------------------------------------------------------------------
    %%--
    %%sift computation params
    
    peakThreshold=10;
    edgeThreshold=5;
    
    %----------------------------------------------------------------------
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


    %----------------------------------------------------------------------
    % rescale fixation points ---------------------------------------------
    scale=256;
    sc_FixX=256.*FixPoints(:,1)./size(image,2);
    sc_FixY=256.*FixPoints(:,2)./size(image,1);
    Fixed=[sc_FixX sc_FixY];
        
    %----------------------------------------------------------------------
    %resize image for consistency
    resized_image = imresize(image,[256 256]);
    
    % visualize points
    if show==1
        figure,imshow(resized_image);
        for k = 1:length(FixPoints)
            text ((Fixed(k, 1)), (Fixed(k, 2)), ['{\color{red}\bf', num2str(k), '}'], 'FontSize', 5, 'BackgroundColor', 'y');
        end
    end

    %----------------------------------------------------------------------
    % determine KDE for fixation points
      
    [bandwidthFix,densityFix,XFix,YFix]=kde2d(Fixed,256,[0 0],[256 256]); % estimate kernel density
    densityFix = removeZeros(densityFix);

    % visualize the KDE
    if show==1
        figure, surf(XFix,YFix,densityFix)
    end

    % find peak of KDE for determining box seed point
    [y x] = find(densityFix==max(densityFix(:)));
    disp([x y])
    
    %----------------------------------------------------------------------
    % use boxSize = 32x32
    
    s=8; % initial box size=10x10 px
    growth=8;
    f=0.2; % percentage of max for threshold
    maxProb = max(densityFix(:));
    threshold = f*maxProb;
    %clc;
    
    
    boxSize=16;
    
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
    
    %----------------------------------------------------------------------
    % cut patches from the image (and save as img_IMAGEINDEX_PATCHINDEX=optional)
    %using the "2*boxSize" determined
    
    
    %-------------show image
    
    if(show==1 || boxShow==1)
        figure,imagesc(densityFix)
    end
    
    %------------------------------
    
    patchesListImage =[];
    index=1;
    probThreshold = threshold/5; % subject to change
    countOnes=0;
    
    while(countOnes==0 && boxSize>0)
        
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

                meanDensity = mean(patchDensity);

                %disp([lowerX upperX lowerY upperY]);
                %patchesListImage(:,:,(index)) = patch;


                if(meanDensity>=probThreshold)

                    countOnes = countOnes+1;
                    label = 1;

                    %patchList = [patchList; [class imgIndex]]; 
                    
                    if (show==1 || boxShow==1)
                        boxRect=[lowerY lowerX boxSize*2 boxSize*2]; % xStart,yStart,boxSize
                        rectangle('Position', boxRect, 'FaceColor','k')
                    end

                else

                    label =-1;
                end

                %disp([lowerX upperX lowerY upperY]);
                %disp(label)

                
                d_all=[];
                N=5;
                for lp=1:N % pick 10 random points 
                    f=[]; d=[];
                    fc = [round(rand(1)*boxSize*2);round(rand(1)*boxSize*2);10;0] ;
                    [f,d] = vl_sift(single(resized_image),'frames',fc,'orientations') ;
                    d_all = [d_all; d'];
                end
                
                d_all = d_all(1:N,:);
                d_all = reshape(d_all,N*128,1);
                d_all = d_all';
                d_all = [d_all label]; % store label along with feature vector
                %size(d_all)
                descriptorList=[descriptorList;d_all];
                index=index+1;
            end

        end
        
        boxSize=boxSize/2; % half box size for concentrated fixation distribution -- keep halving till size =1
    end
    
    disp(['positives:',num2str(countOnes),' boxSize:',num2str(4*boxSize)]);
    
    sizeList = [sizeList; boxSize*2]; % box size
    indexList =[indexList; [imgIndex size(descriptorList,1)]]; % store end index of patch descriptors for cur image
    
    % visualize box - fix region
    if show==1
        figure,imagesc(densityFix)
        rectangle('Position', boxRect, 'FaceColor','k')
    end
    
    
    if (show==1 || boxShow==1)
            %visualize Fix Points
            for k = 1:length(Fixed)
                text ((Fixed(k, 1)), (Fixed(k, 2)), ['{\color{red}\bf', num2str(k), '}'], 'FontSize', 5, 'BackgroundColor', 'y');
            end     
    end
    
end

descriptorList = double(descriptorList); %--- universal list of descriptors over all training patches
boxSizeForTest = ceil(mean(sizeList(:)));

%%
    k=5;
    gmm = gmdistribution.fit((descriptorList(:,(1:end-1))), k, 'covtype','diagonal',...
                                            'regularize',1e-8);
    
%%
%{
    L = indexList(:,2); % keeps track of ending position of each images sift
    fischers = [];
for i = 1:(numel(L)-1)%lowerLim:upperLim
    
    range=L(i):L(i+1);
    F = extract_fisher_vector(descriptorList(range,:), gmm); 
    fischers = [fischers ; F'];
end
%}
    

%%
























































%%

%--------------------------TEST-------------------------------------------
%---
%-





%decide number of files to run for
lowerLimTest=upperLim+30; %replace with 1 for starting file
upperLimTest=lowerLimTest+0; %replace with length(files) for last file

%%

folder = '../ALLSTIMULI/Faces';
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
boxShow=0;

D=[];
sizeList=[];
indexList=[0 1];
close all
disp('testing')

for imgIndex = lowerLimTest:upperLimTest
    
    filename = files(imgIndex).name;
    disp(filename);
    disp(imgIndex);
    % Get image
    
    image = readGray(folder, filename);
    disp(['opened : ',filename]);
   
    resized_image = imresize(image,[256 256]);
    
        FixPoints= [];
    for j = 1:length(users) % for all users find Fixation Points
        user = users{j};
        Pts = getFixationPointsAcrossUsers(filename,user);
        FixPoints = [FixPoints ; Pts];
    end        
    FixPoints = round(FixPoints);

     % rescale fixation points ---------------------------------------------
    scale=256;
    sc_FixX=256.*FixPoints(:,1)./size(image,2);
    sc_FixY=256.*FixPoints(:,2)./size(image,1);
    Fixed=[sc_FixX sc_FixY];
        
    % visualize points
    %if show==1
        figure,imshow(resized_image);
        for k = 1:length(Fixed)
            text ((Fixed(k, 1)), (Fixed(k, 2)), ['{\color{red}\bf', num2str(k), '}'], 'FontSize', 5, 'BackgroundColor', 'y');
        end
    %end

    %
    %%---------------------------------------------------------------------
    %%--
    %%sift computation params
    
    peakThreshold=10;
    edgeThreshold=5;
        
    %----------------------------------------------------------------------
    %resize image for consistency
    resized_image = imresize(image,[256 256]);
    
    
    %----------------------------------------------------------------------
    % use boxSize = 32x32
    
    boxSize=16;
    
    %----------------------------------------------------------------------
    % cut patches from the image (and save as img_IMAGEINDEX_PATCHINDEX=optional)
    %using the "2*boxSize" determined
    
    %------------------------------
    
    patchesListImage =[];
    index=1;

    
    for i=1:2*boxSize:(size(resized_image,1))
        for j=1:2*boxSize:(size(resized_image,2))

            upperX=i+2*boxSize-1;
            lowerX=i;
            lowerY=j; 
            upperY=j+2*boxSize-1;

            if(upperY>size(resized_image,2))
                upperY = size(resized_image,2);
            end

            if(upperX>size(resized_image,1))
                upperX=size(resized_image,2);
            end

            %disp([lowerX upperX lowerY upperY]);
            %patchesListImage(:,:,(index)) = patch;

            %disp([lowerX upperX lowerY upperY]);
            %disp(label)

            d_all=[];
            pts=10; % random points
            for lp=1:pts
                fc = [round(rand(1)*boxSize*2);round(rand(1)*boxSize*2);10;0] ;
                [f,d] = vl_sift(single(resized_image),'frames',fc,'orientations') ;
                d_all = [d_all;d'];
            end
            
            
            d_all = d_all(1:pts,:);
            d_all = reshape(d_all,pts*128,1);
            d_all = d_all';
            d_all = [d_all 0]; % store label along with feature vector

            k=5;
            [neighbours distances]=kNearestNeighbors(double(descriptorList),double(d_all),k);
            
           
            disp('neighbours')
            disp(neighbours)
            disp('dist')
            disp(distances)
            disp('class')
            disp(descriptorList(neighbours,end))

            %disp(size(d_patch));
            %descriptorList=[descriptorList;d_patch];

            %test_fischer=extract_fisher_vector(double(d_patch), gmm); 
            

            %----------------> find closest neighbour here <---------------------------
            
            %imwrite(patch,['..\patches\img',num2str(imgIndex),'_',num2str(index)],'jpg')
            %index=index+1;
        end

    end

    
end
