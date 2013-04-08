%% extracts Fisher Kernel vector from a bag of instances using an already trained universal GMM model
% + X is MxD matrix. M is the number of instances. 
% + GMM is a Gaussian mixture model trained using matlab's gmdistribution.fit. The commented line below is an example off building a GMM model for all training
% samples with allfeatures being an N x D matrix (i.e. observations are in the rows and the feature dimensions are in the columns)
% >> gmm = gmdistribution.fit(allfeatures, num_components, 'covtype','diagonal', 'regularize',1e-8);
% 
% + There are two normalizations in the fisher code: L2 and power. They helped me but they don't have to in your case. Try turning them off and on. 

function F = extract_fisher_vector(X, gmm, l2normalize)
if ~strcmp(gmm.CovType,'diagonal')
    error('Only diagonal covariance GMMs are supported.');
end

if nargin<3
    l2normalize = true;
end

% compute posteriors for each point
P = posterior(gmm, X);

Fmu = zeros(gmm.NDimensions, gmm.NComponents);
Fsigma = zeros(size(Fmu));

for c=1:gmm.NComponents
    shiftedX = bsxfun(@minus, X, gmm.mu(c,:));    
    Fmu(:,c) = (1/sqrt(gmm.PComponents(c)))*(shiftedX'*P(:,c))./sqrt(gmm.Sigma(:,:,c))';    
    Fsigma(:,c) = (1/sqrt(2*gmm.PComponents(c)))*(((shiftedX.^2)'*P(:,c))./gmm.Sigma(:,:,c)'-sum(P(:,c)));
end

% concatenate the features for each parameter
F = [Fmu(:) ; Fsigma(:)];
F = F/size(X,1);

% power normalize
F = sign(F).*abs(F).^0.5;
if l2normalize
    F = F/norm(F);
end

end