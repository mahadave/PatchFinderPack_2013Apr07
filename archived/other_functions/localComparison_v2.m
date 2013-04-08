function [mList]=localComparison(patchInfo,limits)

fraction=0.1:0.02:1; %vary threshold
lowerLim=limits(1);
upperLim=limits(2);
show=0;
mList=[];
rr=[];
for k=1:size(fraction,2)
    
    splitPercent=fraction(k);
    disp(['running for (x) = (',num2str(splitPercent),')'])
    
    disp('starting...');
    
    
    
    P_list =[]; roc_y=[];
    R_List =[]; roc_x=[]; F_List =[];
    %run for many images
    for imgIndex = lowerLim:upperLim
        
        
        siftInSiftList=[];
        sListIndices=[];
        siftAugList=[];
        %extract SIFT points, FIX points and the resp KDEs
        Sifted=patchInfo(imgIndex).predictedFixPtList;
        Fixed=patchInfo(imgIndex).FixPtList;
        densitySift=patchInfo(imgIndex).predictedFixKDE;
        densityFix=patchInfo(imgIndex).realFixKDE;
        
        %Fixed = [Fixed(:,2) Fixed(:,1)];
        disp('dSift');
        disp(Sifted)
        disp('dFix');
        disp(round(Fixed))
        
        
        %         disp(size(Sifted))  ;
        %         disp(size(Fixed))  ;
        %         disp(size(densitySift))  ;
        %         disp(size(densityFix))  ;
        
        for i=1:size(Sifted,1)
            y = round(Sifted(i,1));
            x = round(Sifted(i,2));
            siftInSiftList = [siftInSiftList ; densitySift(x,y)];%self-explanatory, find probabilty of SIFT point being SIFT
            sListIndices = [sListIndices ; [y x]];
            siftAugList = [siftInSiftList sListIndices];
        end
        
        sortedSiftAugList=sortrows(siftAugList);
        
        fixInFixList=[];
        fListIndices =[];
        augList=[];
        for i=1:size(Fixed,1)
            y = round(Fixed(i,1));
            x = round(Fixed(i,2));
            fixInFixList = [fixInFixList ; densityFix(x,y)];%self-explanatory, find probabilty of FIX point being FIX
            fListIndices = [fListIndices ; [y x]];
            augList = [fixInFixList fListIndices];
        end
        
        sortedAugList=sortrows(augList);
        
        x=splitPercent; % percent split
        s = size(sortedAugList,1);
        i=round(x*(s));
        bottomX =[];
        topRem =[];
        if(size(sortedAugList,1)>0)
            bottomX = sortedAugList(1:i,:,:);   %put bottom probs of FIX in bottomX
            topRem = sortedAugList(i+1:end,:,:);%put top probs of FIX in topRem
        end
        
        
        s = size(sortedSiftAugList,1);
        i=round(x*(s));
        bottomXSift =[];
        topRemSift =[];
        if(size(sortedSiftAugList,1)>0)
            bottomXSift = sortedSiftAugList((1:i),2:3,:); %put bottom probs of SIFT in bottomX
            topRemSift = sortedSiftAugList((i+1):end,2:3,:);%put top probs of SIFT in topRem
        end
        
        %put good SIFT points in FIX KDE
        siftGoodInFixList=[];
        siftBadInFixList=[];
        for i=1:size(topRemSift,1)
            y = round(topRemSift(i,1));
            x = round(topRemSift(i,2));
            siftGoodInFixList = [siftGoodInFixList ; densityFix(x,y)];
        end
        %put bad SIFT points in FIX KDE
        for i=1:size(bottomXSift,1)
            y = round(bottomXSift(i,1));
            x = round(bottomXSift(i,2));
            siftBadInFixList = [siftBadInFixList ; densityFix(x,y)];
        end
        
        
        size(bottomX)
        threshold = max(bottomX(:,1,:));
        
        
        TP = size(find(siftGoodInFixList>=threshold));
        FN = size(find(siftGoodInFixList<threshold));
        TN = size(find(siftBadInFixList<threshold));
        FP = size(find(siftBadInFixList>=threshold));
        P = TP/(TP+FP);
        R = TP/(TP+FN);
        
        positives = size(siftGoodInFixList(:),1);
        negatives = size(siftBadInFixList(:),1);
        
        disp([' TP: ',num2str(TP(:,1)),' FN: ',num2str(FN(:,1)),' ']);
        disp([' TN: ',num2str(TN(:,1)),' FP: ',num2str(FP(:,1)),' ']);
        disp([' precision: ',num2str(P),' recall: ',num2str(R),' ']);
        disp([' positives: ',num2str(positives), ' negatives: ',num2str(negatives)]);
        TPR = TP/positives;
        FPR = FP/negatives;
        roc_y = [roc_y TPR];
        roc_x = [roc_x FPR];
        
    end
    
    avgTPR = mean( roc_x(:) );
    avgFPR = mean( roc_y(:) );
    
    
    disp(['running for (avgTPR,avgFPR) = (',num2str(avgTPR),',',num2str(avgFPR),')'])
    mList = [mList ; [avgTPR , avgFPR]];
    %rr = [rr ; [roc_x roc_y]];
    
    
    
end

save(['final_sift_roc',num2str(splitPercent)],'mList');
%%
close all
figure;
%
clf;
stem(mList(:,2),mList(:,1),'LineStyle','none');

%plot(mList(:,2),mList(:,1));
figure;
%stem(rr(:,1),rr(:,2));

end