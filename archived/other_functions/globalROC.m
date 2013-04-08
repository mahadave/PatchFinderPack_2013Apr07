
clear all;

%pt=8:18;
%et=3:13;

pt=10;%8:2:18;
et=5;%5:2:15;

figure;

lowerLim=1:10:1000;


mList=[];
for k=1:numel(lowerLim)
    
    meas = globalDist_forROC(pt(k),et(k),loweLim);
    mList = [mList ; meas ];
    
    
    hold on;
    stem(mList);
end


%%

hold on;
v=mean(mList(:));
line(1:size(mList,1),v*ones(size(mList,1)))