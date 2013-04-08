function [imageInfo] = extractDescriptorAndLabels(trainingLimits)

    [folder,files,users,color] =setDirs();
    [show, boxShow]= showSettings();
    %[NPoints]=setNPoints();
    lowerLim = trainingLimits(1);
    upperLim = trainingLimits(2);
    d_all = [];
    px = [];
    py = [];
    
    for imgIndex = lowerLim:upperLim

        filename = files(imgIndex).name;
        disp(['index:',num2str(imgIndex),' - file:',filename]);
        % Get image
        image = readGray(folder, filename);
        
        FixPoints = getFixData(users,filename);
        FixPoints = FixPoints(find(FixPoints(:,1)>0 & FixPoints(:,2)>0  & FixPoints(:,1)<size(image,1) & FixPoints(:,2)<size(image,2)),:);
        
        [Fixed,resized_image] = rescaleData(FixPoints,image);
    
        Fixed = uint16(round(Fixed));
        
        Lx = size(resized_image,1);
        Ly = size(resized_image,2);
        
        mat=[];
        
        for i=1:Lx
            mat = [mat ; [ones(Ly,1)*i [1:Ly]']] ;
        end
        
        allPoints=mat;

        px = mat(:,1); py = mat(:,2);
        
        fc = [px py 10*ones(size(px,1),1) zeros(size(px,1),1)]';
        
        [f,d] = vl_sift(single(resized_image),'frames',fc);
        d_all = [d_all; d'];
%             

        labels = 1;
        augList = [allPoints -1*ones(size(allPoints,1),1)]; % stores point , label
        for ix = 1:size(mat,1) 
            if(~isempty( intersect(mat(ix,:), Fixed,'rows')))
                augList(ix,3)=+1;
            end
        end
%         imageInfo(imgIndex).allPoints = mat;
%         imageInfo(imgIndex).fixPoints = Fixed;
%         imageInfo(imgIndex).nonFixPoints = setdiff(mat,Fixed,'rows');
        imageInfo(imgIndex).augList = augList;
        imageInfo(imgIndex).descriptors = d';
    
        
    end
        
    
         
    end