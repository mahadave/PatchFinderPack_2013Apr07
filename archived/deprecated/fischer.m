%%This file runs the sift algorithm (http://www.vlfeat.org/overview/sift.html)
% and compares it with the fixation points
% obtained from tilke Judd's dataset
% (http://people.csail.mit.edu/tjudd//WherePeopleLook/index.html<http://peo
% ple.csail.mit.edu/tjudd/WherePeopleLook/index.html)

disp('starting...');
clear all
close all
clc
installSift();

%decide number of files to run for
lowerLim=11; %replace with 1 for starting file
upperLim=lowerLim+10; %replace with length(files) for last file

%%

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


%%
D=[];
indexList=[0 1];
close all

for i = lowerLim:upperLim
    
    filename = files(i).name;
    disp(filename);
    disp(i);
    % Get image
    
    image = readGray(folder, filename);
    disp(['opened : ',filename]);
    %figure;
    %imshow(image); 
    %hold on;

    %%sift computation
    
    peakThreshold=10;
    edgeThreshold=5;
    [f,d] = produceSiftPoints(image,peakThreshold,edgeThreshold);
    
    d=d';
    D = [D;d]; % store index along with the sift pts extracted
    
    indexList =[indexList; [i size(D,1)]];
    
end

D = double(D);


%%
    k=5;
    gmm = gmdistribution.fit((D), k, 'covtype','diagonal',...
                                            'regularize',1e-8);
    
%%
    L = indexList(:,2); % keeps track of ending position of each images sift
    fischers = [];
for i = 1:(numel(L)-1)%lowerLim:upperLim
    
    range=L(i):L(i+1);
    F = extract_fisher_vector(D(range,:), gmm); 
    fischers = [fischers ; F'];
end

    