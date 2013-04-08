function [FixPoints] = getFixData_v2(folderPath,filename,users)

    FixPoints =[];
    nu = length(users);
    for j = 1:nu % for all users find Fixation Points
            user = users{j};
            Pts = getFixationPointsAcrossUsers_v2(folderPath,filename,user);
            FixPoints = [FixPoints ; Pts];
    end        
    
end