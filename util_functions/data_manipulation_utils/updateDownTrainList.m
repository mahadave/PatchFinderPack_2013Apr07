function downTrainList = updateDownTrainList(f,N,negTrainList)

	f_p = [];
	f_n = [];
	temp = [];
	temp2 = [];
	downTrainList = [];

	posIndices = find (f >= 0);
	f_p = [f(posIndices) posIndices];

	negIndices = find (f < 0);
	f_n = [f(negIndices) negIndices];

	f_p = sortrows(f_p);
	f_n = sortrows(f_n);

	if (size(f_p,1)<N)
		 temp = negTrainList(f_p(:,2),:);
		 s = N - size(temp,1);
		 downTrainList = [temp ; negTrainList(f_n(end - (s-1): end,2),:)];
	else
		downTrainList = negTrainList(f_p(end-(N-1):end,2),:);
    end


end