function boxSize  = getPatchSize(resized_image,probThreshold,densityFix)

countOnes=0;
boxSize=16; % starting value

% figure, imshow(resized_image);

        while(countOnes==0 && boxSize>0)
            for i=1:2*boxSize:(size(resized_image,2))
                for j=1:2*boxSize:(size(resized_image,1))
                    
                    upperX = i+2*boxSize-1;
                    lowerX=i;     lowerY=j;
                    upperY=j+2*boxSize-1;
                    
%                     
%                     disp([lowerX lowerY upperX upperY]);
                    [MX MY]=size(resized_image);
                    if(upperY>MY)
%                         disp('here');
                        upperY = MY;
                    end
                    if(upperX>MX)
%                         disp('here2')
                        upperX=MX;
                    end
%                     disp('corrected')
%                     disp(size(resized_image))
%                     disp('dFix')
%                     disp(size(densityFix))
  %                  rectangle('Position',[lowerX lowerY 2*boxSize 2*boxSize],'LineWidth',2,'LineStyle','--');
%                     disp([lowerX lowerY upperX upperY]);
                    %-- determine patch from image
                    patch = resized_image(lowerX:upperX,:);
                    patch = resized_image(:,lowerY:upperY);
                    patchDensity = densityFix(lowerX:upperX,lowerY:upperY);
                    meanDensity = mean(patchDensity(:));
    
                    if(meanDensity>=probThreshold)
                        countOnes = countOnes+1;
                        label = 1;
                    else
                        label =-1;
                    end
                end
            end
            boxSize=boxSize/2; % half box size for concentrated fixation distribution -- keep halving till size =1
        end
        
        boxSize = boxSize*2;
        
end