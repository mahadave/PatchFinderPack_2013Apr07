close all;
brayCurtis=[];
for imgIndex = 51:100 %change here
   [bcMeasure] = measureBCS(imgIndex);
    brayCurtis = [brayCurtis bcMeasure]; 
end