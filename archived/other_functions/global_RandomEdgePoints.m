
clear all;
close all;

disp('starting...');
%clear all
%close all
clc


%decide number of files to run for
%lowerLim=1; %replace with 1 for starting file
folder = '../ALLSTIMULI';
files = dir(strcat(folder, '/*.jpeg'));
lowerLim=1;
upperLim=length(files); %replace with length(files) for last file

%%


mList=[];
for k=lowerLim:upperLim
    
    meas = globalDist_randomEdgePts(k);
    mList = [mList ; meas];
    
    
end


%%

stem(mList);
hold on;
v=mean(mList(:));
line(1:size(mList,1),v*ones(size(mList,1)))