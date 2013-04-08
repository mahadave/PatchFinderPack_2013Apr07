close all
clc
clear all;

%pt=8:18;
%et=3:13;

pt=5:1:25;
et=5:1:25;

figure;

mList=[];
for k=1:size(pt,2)
    clc;
    p=pt(k);
    e=et(k);
    disp(['running for (pt,et) = (',num2str(p),',',num2str(e),')'])
	[avgTPR , avgFPR] = localDist_forROC(p,e);
    disp(['running for (avgTPR,avgFPR) = (',num2str(avgTPR),',',num2str(avgFPR),')'])
    mList = [mList ; [avgTPR , avgFPR]];
    
    clf;
    stem(mList(:,1),mList(:,2));
end


%%
close all
clc
clear all;

%pt=8:18;
%et=3:13;
fraction=0.01:0.05:1;

figure;

mList=[];
for k=1:size(fraction,2)
    x=fraction(k);
    disp(['running for (x) = (',num2str(x),')'])
	[avgTPR , avgFPR] = localDist_forROC(x);
    disp(['running for (avgTPR,avgFPR) = (',num2str(avgTPR),',',num2str(avgFPR),')'])
    mList = [mList ; [avgTPR , avgFPR]];
    
    
end

%%
clf;
    stem(mList(:,2),mList(:,1),'LineStyle','none');
%%


stem(mList(:,1),mList(:,2),'--rs');
hold on
g=(mList(:,1));
h=(mList(:,2));
plot(0:max(g),0:max(g));
%axis([0 1 0 1]);

