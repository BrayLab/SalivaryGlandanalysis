%%personal startup
mkdir('/Users/fjavierdha/Documents/MATLAB')

warning ('off','all')


%% the following section is to get all the intensity values from each channel into a csv file

% 
% listConditions = {'Notch ON', 'Notch OFF'};
% 
% [indx,tf] = listdlg('ListString',listConditions);
% 
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



% listMolecules = csvread("/Users/fjavierdha/Documents/MATLAB/TaggedMols.csv");
nameofmolofinterest = 'MamGFP';
nameofloctag = "loctag ";



%% Accessing all the csv files






nameofmolofinterest = 'suh idr ct';
nameofloctag = "loctag ";
ChannelofInterest = 1;
blue = [0 0.5 1];
red = [1 0.2 0.2];
green = [0.11 0.7 0.32];
orange = [1 0.58 0.01];
purple = [0.74 0.01 1];

listConditions = {'lacZ', 'NDECD' };
listColor = cat(1, green, red, blue, purple);

path = uigetdir()


for a = 1:length(listConditions)

    nameNotchstatus = listConditions{a};
    notchstatus = listConditions{a}


parentdirectory = dir(append(path, '/*', nameNotchstatus, '*'));

MolofInterest = []; %make color 1 the molecule that is tagged
LocTag  = []; %make color 2 the loctag
NormMolofInterest = [];

for t = 1:length({parentdirectory.name}) %this loop will go over every folder that has the name nameNotchstatus on it
    
    disp(parentdirectory(t).name);
    
    CSVDirectory = dir(append(parentdirectory(t).folder, "/", parentdirectory(t).name, '/*.csv'));
       
    CSVDirectoryfullpath = [];
    
    for u = 1:length(CSVDirectory);
        
        CSVDirectoryfullpath = [CSVDirectoryfullpath, append(CSVDirectory(u).folder, "/", CSVDirectory(u).name)];
    
    end


    for n = 1:length(CSVDirectoryfullpath);
       
        if isequal("color1", regexp(CSVDirectoryfullpath{n},'color1', 'match')); %match arguement will regexp give the expression that matches

            nuclearmoleculeintensity = readtable(CSVDirectoryfullpath{n});

            MolofInterest = [MolofInterest, nuclearmoleculeintensity{:,2}];


        elseif isequal("color2", regexp(CSVDirectoryfullpath{n},'color2', 'match'));

            loctagintensity = readtable(CSVDirectoryfullpath{n});

            LocTag = [LocTag, loctagintensity{:,2}];

            spatialscale = loctagintensity{:, 1};


        elseif isequal("colorn1", regexp(CSVDirectoryfullpath{n},'colorn1', 'match'));   

            Normintensity = readmatrix(CSVDirectoryfullpath{n});
            
            NormMolofInterest = [NormMolofInterest, Normintensity]; % ".'" will transpose column into row
         
        else
            disp(append('There is a CSV file with no appropiate name in the folder', string(CSVDirectoryfullpath{n})))
        end
      
    end
  
    

   
end

    


FoldChangeMolofInterest = [];
    if length(NormMolofInterest) > 0 %the normalization depends on drawn circles in other regions

        for h = 1:length(MolofInterest(1,:));

            normcolumn = (MolofInterest(:, h) ./ NormMolofInterest(h)); 
            FoldChangeMolofInterest = [FoldChangeMolofInterest, normcolumn];

        end    
            
            
    elseif length(NormMolofInterest) < 1;
        
        for h = 1:length(LocTag(1,:));

            normcolumn = (MolofInterest(:, h) ./ mean(mink(MolofInterest(:, h), 6))); %this is doing the average of 6 minimum values within the rectangle
            FoldChangeMolofInterest = [FoldChangeMolofInterest, normcolumn];

        end
    else 
        display("There is an error with the normalization")
    end

    
    
 NormLocTag = [];

    for w = 1:length(LocTag(1,:));

        normcolumn = (LocTag(:, w) ./ mean(mink(LocTag(:, w), 6))); %this is doing the average of 6 minimum values within the rectangle
        NormLocTag = [NormLocTag, normcolumn];
    end
        





SEMmolofinterest = std(FoldChangeMolofInterest, 0, 2) ./ sqrt(size(FoldChangeMolofInterest, 2));
SEMloctag = std(NormLocTag, 0, 2) ./ sqrt(size(NormLocTag, 2));






% hold off;
% hold on;

title(append(nameofmolofinterest, ' intensity in ', notchstatus, ' conditions'), 'FontSize', 20)
xlim([0 max(spatialscale)]);
xlabel('Distance (um)', 'FontSize', 14);

yyaxis left;
ylim([0.8 1.4]);
ylabel(append('Normalised ', nameofmolofinterest, ' intensity'), 'FontSize', 14);

topcurve = (mean(FoldChangeMolofInterest, 2) + SEMmolofinterest).';
lowercurve = (mean(FoldChangeMolofInterest, 2) - SEMmolofinterest).';

pline1 = plot(spatialscale, mean(FoldChangeMolofInterest, 2), '-', 'DisplayName', nameofmolofinterest, color, listColor(a,:));

pfill1 = fill([spatialscale.' fliplr(spatialscale.')], [topcurve fliplr(lowercurve)], ...
              listColor(a,:), 'linestyle', 'none', 'FaceAlpha', .3, 'DisplayName', 'SEMmol');

% 
% yyaxis right;
% % s
% ylabel(append('Normalised ', nameofloctag, ' intensity'), 'FontSize', 14);
% 
% topcurve2 = (mean(NormLocTag, 2) + SEMloctag).';
% lowercurve2 = (mean(NormLocTag, 2) - SEMloctag).';
% 
% pline2 = plot(spatialscale, mean(NormLocTag, 2), '-r', 'DisplayName', nameofloctag);
% 
% pfill2 = fill([spatialscale.' fliplr(spatialscale.')], [topcurve2 fliplr(lowercurve2)], ...
%               [1 0.1 0.1], 'linestyle', 'none', 'FaceAlpha', .3, 'DisplayName', 'SEMloc');
% 
% 
% 
% legend([pline1,pline2], nameofmolofinterest, nameofloctag, ...
%        'FontSize', 14);






orient(gcf,'landscape');

saveas(gcf, append(path, "/", nameNotchstatus, nameofmolofinterest));

end
