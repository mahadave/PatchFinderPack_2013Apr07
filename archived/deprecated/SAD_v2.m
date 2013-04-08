function [ x ] = SAD_v2( curPatchDescriptors,curNeighbourDescriptors )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
x =0;
 if(size(curNeighbourDescriptors,1)*size(curNeighbourDescriptors,2) < 25)
   x = abs(curPatchDescriptors(:));
 elseif(size(curPatchDescriptors,1)*size(curPatchDescriptors,2) < 25)
   x = abs(curNeighbourDescriptors(:));
 else
    curNeighbourDescriptors = imresize(curNeighbourDescriptors,size(curPatchDescriptors)); % is this fine??
    x = abs(curPatchDescriptors(:) - curNeighbourDescriptors(:));
    
end
x = sum(x(:));
end

