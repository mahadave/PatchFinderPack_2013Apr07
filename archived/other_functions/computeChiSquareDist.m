function chiMeasure = computeChiSquareDist(densityFix,densitySift)


    diffList = densityFix - densitySift;
    sumList = densityFix + densitySift;
    sqList = (diffList).*(diffList);
    chiList = (sqList)./(sumList);
    chiMeasure = sqrt(0.5*sum(chiList(:)));
    
end