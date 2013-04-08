function threshold = setThreshold(maxProb)

        f=0.2; % percentage of max for threshold
        threshold = f*maxProb;
        threshold = threshold/1;
end
