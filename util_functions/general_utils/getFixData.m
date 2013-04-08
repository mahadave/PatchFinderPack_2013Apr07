function [FixPoints] = getFixData(folderPath,filename,users)
% version : _v2 , based on Judd's function... search the data folder for
% the fixation data per user
    FixPoints =[];
    nu = length(users);
    for j = 1:nu % for all users find Fixation Points
            user = users{j};
            Pts = getFixationPointsAcrossUsers(folderPath,filename,user);
            FixPoints = [FixPoints ; Pts];
    end        
    
end