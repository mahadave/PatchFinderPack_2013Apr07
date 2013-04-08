i=double(imread('index02.jpg'));
i = imresize(i, [16 16])

parms.size=3;
parms.coRelWindowRadius=4;
parms.numRadiiIntervals=2;
parms.numThetaIntervals=4;
parms.varNoise=25*3*36;
parms.autoVarRadius=1;
parms.saliencyThresh=0; % I usually disable saliency checking
parms.nChannels=size(i,3);

radius=(parms.size-1)/2; % the radius of the patch
marg=radius+parms.coRelWindowRadius;

% Compute descriptor at every 5 pixels seperation in both X and Y directions
[allXCoords,allYCoords]=meshgrid([marg+1:3:size(i,2)-marg],...
                                 [marg+1:3:size(i,1)-marg]);

allXCoords=allXCoords(:)';
allYCoords=allYCoords(:)';

fprintf('Computing self similarity descriptors\n');
[resp,drawCoords,salientCoords,uniformCoords]=ssimDescriptor(i ,parms ,allXCoords ,allYCoords);
fprintf('Descriptor computation done\n');

size(resp)