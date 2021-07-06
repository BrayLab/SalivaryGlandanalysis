
%%personal startup
mkdir('/Users/fjavierdha/Documents/MATLAB');

warning ('off','all')
Override = [];



%% option to override quantifications

listConditions = {'Check if quantifications have been done', 'Do not check if quantifications have been done'};

[indx,tf] = listdlg('ListString',listConditions);

    if isequal('Check if quantifications have been done', listConditions{indx});

        Override = [];

    elseif isequal('Do not check if quantifications have been done', listConditions{indx});
        
        Override = [1];
        
    end


%% choosing folder and opening mini app


Path = uigetdir()  %set the parent folder that contains the folders with the lifs files

Parentdirectory = dir(Path);

Listdirectory = [];
    
for t = 1:length({Parentdirectory.name}) %this loop is to get the folder that will contain many folders at the same time with the diffrent replicates
    
    if  Parentdirectory(t).name(1) == "." %this avoids all the folders that are part of the system and begin with ".", ie '.DS_Store'
    
    else   Listdirectory = [Listdirectory, dir(append(Parentdirectory(t).folder, "/", Parentdirectory(t).name, '/*.lif'))];
    
    end
%     directoryonlycsv = {};
    
end

for v = 1: length({Listdirectory.name}) % this loop will go over every lif file in the Lisdirectory


LifLocString = convertStringsToChars(append(Listdirectory(v).folder, "/", Listdirectory(v).name));

% ischar(LifLocString); 

Reader = bfGetReader(LifLocString);
    seriesMetadata = Reader.getSeriesMetadata(); 
    omeMeta = Reader.getMetadataStore();
    Info = strsplit(char(omeMeta.dumpXML()),' ')';
    

Image = bfopen(LifLocString);
IntensityROIsLIF = [];
MeansChannel1LIF = [];
MeansChannel2LIF = [];
BackgroundIntensity = [];    
    for s = 1:size(Image, 1) % this loop will go over every series on the v lif file
        % build the 3D matrix for each series
        % we are workinnng with images that have c channels and z stacks, but no time series
        Channels = str2double(extractBefore(extractAfter(Image{s, 1}{1,2}, "C=1/"),2)); %this will extract the first character after "C=1/"
        Stacks = str2double(extractBefore(extractAfter(Image{s, 1}{1,2}, "Z=1/"), "; C=1")); %
        
        
        SeriesMetadata= split(char(Image{s, 2}),", "); %the metadata string can be divided as there is a delimiter 
        
      
        %Extracting information from the metadata
        PhysicalSizePixel = str2num(extractBefore(extractAfter(FindInMetadata(Info, 'PhysicalSizeX'), '"'), '"'));
        SeriesName = FindInMetadata(SeriesMetadata, 'Image name=');
        SeriesZoom = FindInMetadata(SeriesMetadata, 'ATLConfocalSettingDefinition|Zoom=');
    
        CheckIfMatFile = [];
        
        if isempty(Override)
            try
                CheckIfMatFile = load(append(LifLocString, ' series ', SeriesName, ' ROIMatrix.mat'));
            end
        end 
        
        if isempty(CheckIfMatFile); %with this if we will check if there is a .mat file. If there isn't, the matrix will be read and the mini app will be generated
            
            %checking if the zoom that was applied was 4.5 to every image.
            %Set the zoom for the images, the same scale is necessary to average them


             if (str2num(SeriesZoom) ~= 4.5) == 0;
                error(strcat("The series ", SeriesName  , " in the image ", Listdirectory(1).name , " has a zoom different to 4.5. This might affect the scale of the plot"));
             end


            ImageMatrix = [];

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
           
            % this is for the script to wait until the app runs and turn this variable to true
           app = bandintensity(ImageMatrix, ROIdim);
           while isvalid(app); pause(0.1); end
           
%            saving the intensity ROI .m file

            IntensityROI = ExportIntensityROI;

            save(append(LifLocString, ' series ', SeriesName, ' ROIMatrix.mat'), 'IntensityROI'); % the save function allows saving variables. They have to be writen as scalars on the second argument
            
            BackgroundIntensity = [BackgroundIntensityExport, BackgroundIntensity];
            
%             saving the average intensity across the y axis of of the two
%             or three  channels for traditional plots

            MeanChannel1 = mean(IntensityROI(:,:,:,1), 1); %the second argument is for making average of the columns, the end is one vector (row)

            MeanChannel2 = mean(IntensityROI(:,:,:,2), 1); %the second argument is for making average of the columns, the end is one vector (row)

            if Channels > 2
                 MeanChannel3 = mean(IntensityROI(:,:,:,3), 1); %the second argument is for making average of the columns, the end is one vector (row)

             end



            MeanvalueswithdistanceChannel1 = [];
            MeanvalueswithdistanceChannel1(:,2) = MeanChannel1;
            MeanvalueswithdistanceChannel1(:,1) = PhysicalSizePixel * (0:(length(MeanChannel1)-1));


            MeanvalueswithdistanceChannel2 = [];
            MeanvalueswithdistanceChannel2(:,2) = MeanChannel2;
            MeanvalueswithdistanceChannel2(:,1) = PhysicalSizePixel * (0:(length(MeanChannel2)-1));


            MeanvalueswithdistanceMolofInteresttable = array2table(MeanvalueswithdistanceChannel1, 'VariableNames', {'Distance_(microns)', 'Gray_Value'});
            writetable(MeanvalueswithdistanceMolofInteresttable, strcat(LifLocString, ' - ', SeriesName,' - color1.csv') );
            
            MeanvalueswithdistanceLoctagtable = array2table(MeanvalueswithdistanceChannel2, 'VariableNames', {'Distance_(microns)', 'Gray_Value'});
            writetable(MeanvalueswithdistanceLoctagtable, strcat(LifLocString, ' - ', SeriesName,' - color2.csv') );
            
        
        else %this part will be run if there already is a .mat file, which means that there will it already has been quantified and 
            
           IntensityROIstructure =  load(append(LifLocString, ' series ', SeriesName, ' ROIMatrix.mat'), 'IntensityROI'); %there is no way for load to extract data into a double array, only into a structure array if it comes from a .mat file
           IntensityROI = IntensityROIstructure.IntensityROI;
           MeanvalueswithdistanceChannel1 = table2array(readtable(strcat(LifLocString, ' - ', SeriesName,' - color1.csv')));
           MeanvalueswithdistanceChannel2 = table2array(readtable(strcat(LifLocString, ' - ', SeriesName,' - color2.csv')));
           
        end
        
        %this will accumulate in the variables all the imagesROIs and Means
        % from the different series
    IntensityROIsLIF(:, :,  :, s) = IntensityROI;
    MeansChannel1LIF(:, 1) = MeanvalueswithdistanceChannel1(:, 1);
    MeansChannel2LIF(:, 1) = MeanvalueswithdistanceChannel2(:, 1);
    
    MeansChannel1LIF = [MeansChannel1LIF, MeanvalueswithdistanceChannel1(:, 2)];
    MeansChannel2LIF = [MeansChannel2LIF, MeanvalueswithdistanceChannel2(:, 2)];
    end
    
    % now we write the files 
 save(append(LifLocString, ' all series ', ' ROIMatrix.mat'), 'IntensityROIsLIF');   
 writematrix(MeansChannel1LIF, strcat(LifLocString, ' all series ',' - color 1.csv'));
 writematrix(MeansChannel2LIF, strcat(LifLocString, ' all series ',' - color 2.csv'));
 writematrix(BackgroundIntensity, strcat(LifLocString, ' all series ',' - colorn1.csv'));
 
end
