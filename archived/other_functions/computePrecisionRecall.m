function [p,r]=computePrecisionRecall(siftPoints,FixPoints,...
    centroid,numClusters,threshold)
% Computes the precision and recall by comparing
% the distance of each sift point from the cluster centroids
% Inputs: 
%   siftPoints - list of sift point coordinates obtained after the sift
%   algorithm
%   FixPoints - Fixation points found from Tilke Judd's dataset
%   centroid -  List of centroids of each cluster
%   numClusters - Number of clusters(k) of k-means
%   threshold - list of thresholds computer for each cluster
% Outputs:
%   p - precision
%   r - recall


    numGoodPoints =0;
    numSiftPoints=size(siftPoints,1);
    numFixPoints=size(FixPoints,1);
    for i=1:numSiftPoints;

        p = siftPoints(i,:); % take the i-th sift point
        for j=1:numClusters
            q = centroid(j,:);       
            dist= pdist([p;q]); % find its distance from the j-th cluster cetroid
    
            if(dist<=threshold(j))
               numGoodPoints = numGoodPoints + 1 ; % point qualifies if threshold met
               break;
            end
        end
    end

    p = numGoodPoints/numSiftPoints; % precision
    r = numGoodPoints/numFixPoints;

end