%%This file runs the sift algorithm
%% bag is a patch and the instances are the randomly selected points 
% fischer extracts a feature vector for each bag based on the universal GMM
% trained using all the instances
%

disp('starting...');
clear all
close all
clc
installSift();


%--------------------------TRAIN-------------------------------------------
%---
%-


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
%decide number of files to run for
lowerLim=1; %replace with 1 for starting file
upperLim=lowerLim-1+50;%length(files); %replace with length(files) for last file

trainLim = 40; 
%%
show=0;
boxShow=0;
NPoints=10; % num points to pick randomly

D=[];
sizeList=[];
indexList=[0 1];
trainingList=[];
labelList=[];
testLabels=[];
trainingLabels=[];
pointList=[];

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
    % find peak of KDE for determining box seed point

    [resized_image,densityFix]=getFixationKDE(image,users,filename);
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
    %
    patchesListImage =[];
    index=1;
    probThreshold = threshold/5; % subject to change
    countOnes=0;
 
    %
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

                labelList = [labelList label]; % label all                
                
                if(imgIndex >=trainLim)
                    continue;
                end
                %disp([lowerX upperX lowerY upperY]);
                %disp(label)
                d_all=[];
                for lp=1:NPoints % pick N random points 
                    f=[]; d=[];
                    fc = [round(rand(1)*boxSize*2);round(rand(1)*boxSize*2);10;0] ; % check if this is correct******
                    [f,d] = vl_sift(single(resized_image),'frames',fc,'orientations') ;
                    d=d(:,1); % why do I need to do this? read paper Lowe
                    %labeled_d = [d' label];
                    d_all = [d_all; d'];
                end
                
                %{
                d_all = d_all(1:10,:);
                d_all = reshape(d_all,10*128,1);
                d_all = d_all';
                d_all = [d_all label]; % store label along with feature vector
                %size(d_all)
                %}
                
                pointList=[pointList;d_all]; % add to training set only if within training bounds
                trainingLabels = [trainingLabels label];
                %testLabels = [testLabels label];
                
                index=index+1;
                
            end

        end
        
        boxSize=boxSize/2; % half box size for concentrated fixation distribution -- keep halving till size =1
    end
    

    disp(['positives:',num2str(countOnes),' boxSize:',num2str(4*boxSize)]);
    
    sizeList = [sizeList; boxSize*2]; % box size per image
    %indexList =[indexList; [imgIndex size(descriptorList,1)]]; % store end index of patch descriptors for cur image
    
    % visualize box - fix region
    if show==1
        figure,imagesc(densityFix)
        rectangle('Position', boxRect, 'LineWidth',2,'LineStyle','--')
    end
    
    
    if (show==1 || boxShow==1)
            %visualize Fix Points
          %  for k = 1:length(Fixed)
           %     text ((Fixed(k, 1)), (Fixed(k, 2)), ['{\color{red}\bf', num2str(k), '}'], 'FontSize', 5, 'BackgroundColor', 'y');
           % end     
    end
    
end

%%

D=1; %divisions of data
trainingLowerLimit = 1;
trainingUpperLimit = numel(labelList)/D;
%%

GMMList = pointList;
GMMList = double(GMMList); %--- universal list of descriptors over all training patches
boxSizeForTest = ceil(mean(sizeList(:)));

%%
    k=5;

    gmm = gmdistribution.fit(GMMList, k, 'covtype','diagonal',...
                                            'regularize',1e-8); % says some columns are constant.. do PCA?
    
    save(['GMM_',num2str(k)],'gmm');                                    
%%

    instances = GMMList;
    L = size(instances,1); % all points from all patches
    fishers = [];
    %%
for i = 1:NPoints:L% jump in steps of NPoints since NPoints belong to the same patch and we want to form a Fisher Feature Vector of these
    
    range=i:(i+NPoints-1);
    in = instances(range,:);
    F = extract_fisher_vector(in, gmm); 
    fishers = [fishers ; F'];
end

%%
trainingList = fishers;
trainingLabels = trainingLabels';
%labelList = labelList';    
%%
SMO_OptsStruct = svmsmoset('MaxIter', 200000);
SVMStruct = svmtrain(trainingList,trainingLabels,'BoxConstraint',10,'Method', 'SMO', 'SMO_Opts', SMO_OptsStruct);

save('SVMStruct','SVMStruct');
%%



%% small test code

testList = trainingList;
predictedLabelList =[];
predictedLabelList = svmclassify(SVMStruct,testList);
figure
subplot 211 
stem(predictedLabelList)
title('predicted');
subplot 212
stem(labelList)
title('real')

a=0;
l=0;
l2=0;
p=0;
x=0;
for i = 1:numel(predictedLabelList)
    
    if(labelList(i)==1)
        l=l+1;
        if(predictedLabelList(i)==1)
            a=a+1;
        end
    end
    
    if(labelList(i)==-1)
        l2=l2+1;
        if(predictedLabelList(i)==-1)
            x=x+1;
        end
    end
end

p=a/l;
n=x/l2;
disp(['p = ',num2str(p),' , n = ',num2str(n)]);
%%


















































%%

%--------------------------TEST-------------------------------------------
%---
%-





%decide number of files to run for
lowerLimTest=trainLim; %replace with 1 for starting file
upperLimTest=lowerLimTest+10; %replace with length(files) for last file

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
testList=[];
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
    if show==1
        figure,imshow(resized_image);
        for k = 1:length(Fixed)
            text ((Fixed(k, 1)), (Fixed(k, 2)), ['{\color{red}\bf', num2str(k), '}'], 'FontSize', 5, 'BackgroundColor', 'y');
        end
    end

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
            for lp=1:NPoints % pick N random points 
                f=[]; d=[];
                fc = [round(rand(1)*boxSize*2);round(rand(1)*boxSize*2);10;0] ; % check if this is correct******
                [f,d] = vl_sift(single(resized_image),'frames',fc,'orientations') ;
                d=d(:,1); % why do I need to do this? read paper Lowe
                d_all = [d_all; d']; %% adding a false label
            end

            testList=[testList;d_all]; 
            index=index+1;
            
            %{
            k=5;
            [neighbours distances]=kNearestNeighbors(double(descriptorList),double(d_all),k);
                      
            disp('neighbours')
            disp(neighbours)
            disp('dist')
            disp(distances)
            disp('class')
            disp(descriptorList(neighbours,end))
            %}
            %disp(size(d_patch));
            %descriptorList=[descriptorList;d_patch];

            %test_fischer=extract_fisher_vector(double(d_patch), gmm); 
            

            %----------------> find closest neighbour here <---------------------------
            
            %imwrite(patch,['..\patches\img',num2str(imgIndex),'_',num2str(index)],'jpg')
            %index=index+1;
        end

    end

    
end


%%

testList = double(testList);
%%
    instances = testList;
    L = size(instances,1); % all points from all patches
    fishers = [];
    %%
for i = 1:NPoints:L% jump in steps of NPoints since NPoints belong to the same patch and we want to form a Fisher Feature Vector of these
    
    range=i:(i+NPoints-1);
    in = instances(range,:);
    F = extract_fisher_vector(in, gmm); 
    fishers = [fishers ; F'];
end

%%

testList = fishers;
predictedLabelList =[];
predictedLabelList = svmclassify(SVMStruct,testList);

%% small test code

figure
subplot 211 
stem(predictedLabelList)
title('predicted');
subplot 212
stem(labelList)
title('real')

a=0;
l=0;
l2=0;
p=0;
x=0;
for i = 1:numel(predictedLabelList)
    
    if(labelList(i)==1)
        l=l+1;
        if(predictedLabelList(i)==1)
            a=a+1;
        end
    end
    
    if(labelList(i)==-1)
        l2=l2+1;
        if(predictedLabelList(i)==-1)
            x=x+1;
        end
    end
end

p=a/l;
n=x/l2;
disp(['p = ',num2str(p),' , n = ',num2str(n)]);
xlabel(['p = ',num2str(p),' , n = ',num2str(n)]);