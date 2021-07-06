%%personal startup
mkdir('/Users/fjavierdha/Documents/MATLAB')

warning ('off','all')


%% the following section is to the names of the Mol of Interest and the Notch condition

%color1 is the molecule that is tagged
%color2 is the loctag
%colorn1 are measured areas outside the loctag, they contain one vale 
 




listConditions = {'Notch ON', 'Notch OFF'};

[indx,tf] = listdlg('ListString',listConditions);

    if isequal('Notch ON', listConditions{indx});

        nameNotchstatus = "NDECD";
        notchstatus = "NDECD";

    elseif isequal('Notch OFF', listConditions{indx});
        nameNotchstatus = "lacZ";
        notchstatus = "lacZ";
        
    end



listMolecules = readtable("/Users/fjavierdha/Documents/MATLAB/TaggedMols.csv");
listMolecules = listMolecules{:,1}


[indx2,tf2] = listdlg('ListString',listMolecules);


nameofmolofinterest = 'suh nt idr'
nameofloctag = "loctag"



%% Reading the csv file

% creating empty matrixes in which to store each of the channels

molofinterest = []; %make color 1 the molecule that is tagged
loctag  = []; %make color 2 the loctag


% getting the folder 

path = uigetdir()

parentdirectory = dir(append(path, '/*', nameNotchstatus, '*'));

normmolofinterest = [];
numberofcycles = 0

for t = [1:length({parentdirectory.name})] %this loop will go over every folder that has the name nameNotchstatus on it
    
 
   parentdirectory(t).name
    
    directory = dir(append(parentdirectory(t).folder, "/", parentdirectory(t).name, '/*.csv'));
        
    directoryonlycsv = {};
    numberofcycles = 0;
    
    for u = 1:length(directory)
            directoryonlycsv = [directoryonlycsv, append(directory(u).folder, "/", directory(u).name)];
    end 
        

    csvwithgreen = find(cellfun(@(x) ~isempty(x), regexp(directoryonlycsv,'color1')));
    csvwithgreennorm = find(cellfun(@(x) ~isempty(x), regexp(directoryonlycsv,'colorn1')));

    for n = csvwithgreen

    
    nuclearmoleculeintensity = readtable(directoryonlycsv{n});

    molofinterest = [molofinterest, nuclearmoleculeintensity{:,2}];
    
    numberofcycles = (numberofcycles + 1); %this is to keep track of the csv files that have been read 
    
    csvwithgreennormdirectory = dir(append(parentdirectory(t).folder, "/", parentdirectory(t).name, '/*colorn1.csv'));
    csvwithgreennormdirectory = append(parentdirectory(t).folder, "/", parentdirectory(t).name, "/", csvwithgreennormdirectory.name);
    
    csvwithgreennorm = readtable(csvwithgreennormdirectory);
     
    
    normmolofinterest = [normmolofinterest, (nuclearmoleculeintensity{:,2} ./ csvwithgreennorm{numberofcycles, 'Mean'})];
    
    spatialscale = nuclearmoleculeintensity{:, 1};


    end


    csvwithred = find(cellfun(@(x) ~isempty(x),regexp(directoryonlycsv,'color2')));

    for n = csvwithred


    loctagintensity = readtable(directoryonlycsv{n});

    loctag = [loctag, loctagintensity{:,2}];

    spatialscale = loctagintensity{:, 1};


    end
end


    


%% Normalizing the data



FoldChangeMolofInterest = [];


for h = 1:length(molofinterest(1,:))
    
    normcolumn = (molofinterest(:, h) ./ mean(mink(molofinterest(:, h), 6))); %this is doing the average of 6 minimum values within the rectangle
    FoldChangeMolofInterest = [FoldChangeMolofInterest, normcolumn];

end


% 
% normloctag = [];
% 
% for n = 1:length(loctag(1,:));
%     
%     normcolumn = (loctag(:, n) - min(loctag(:, n))) ./ (max(loctag(:, n)) - min(loctag(:, n)));
%     normloctag = [normloctag, normcolumn];
% end



%% estimate the SEM of each color


blue = [0 0.5 1];
red = [1 0.2 0.2];
green = [0.11 0.7 0.32];
orange = [1 0.58 0.01];
purple = [0.74 0.01 1];

