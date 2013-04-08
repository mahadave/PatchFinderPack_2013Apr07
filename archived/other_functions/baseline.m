clc
startUp();
clear all;
[folder,files,users,color] =setDirs();
showSettings();
%%
trainingLimits = [1 248];
[imageInfo] = extractDescriptorAndLabels(trainingLimits);
save('baseData6','imageInfo');
%%
