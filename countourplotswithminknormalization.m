%%personal startup

warning ('off','all')


%% the following section is to get all the intensity values from each channel into a csv file

% listConditions = {'Notch ON', 'Notch OFF'};
% 
% [indx,tf] = listdlg('ListString',listConditions);

%     if isequal('Notch ON', listConditions{indx});
% 
%         nameNotchstatus = "Notch";
%         notchstatus = "Notch";
% 
%     elseif isequal('Notch OFF', listConditions{indx});
%         nameNotchstatus = "LacZ";
%         notchstatus = "LacZ";
%         
%     end
% 
% 
% 
% listConditions = {'wRi', 'skdRi', 'ktoRi'};
% 
% [indx,tf] = listdlg('ListString',listConditions);
% 
%     if isequal('wRi', listConditions{indx});
% 
%         nameNotchstatus = "wRi"; % this one is for searching
%         notchstatus = "wRi";
% 
%     elseif isequal('skdRi', listConditions{indx});
%         nameNotchstatus = "skdRi";
%         notchstatus = "skdRi";
%         
%     elseif isequal('ktoRi', listConditions{indx});
%         nameNotchstatus = "ktoRi";
%         notchstatus = "ktoRi";
%         
%     end
% 

% listMolecules = csvread("/Users/fjavierdha/Documents/MATLAB/TaggedMols.csv");
nameofmolofinterest = 'Su(H)GFP';
nameofloctag = "loctag ";
ChannelofInterest = 1;


%% getting the folder

path = uigetdir()


ChannelofInterest = 1;
blue = [0 0.5 1];
red = [1 0.2 0.2];
green = [0.11 0.7 0.32];
orange = [1 0.58 0.01];
purple = [0.74 0.01 1];

listConditions = {'wRi', 'skdRi', 'ktoRi', 'cdk8Ri' };
listColor = cat(1, green, red, blue, orange, purple);


for a = 1:(length(listConditions))

    nameNotchstatus = listConditions{a};
    notchstatus = listConditions{a}

parentdirectory = dir(append(path, '/*', nameNotchstatus, '*'));


BackgroundMolofIinterest = [];
MolofInterest = []; 
PixelSize = [];


for t = 1:length({parentdirectory.name}) %this loop will go over every folder that has the name nameNotchstatus on it
    
    disp(parentdirectory(t).name);
    
    CSVDirectory = dir(append(parentdirectory(t).folder, "/", parentdirectory(t).name, '/*.csv'));
       
    CSVDirectoryfullpath = [];
    
    for u = 1:length(CSVDirectory);
        
        CSVDirectoryfullpath = [CSVDirectoryfullpath, append(CSVDirectory(u).folder, "/", CSVDirectory(u).name)];
    
    end


    for n = 1:length(CSVDirectoryfullpath);
       
        if isequal("colorn1", regexp(CSVDirectoryfullpath{n},'colorn1', 'match'));   %avoid the colorn1 files

        else
            if isempty(PixelSize)
                SomeIntensity = readtable(CSVDirectoryfullpath{n});
                PixelSize = SomeIntensity{end, 1} / length( SomeIntensity{:, 1});
            else
            end
       end
      
    end
  
      
end



for t = 1:length({parentdirectory.name}) %this loop will go over every folder that has the name nameNotchstatus on it
    
    disp(parentdirectory(t).name);
    
    MATDirectory = dir(append(parentdirectory(t).folder, "/", parentdirectory(t).name, '/*.mat'));
       
    MATDirectoryfullpath = [];
    
    for u = 1:length(MATDirectory);
        
        MATDirectoryfullpath = [MATDirectoryfullpath, append(MATDirectory(u).folder, "/", MATDirectory(u).name)];
    
    end


    for n = 1:length(MATDirectoryfullpath);
       
        if isequal("all series", regexp(MATDirectoryfullpath{n},'all series', 'match'))  
            
        else
            
            
          MolofInterestImage  = load(MATDirectoryfullpath{n})
           
          if isempty(MolofInterest)
              
              MolofInterest = MolofInterestImage.IntensityROI(:,:,1,ChannelofInterest);
              
          else
              MolofInterest(:,:,length(MolofInterest(1,1,:))+1) = MolofInterestImage.IntensityROI(:,:,1,ChannelofInterest);
          end
          
        end
      
    end

end

NormMolofInterest = [];

for r = 1:size(MolofInterest, 3)
    
    NormMolofInterest(:,:,r) = (MolofInterest(:,:,r)  ./ mean(mink(mean(MolofInterest(:,:,r)), 6), 'omitnan'));
    
end

figure('Name', notchstatus, 'Position', [0 0 900 235]);
Yaxislastvalue = PixelSize .* length(MolofInterest(:,1,1));
Xaxislastvalue = PixelSize .* length(MolofInterest(1,:,1));

tl = tiledlayout(1, 2,'TileSpacing','Compact');


title(tl, append('Intensity of ', nameofmolofinterest, ' in ',  nameNotchstatus));
ylabel(tl, 'distance (um)');
xlabel(tl, 'distance (um)');
colormap(parula);

    nexttile
    imagesc([PixelSize:PixelSize:Xaxislastvalue],  [PixelSize:PixelSize:Yaxislastvalue], mean(MolofInterest, 3, 'omitnan'));
    caxis([1, 256]);
    title('Image of the mean intensity');
    colorbar;
 axis equal

    
    nexttile;
    imagesc([PixelSize:PixelSize:Xaxislastvalue],  [PixelSize:PixelSize:Yaxislastvalue], mean(NormMolofInterest, 3, 'omitnan'));
    caxis([0, 12]);
    title('Image of the mean fold change');
colorbar;

axis equal
    
 %% saving the plot

orient(gcf,'landscape');

saveas(gcf, append(path, "/", 'Mam GFP intensity in NDECD and ', nameNotchstatus, '.pdf'));

end