colour = green

hold on

SEMmolofinterest = std(FoldChangeMolofInterest, 0, 2) ./ sqrt(size(FoldChangeMolofInterest, 2));

title(append(nameofmolofinterest, ' intensity in ', notchstatus), 'FontSize', 20)
xlim([0 max(spatialscale)]);
xlabel('Distance (um)', 'FontSize', 14);


ylim([0.8 1.4]);
ylabel(append( nameofmolofinterest, 'fluorescence intensity'), 'FontSize', 14);

topcurve = (mean(FoldChangeMolofInterest, 2, 'omitnan') + SEMmolofinterest).';
lowercurve = (mean(FoldChangeMolofInterest, 2, 'omitnan') - SEMmolofinterest).';

pline1 = plot(spatialscale, mean(FoldChangeMolofInterest, 2, 'omitnan'), '-', 'DisplayName', nameofmolofinterest, 'color', colour);

pfill1 = fill([spatialscale.' fliplr(spatialscale.')], [topcurve fliplr(lowercurve)], ...
              colour, 'linestyle', 'none', 'FaceAlpha', .3, 'DisplayName', 'SEMmol');

 
 legend([pline1],  notchstatus, ...
     'FontSize', 14);



orient(gcf,'landscape');

saveas(gcf, append(path, "/", nameNotchstatus, nameofmolofinterest));







%%

normmolofinterest = [];

for n = 1:length(molofinterest(1,:))
%    
%    normcolumn = molofinterest(:, n) ./ mean(molofinterest(:, n));
%    normmolofinterest = [normmolofinterest, normcolumn];
%end



normloctag = [];

for n = 1:length(loctag(1,:));
    
    normcolumn = (loctag(:, n) - min(loctag(:, n))) ./ (max(loctag(:, n)) - min(loctag(:, n)));
    normloctag = [normloctag, normcolumn];
end



%% estimate the SEM of each color




SEMmolofinterest = std(normmolofinterest, 0, 2) ./ sqrt(size(normmolofinterest, 2));
SEMloctag = std(normloctag, 0, 2) ./ sqrt(size(normloctag, 2));




%% plotting 

hold off;
hold on;

title(append(nameofmolofinterest, ' intensity in ', notchstatus, ' conditions'), 'FontSize', 20)
xlim([0 max(spatialscale)]);
xlabel('Distance (um)', 'FontSize', 14);

yyaxis left;
ylim([0 4]);
ylabel(append('Normalised ', nameofmolofinterest, ' intensity'), 'FontSize', 14);

topcurve = (mean(normmolofinterest, 2) + SEMmolofinterest).';
lowercurve = (mean(normmolofinterest, 2) - SEMmolofinterest).';

pline1 = plot(spatialscale, mean(normmolofinterest, 2), '-o', 'DisplayName', nameofmolofinterest);

pfill1 = fill([spatialscale.' fliplr(spatialscale.')], [topcurve fliplr(lowercurve)], ...
              [0 0.5 1], 'linestyle', 'none', 'FaceAlpha', .3, 'DisplayName', 'SEMmol');


yyaxis right;
ylim([0 1]);
ylabel(append('Normalised ', nameofloctag, ' intensity'), 'FontSize', 14);

topcurve2 = (mean(normloctag, 2) + SEMloctag).';
lowercurve2 = (mean(normloctag, 2) - SEMloctag).';

pline2 = plot(spatialscale, mean(normloctag, 2), '-ro', 'DisplayName', nameofloctag);

pfill2 = fill([spatialscale.' fliplr(spatialscale.')], [topcurve2 fliplr(lowercurve2)], ...
              [1 0.1 0.1], 'linestyle', 'none', 'FaceAlpha', .3, 'DisplayName', 'SEMloc');



legend([pline1,pline2], nameofmolofinterest, nameofloctag, ...
       'FontSize', 14);




%% saving the figure

orient(gcf,'landscape');

filename = fullfile(path,...
                    append(nameofmolofinterest, nameNotchstatus, "new quantification & normalized with drawings, n", string(n),'.pdf'))
                
print(filename, '-dpdf')

