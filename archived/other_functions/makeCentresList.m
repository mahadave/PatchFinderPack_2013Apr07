function outList = makeCentresList(inList)

    x = inList(:,1);
    y = inList(:,2);
    freq = uint8(inList(:,3)*500); % scaling by 100
    
    outList=[];
    for i=1:numel(x)
        tuple = [x(i) y(i)];
        append = repmat(tuple,freq(i),1);
        outList = [outList;append];        
    end
    
end