
clear all;

%pt=8:18;
%et=3:13;

pt=10;%8:2:18;
et=5;%5:2:15;

figure;


mList=[];
for k=1:size(pt,2)
    
    mList=[];
    meas = globalDist_forMI_improved(pt(k),et(k));
    mList = [mList ; meas ];
    
    
    hold on;
    stem(mList);
end

%%

hold on;
v=mean(mList(:));
line(1:size(mList,1),v*ones(size(mList,1)))