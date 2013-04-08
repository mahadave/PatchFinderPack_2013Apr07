close all
clc
clear all;

%pt=8:18;
%et=3:13;


    disp('starting...');

    installSift();


  folder = '../ALLSTIMULI';
  files = dir(strcat(folder, '/*.jpeg'));

    
    
    %decide number of files to run for
    lowerLim=1; %replace with 1 for starting file
    upperLim=1;%length(files);%lowerLim+10; %replace with length(files) for last file



%%


fraction=0.01:0.025:1;

figure;

mList=[];
avgMList=[];


for k=1:size(fraction,2)
    
    x=fraction(k);
    for i = lowerLim:upperLim
    
    
        disp(['running for (x) = (',num2str(x),')'])
        [TPR , FPR] = localDist_forROC_improved(x,i);
        disp(['running for (TPR,FPR) = (',num2str(TPR),',',num2str(FPR),')'])
        mList = [mList ; [TPR , FPR]];
    end
    
    
    %avgMList = [avgMList; mList];
    %clf;
    %stem(mList(:,2),mList(:,1));
    
end

%%



xlabel('FPR');
ylabel('TPR');
title('ROC');
hold on
g=(mList(:,1));
h=(mList(:,2));
stem(h,g,'LineStyle','none');
%plot(0:max(g),0:max(g));
%axis([0 1 0 1]);

