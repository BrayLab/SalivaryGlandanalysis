
%%personal startup
mkdir('/Users/fjavierdha/Documents/MATLAB');

warning ('off','all')


Path = uigetdir()  %set the parent folder that contains the folders with the lifs files

Parentdirectory = dir(Path);

Listdirectory = [];
    
for t = 1:length({Parentdirectory.name}) %this loop is to get the folder that will contain many folders at the same time with the diffrent replicates
    
    Listdirectory = [Listdirectory, dir(append(Parentdirectory(t).folder, "/", Parentdirectory(t).name, '/*.lif'))];
        
    directoryonlycsv = {};
    
end

for v = 1:length({Listdirectory.name}) % this loop will go over every lif file in the Lisdirectory


LifLocString = convertStringsToChars(append(Listdirectory(v).folder, "/", Listdirectory(v).name));

% ischar(LifLocString); 

Reader = bfGetReader(LifLocString);
    seriesMetadata = Reader.getSeriesMetadata(); 
    omeMeta = Reader.getMetadataStore();
    Info = strsplit(char(omeMeta.dumpXML()),' ')';
    

Image = bfopen(LifLocString);

    for s = 1:length(Image) % this loop will go over every series on the v lif file
        % build the 3D matrix for each series
        % we are workinnng with images that have c channels and z stacks, but no time series
        Channels = str2double(extractBefore(extractAfter(Image{s, 1}{1,2}, "C=1/"),2)); %this will extract the first character after "C=1/"
        Stacks = str2double(extractBefore(extractAfter(Image{s, 1}{1,2}, "Z=1/"), "; C=1")); %
        
        
        SeriesMetadata= split(char(Image{s, 2}),", "); %the metadata string can be divided as there is a delimiter 
        
        PhysicalSizePixel = str2num(extractBefore(extractAfter(FindInMetadata(Info, 'PhysicalSizeX'), '"'), '"'));
        SeriesName = FindInMetadata(SeriesMetadata, 'Image name=');
        
        %checking if the zoom that was applied was 4.5 to every image.
        %Set the zoom for the images, the same scale is necessary to average them
        
        if (round(str2num(extractAfter(SeriesMetadata{140, 1}, "ATLConfocalSettingDefinition|Zoom=")),1) ~= 4.5 );
            error(strcat("The series ", SeriesMetadata{249, 1}  , " in the image ", Listdirectory(1).name , " has a zoom different to 4.5. This might affect the scale of the plot"));
        end
        
        
        ImageMatrix = [];
        
        PhysicalSizePixel = str2num(extractBefore(extractAfter(FindInMetadata(Info, 'PhysicalSizeX'), '"'), '"'));
        SeriesName = FindInMetadata(SeriesMetadata, 'Image name=');
        
   
        
        for y  = 0:Stacks - 1 %channnel 1 
            ImageMatrix(:,:, (y+1), 1) = Image{s, 1}{(Channels*y + 1),1};
        end
        
        for a  = 0:Stacks - 1 %channnel 2
            ImageMatrix(:,:, (a+1), 2) = Image{s, 1}{(Channels*a + 2),1};
        end
        
       if Channels > 2
         for b = 0:Stacks - 1 %channnel 3
            ImageMatrix(:,:, (b+1), 3) = Image{s, 1}{(Channels*b + 3),1};
         end
       end
       
       ROIdim = [100,100,90,40];
       
%         imagesc(ImageMatrix(:,:,7, 2))
%         StackofInterest = 7
%         AngleofInterest = -35
%         
%         ImageMatrix = imrotate(ImageMatrix, AngleofInterest, 'nearest', 'crop');
        
%         imagesc(ImageMatrix(:,:,7, 2));
        

%         Roi = drawrectangle('Position',ROIdim, 'LineWidth', 1);
%         wait(Roi); %this function will stop the script until the selected ROI is double clicked
        
        
%         StartROI = round(Roi.Position(1,1:2), 0); %where the specified ROI starts, rounded to the nearest integer
%         SizeROI = round(Roi.Position(1,3:4), 0); %the size of the ROI, it should always be 60 by 20, a the ROI should only be moved
%         
        %extract the intensity values and save them as a roimatrix in the folder build a matrix that can be
        %exported to a csv file
        
        IntensityROI = ExportIntensityROI;
        
        save(append(LifLocString, ' series ', string(s), ' ROIMatrix.mat'), 'IntensityROI'); % the save function allows saving variables. They have to be writen as scalars on the second argument
        
%         Test = load(append(LifLocString, ' series ', string(s), ' ROIMatrix.mat'))
%         imagesc(Test.IntensityROI(:,:,:,1))
        
        MeanChannel1 = mean(IntensityROI(:,:,:,1), 1); %the second argument is for making average of the columns, the end is one vector (row)
%         plot(MeanChannel1)
        
        MeanChannel2 = mean(IntensityROI(:,:,:,2), 1); %the second argument is for making average of the columns, the end is one vector (row)
%         plot(MeanChannel2)
        
        if Channels > 2
             MeanChannel3 = mean(IntensityROI(:,:,:,3), 1); %the second argument is for making average of the columns, the end is one vector (row)
%              plot(MeanChannel3)
         end
        
        
       
        
        %now that we have a vector for the mean of this series, we will
        %access the metadata to access a distance. The information we need
        %is how long each pixel is in terms of distance
        
        %we have used the "crop" method for rotating the image, so the
        %scale of the image doesnt change; independently of the rotation
        %angle. If the image had been rotated with another method, the
        %scale would need to be changed for each of the rotations
        
        %the variable Info is being used to access the metadata, which has information about the
        %whole lif, it will propably refer to the first series. As we have
        %setup the error message, the scale should be the same for all the
        %series and if they aren't; it will give back an error message
        
%         is = find(ismember(Info,'PhysicalSizeX=')) %this is to find that
%         string, but the cell that contains that string also contains
%         other characters, so it wont return anything
        
        extractInfo(Info, 'PhysicalSizeX')
        
        cellfun(@regexp(Info{333},'PhysicalSizeX')
     
       
        MeanvalueswithdistanceChannel1 = [];
        MeanvalueswithdistanceChannel1(:,2) = MeanChannel1;
        MeanvalueswithdistanceChannel1(:,1) = PhysicalSizePixel * (0:(length(MeanChannel1)-1));
        
        
        MeanvalueswithdistanceChannel2 = [];
        MeanvalueswithdistanceChannel2(:,2) = MeanChannel2;
        MeanvalueswithdistanceChannel2(:,1) = PhysicalSizePixel * (0:(length(MeanChannel2)-1));
        
        
        MeanvalueswithdistanceMolofInteresttable = array2table(MeanvalueswithdistanceChannel1, 'VariableNames', {'Distance_(microns)', 'Gray_Value'});
        writetable(MeanvalueswithdistanceMolofInteresttable, strcat(LifLocString, ' - ', SeriesName,' - color1.csv') );
        imwrite(uint8(rotatedChannel1), strcat(LifLocString, ' - ', SeriesName,' - channel1.tif'));
        
        MeanvalueswithdistanceLoctagtable = array2table(MeanvalueswithdistanceChannel2, 'VariableNames', {'Distance_(microns)', 'Gray_Value'});
        writetable(MeanvalueswithdistanceLoctagtable, strcat(LifLocString, ' - ', SeriesName,' - color2.csv') );
        imwrite(uint8(rotatedChannel2), strcat(LifLocString, ' - ', SeriesName,' - channel2.tif'));
        
        
        
        
    end

end

