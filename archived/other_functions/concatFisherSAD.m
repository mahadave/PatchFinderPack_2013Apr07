function [ newFeatVector] = concatFisherSAD(fishers, patchInfo)
    
	histList = [];
	N = numel(patchInfo);
	for i=1:N
            
            cur = patchInfo(i).patchData;
            tmp=[];
            for j=1:numel(cur)
                tmp = [tmp ; cur(j).intraPatchHist];
            end
            
            histList = [histList ; [patchInfo(i).interPatchHist tmp] ];
    end
    
    
	
	% check here if disp(numel(histList) == numel(fishers))
    newFeatVector = [];
    for i=1:size(fishers,1)
%  		size(fishers(i,:))
%         size(histList(i,:))
        newFeatVector = [newFeatVector ; [fishers(i,:) histList(i,:)]];
	end

end