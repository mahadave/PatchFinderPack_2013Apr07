function patch_res = adjustPatch(patch)
% JUGAAD function - If a patch is smaller than the regular ones and is an
% edge patch, resize it so that self-sim does not complain 
% INPUT - patch (weird patch)
% OUTPUT - patch_res (square patch)
    [a b]=size(patch);
    if(a~=b)
       patch_res = imresize(patch,[max([a,b]) max([a,b])]);
    else
       patch_res = patch;
    end
 end
               