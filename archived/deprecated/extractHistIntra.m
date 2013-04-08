function [ histVector] = extractHistIntra(testFisherVector,NBins)

histVector = testFisherVector(:,end-(NBins-1):end);

end