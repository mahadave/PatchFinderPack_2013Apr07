function [d_all,indexList] = getTopGradPoints(patch,META,index,indexList)
            %%----- GET TOP X gradient points
            %%-----------------------------------------------------------------%%

            NPoints = META.NPoints;
            d_all = [];
            [FX,FY] = gradient(double(patch));
            u = (abs(FX/2) + abs(FY/2));
            [array] = makeArray_v2(size(patch,1),size(patch,2));
            
            ut = u'; ut = ut(:);
            linearArray = [ut array];
            linearArray = sortrows(linearArray);
            p = linearArray(end - (NPoints - 1) : end , : , :);%put last sorted N points of linear array in p

            indexList =[indexList; [index index+size(p,1)]]; % store end index of patch descriptors for cur image
            index = index + size(p,1) +1;

            p=p(:,2:3);  px = p(:,1); py=p(:,2);
            fc = [px py 10*ones(size(px,1),1) zeros(size(px,1),1)]'; % check if this is correct******
            [f,d] = vl_sift(single(patch),'frames',fc) ;
            d_all = [d_all; d'];
            
            

            
end