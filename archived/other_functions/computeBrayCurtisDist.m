function bcMeasure = computeBrayCurtisDist(densityFix,densitySift)

    diffList = abs(densityFix-densitySift);
    sumList = densityFix+densitySift;
    

    n = sum(diffList(:));
    d = sum(sumList(:));
    
    bcMeasure = n/d;
end