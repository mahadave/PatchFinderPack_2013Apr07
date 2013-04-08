function [ x ] = SAD( curPatchDescriptors,curNeighbourDescriptors )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
x =0;
for e = 1 : size(curPatchDescriptors,1)
    for f = 1 : size(curPatchDescriptors,2)
    x = x + abs((curPatchDescriptors(e,f) - curNeighbourDescriptors(e,f))) ;
    end
end

end

