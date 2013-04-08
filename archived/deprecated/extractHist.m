function [ histVector] = extractHist(testFisherVector,NBins)

histVector = testFisherVector(:,1300-(NBins-1):1300);

end