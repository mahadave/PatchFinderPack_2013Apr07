function [ rel, PCReduced ] = pca_own( A )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[n m] = size(A);
AMean = mean(A);
AStd = std(A);
B = (A - repmat(AMean,[n 1])) ./ repmat(AStd,[n 1]);
B(isnan(B))=0;
B(isinf(B))=0;
[V D] = eig(cov(B));

rel = cumsum(flipud(diag(D))) / sum(diag(D));
PC = B * V;

variance = var(PC);

VReduced = V(:,1230:end); % check rel and use the till the variance is 90%
PCReduced = B * VReduced;

dec = PCReduced * VReduced';
end

