
clear all;

%pt=8:18;
%et=3:13;

pt=10;%8:2:18;
et=5;%5:2:15;

disp('starting...');
%clear all
%close all
clc
installSift();

%decide number of files to run for
%lowerLim=1; %replace with 1 for starting file
folder = '../ALLSTIMULI';
files = dir(strcat(folder, '/*.jpeg'));
lowerLim=1003;
upperLim=length(files); %replace with length(files) for last file

%%


mList=[];
for k=lowerLim:upperLim
    
    meas = globalDist_forROC_improved(pt,et,k);
    mList = [mList ; meas];
    
    
end


%%

stem(mList);
hold on;
v=mean(mList(:));
line(1:size(mList,1),v*ones(size(mList,1)))