
clear all;

%pt=8:18;
%et=3:13;

pt=10;
et=5;

disp('starting...');
%clear all
%close all
clc

installSift();

%decide number of files to run for
%lowerLim=1; %replace with 1 for starting file
folder = '../ALLSTIMULI';
files = dir(strcat(folder, '/*.jpeg'));
lowerLim=1;
upperLim=10;%length(files); %replace with length(files) for last file

%%


mList=[];
for k=lowerLim:upperLim
    
    meas = globalDist_KLD(pt,et,k);
    mList = [mList ; meas];
    
    
end


%%
figure;
stem(mList);
hold on;
v=mean(mList(:));
line(1:size(mList,1),v*ones(size(mList,1)))