function [M,N] = getMN(posTrainList,negTrainList,fr)


	M = size(negTrainList,1);
	N = uint16(round(fr * (size(posTrainList,1))));
    
end