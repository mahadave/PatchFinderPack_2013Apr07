function [f , d] = produceSiftPoints(image,peakThreshold,edgeThreshold)
% This function uses the vl_sift method to produce the sift points
% Inputs : 
%   image - image for which sift frames and descriptors are computed
%   edgeThreshold - edge threshold for the sift algorithm edge detection 
%   PeakThreshold - peak threshold for the sift algorithm peak detection
%
% Outputs :
%   f - sift frames (keypoints)
%   d - sift descriptors

    [f ,d]= vl_sift(single(image),'PeakThresh', peakThreshold,'edgethresh',edgeThreshold);
    
end