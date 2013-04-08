function [pts]=getFixationPointsAcrossUsers(folderPath,filename,user)
% version : _v2 , based on Judd's function... search the data folder for
% the fixation data per user   

    % Get eyetracking data for this image
    datafolder=[folderPath user];
    datafile = strcat(filename(1:end-4), 'mat');
    load(fullfile(datafolder, datafile));
    stimFile = eval([datafile(1:end-4)]);
    eyeData = stimFile.DATA(1).eyeData;

    [eyeData Fix Sac] = checkFixations(eyeData);
    s=find(eyeData(:, 3)==2, 1)+1; % to avoid the first fixation
    eyeData=eyeData(s:end, :);

    fixs = find(eyeData(:,3)==0);      
    pts = Fix.medianXY; % store fixation point medians of current user 
        
end