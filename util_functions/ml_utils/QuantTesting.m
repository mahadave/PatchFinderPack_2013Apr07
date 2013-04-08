function [p,n] = QuantTesting(testLabels,predictedLabelList)



% figure
% subplot 211 
% stem(predictedLabelList)
% title('predicted');
% subplot 212
% stem(testLabels)
% title('real')

a=0;
l=0;
l2=0;
p=0;
x=0;
for i = 1:numel(predictedLabelList)
    
    if(testLabels(i)==1)
        l=l+1;
        if(predictedLabelList(i)==1)
            a=a+1;
        end
    end
    
    if(testLabels(i)==-1)
        l2=l2+1;
        if(predictedLabelList(i)==-1)
            x=x+1;
        end
    end
end

p=a/l;
n=x/l2;
disp(['p = ',num2str(p),' , n = ',num2str(n)]);
% xlabel(['p = ',num2str(p),' , n = ',num2str(n)]);

