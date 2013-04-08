function [newFeatVector] = normalizeFeatVectTest(featVector,scalingParams)
% use the scaling params found from test data
    scaling=[]; newFeatVector=[];
    NCols = size(featVector,2);
    for i=1:NCols
        curCol = featVector(:,i);
        mx = max(scalingParams(i,1));
        mn = min(scalingParams(i,2));
        delta = mx-mn;
        newCol = (curCol - mn) ./ delta;
        newFeatVector(:,i) = newCol;
        if(delta == 0)
            newFeatVector(:,i) = 0;
        end
    end
end