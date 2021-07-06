%%personal startup
mkdir('/Users/fjavierdha/Documents/MATLAB')

warning ('off','all')

f = filesep

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



path = uigetdir()

nameofmolofinterest = 'suh ct IDR';
nameofloctag = "loctag ";
ChannelofInterest = 2;
blue = [0 0.5 1];
red = [1 0.2 0.2];
green = [0.11 0.7 0.32];
orange = [1 0.58 0.01];
purple = [0.74 0.01 1];

listConditions = { 'lacZ', 'NDECD',};
listColor = cat(1, green, red,purple);


for a = 1:(length(listConditions))

    nameNotchstatus = listConditions{a};
    notchstatus = listConditions{a}


parentdirectory = dir(append(path, f, '*', nameNotchstatus, '*'));

MolofInterest = []; %make color 1 the molecule that is tagged
LocTag  = []; %make color 2 the loctag
NormMolofInterest = [];

for t = 1:length({parentdirectory.name}) %this loop will go over every folder that has the name nameNotchstatus on it
    
    disp(parentdirectory(t).name);
    
    CSVDirectory = dir(append(parentdirectory(t).folder, f, parentdirectory(t).name, f, '*.csv'));
       
    CSVDirectoryfullpath = [];
    
    for u = 1:length(CSVDirectory);
        
        CSVDirectoryfullpath =  [CSVDirectoryfullpath, cellstr(append(CSVDirectory(u).folder, f, CSVDirectory(u).name))];
    
    end
    


    for n = 1:length(CSVDirectoryfullpath);
       
        if isequal("color1", regexp(CSVDirectoryfullpath{n},'color1', 'match')); %match arguement will regexp give the expression that matches

            nuclearmoleculeintensity = readtable(CSVDirectoryfullpath{n});

            MolofInterest = [MolofInterest, nuclearmoleculeintensity{:,2}];


%         elseif isequal("color2", regexp(CSVDirectoryfullpath{n},'color2', 'match'));
% 
%             loctagintensity = readtable(CSVDirectoryfullpath{n});
% 
%             LocTag = [LocTag, loctagintensity{:,2}];
% 
%             spatialscale = loctagintensity{:, 1};


        elseif isequal("colorn1", regexp(CSVDirectoryfullpath{n},'colorn1', 'match'));   

            Normintensity = readmatrix(CSVDirectoryfullpath{n});
            
            
            NormMolofInterest = [NormMolofInterest, Normintensity(:,3).']; % ".'" will transpose column into row
         
%             if size(Normintensity, 1) > 1
%                 
%                  NormMolofInterest = [NormMolofInterest; Normintensity(:, 3).']; % ".'" will transpose column into row
%          
%              
%             else
%                 
%                 NormMolofInterest = horzcat(NormMolofInterest, Normintensity); % ".'" will transpose column into row
%          
%             end
        else
            disp(parentdirectory(t).name);
            disp(append('There is a CSV file with no appropiate name in the folder', CSVDirectoryfullpath{n}))
        end
      
    end
  
    

   
end

    


%% Normalizing the data
% the normalization method will depend if circles have been drawn; which is
% the same as having a color1n double

% alternatively, the 6 lowest values will be used as the "background"

FoldChangeMolofInterest = [];
    if length(NormMolofInterest) > 0 %the normalization depends on drawn circles in other regions

        for h = 1:length(MolofInterest(1,:));

            normcolumn = (MolofInterest(:, h) ./ NormMolofInterest(h)); 
            FoldChangeMolofInterest = [FoldChangeMolofInterest, normcolumn];

        end    
            
            
    elseif length(NormMolofInterest) < 1;
        
        for h = 1:length(LocTag(1,:));

            normcolumn = (MolofInterest(:, h) ./ mean(mink(MolofInterest(:, h), 6), 'omitnan')); %this is doing the average of 6 minimum values within the rectangle
            FoldChangeMolofInterest = [FoldChangeMolofInterest, normcolumn];

        end
    else 
        display("There is an error with the normalization")
    end

    
    
 NormLocTag = [];

    for w = 1:length(LocTag(1,:));

        normcolumn = (LocTag(:, w) ./ mean(mink(LocTag(:, w), 6), 'omitnan')); %this is doing the average of 6 minimum values within the rectangle
        NormLocTag = [NormLocTag, normcolumn];
    end
        

%% estimate the SEM of each color




SEMmolofinterest = std(FoldChangeMolofInterest, 0, 2, 'omitnan') ./ sqrt(size(FoldChangeMolofInterest, 2));
SEMloctag = std(NormLocTag, 0, 2, 'omitnan') ./ sqrt(size(NormLocTag, 2));




MiddleFoldChange = FoldChangeMolofInterest([(round(((size(FoldChangeMolofInterest, 1)/2) - 5), 0)):(round(((size(FoldChangeMolofInterest, 1)/2) + 5), 0))], :);
MiddleFoldChange = mean(MiddleFoldChange, 1, 'omitnan');


writematrix(MiddleFoldChange, strcat(path, f, '10 middle pixels average fold change for', nameNotchstatus));
writematrix(NormMolofInterest, strcat(path, f, 'citoplasmic signal', nameNotchstatus));



hold on
title(append(nameofmolofinterest, ' intensity in ', notchstatus), 'FontSize', 20)
xlim([0 max(spatialscale)]);
xlabel('Distance (um)', 'FontSize', 14);


ylim([0.5 2]);
ylabel(append('Normalised ', nameofmolofinterest, ' intensity'), 'FontSize', 14);

topcurve = (mean(FoldChangeMolofInterest, 2, 'omitnan') + SEMmolofinterest).';
lowercurve = (mean(FoldChangeMolofInterest, 2, 'omitnan') - SEMmolofinterest).';

pline1 = plot(spatialscale, mean(FoldChangeMolofInterest, 2, 'omitnan'), '-', 'DisplayName', nameofmolofinterest, 'color', listColor(a,:));

pfill1 = fill([spatialscale.' fliplr(spatialscale.')], [topcurve fliplr(lowercurve)], ...
              listColor(a,:), 'linestyle', 'none', 'FaceAlpha', .3, 'DisplayName', 'SEMmol');

 
 legend([pline1],  notchstatus, ...
     'FontSize', 14);
end

% yyaxis right;
% % s
% ylabel(append('Normalised ', nameofloctag, ' intensity'), 'FontSize', 14);
% 
% topcurve2 = (mean(NormLocTag, 2, 'omitnan') + SEMloctag).';
% lowercurve2 = (mean(NormLocTag, 2, 'omitnan') - SEMloctag).';
% 
% pline2 = plot(spatialscale, mean(NormLocTag, 2, 'omitnan'), '-r', 'DisplayName', nameofloctag);
% 
% pfill2 = fill([spatialscale.' fliplr(spatialscale.')], [topcurve2 fliplr(lowercurve2)], ...
%               [1 0.1 0.1], 'linestyle', 'none', 'FaceAlpha', .3, 'DisplayName', 'SEMloc');
% 
% % 

   




%% saving the figure

orient(gcf,'landscape');

saveas(gcf, append(path, f, "SuHLLL classic plot.pdf"));

%% saving the middle part average


MiddleFoldChange = FoldChangeMolofInterest([(round(((size(FoldChangeMolofInterest, 1)/2) - 5), 0)):(round(((size(FoldChangeMolofInterest, 1)/2) + 5), 0))], :);
MiddleFoldChange = mean(MiddleFoldChange, 1, 'omitnan');

writematrix(MiddleFoldChange, strcat(path, f, '10 middle pixels average fold change for', nameNotchstatus));



