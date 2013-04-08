function [ avgTPR , avgFPR ] = localDist_forROC(splitPercent) %%{pt,et}% 
%LOCALDIST_FORROC Summary of this function goes here
%   Detailed explanation goes here
    %%This file runs the sift algorithm (http://www.vlfeat.org/overview/sift.html)
% and compares it with the fixation points
% obtained from tilke Judd's dataset
% (http://people.csail.mit.edu/tjudd//WherePeopleLook/index.html<http://peo
% ple.csail.mit.edu/tjudd/WherePeopleLook/index.html)

    disp('starting...');
  
    show=0;
    mainImg=0;

    installSift();

    %decide number of files to run for
    lowerLim=16; %replace with 1 for starting file
    upperLim=lowerLim+10; %replace with length(files) for last file

    

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

    P_list =[]; roc_y=[];
    R_List =[]; roc_x=[]; F_List =[];

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

        peakThreshold=10;
        edgeThreshold=5;
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

        sc_siftX=256.*siftPoints(:,1)./size(image,2); % scaled
        sc_siftY=256.*siftPoints(:,2)./size(image,1);
        Sifted=[sc_siftX sc_siftY];
        %figure,imshow(imresize(image,[256 256]));
        %for k = 1:length(Sifted)
        %    text ((Sifted(k, 1)), (Sifted(k, 2)), ['{\color{red}\bf', num2str(k), '}'], 'FontSize', 5, 'BackgroundColor', 'g');
        %end





        [bandwidthSift,densitySift,XSift,YSift]=kde2d(Sifted,256,[0 0],[256 256]);
        [bandwidthFix,densityFix,XFix,YFix]=kde2d(Fixed,256,[0 0],[256 256]);


        if show==1
            figure, surf(XSift,YSift,densitySift)
            figure, surf(XFix,YFix,densityFix)
        end


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


        siftInSiftList=[];
        sListIndices=[];
        siftAugList=[];
        for i=1:size(Sifted,1)
           y = round(Sifted(i,1)); 
           x = round(Sifted(i,2));
           %disp([x y]);
           siftInSiftList = [siftInSiftList ; densitySift(x,y)];
           sListIndices = [sListIndices ; [y x]];
           siftAugList = [siftInSiftList sListIndices];
        end

        sortedSiftAugList=sortrows(siftAugList);

        fixInFixList=[];
        fListIndices =[];
        for i=1:size(Fixed,1)
           y = round(Fixed(i,1)); 
           x = round(Fixed(i,2));

           if(x<0 || x>256 || y<0 ||  y>256)
               continue;

           end
           fixInFixList = [fixInFixList ; densityFix(x,y)];
           fListIndices = [fListIndices ; [y x]];
           augList = [fixInFixList fListIndices];
        end


        sortedAugList=sortrows(augList);

        x=splitPercent; % percent split
        s = size(sortedAugList,1);
        i=round(x*(s));
        bottomX = sortedAugList(1:i,:,:);
        topRem = sortedAugList(i+1:end,:,:);


        s = size(sortedSiftAugList,1);
        i=round(x*(s));
        bottomXSift = sortedSiftAugList((1:i),2:3,:);
        topRemSift = sortedSiftAugList((i+1):end,2:3,:);



        siftGoodInFixList=[];
        siftBadInFixList=[];
        for i=1:size(topRemSift,1)
           y = round(topRemSift(i,1)); 
           x = round(topRemSift(i,2));
           siftGoodInFixList = [siftGoodInFixList ; densityFix(x,y)];
        end

        for i=1:size(bottomXSift,1)
           y = round(bottomXSift(i,1)); 
           x = round(bottomXSift(i,2));
           siftBadInFixList = [siftBadInFixList ; densityFix(x,y)];
        end

        %figure;
        %imagesc(densitySift); title('sift density');

        %figure;
        %imagesc(densityFix); title('Fixation density');

        threshold = max(bottomX(:,1,:));

        if show==1
            figure;
            imshow(imresize((image),[256 256]));
            hold on;

            %visualize top Points

            plotPoints=topRem(:,2:3,:);
            for k = 1:length(plotPoints)
                text ( (plotPoints(k,1)), (plotPoints(k,2)), ['{\color{red}\bf', num2str(k), '}'], 'FontSize', 5, 'BackgroundColor', 'y');
            end     


        end


        if show==1
            figure,
            figure,plot(siftInFixList);
            hold on;
            plot(fixInFixList,'--k');
            hold on
            plot(siftInSiftList,'--g');
            line([1 size(siftInFixList,1)],[threshold threshold]);
        end



        TP = size(find(siftGoodInFixList>=threshold));
        FN = size(find(siftGoodInFixList<threshold));
        TN = size(find(siftBadInFixList<threshold));
        FP = size(find(siftBadInFixList>=threshold));
        P = TP/(TP+FP);
        R = TP/(TP+FN);

        positives = size(siftGoodInFixList(:),1);
        negatives = size(siftBadInFixList(:),1);

        disp([' TP: ',num2str(TP),' FN: ',num2str(FN),' ']);
        disp([' TN: ',num2str(TN),' FP: ',num2str(FP),' ']);
        disp([' precision: ',num2str(P),' recall: ',num2str(R),' ']);


        TPR = TP/positives;
        FPR = FP/negatives;

        F = 2*(P*R)/(P+R);
        %pause;
        %close all;

        P_list = [P_list P];
        R_List = [R_List R];

        F_List = [F_List F];

        roc_x = [roc_x TPR];
        roc_y = [roc_y FPR];
    end 
    
    avgTPR = mean( roc_x(:) );
    avgFPR = mean( roc_y(:) );
    
end

