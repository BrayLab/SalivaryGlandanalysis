%%personal startup
mkdir('/Users/fjavierdha/Documents/MATLAB')

warning ('off','all')


%% the following section is to get all the intensity values from each channel into a csv file

 %colour1 is the molecule that is tagged (in the original script it was
 %green)
 
%colour2 is the loctag (originally it was named red)
 

% this is for the figure that is generated

nameofmolofinterest = 'SuH-IDRnt' 
nameofloctag = "loctag"
nameNotchstatus = "Notch ON"
%nameNotchstatus = "Notch OFF"

% creating empty matrixes in which to store each of the channels


molofinterest = []; %make color 1 the molecule that is tagged
loctag  = []; %make color 2 the loctag








%% run with as many folders with all the same genotypes

path = uigetdir()

directory = dir([path, '/*.csv']);

directoryonlycsv = {directory.name};


csvwithgreen = find(cellfun(@(x) ~isempty(x),regexp(directoryonlycsv,'color1')));


for n = csvwithgreen
    
    
    nuclearmoleculeintensity = readtable([path,'/', directoryonlycsv{n}]);
    
    molofinterest = [molofinterest, nuclearmoleculeintensity{:,2}];
    
    spatialscale = nuclearmoleculeintensity{:, 1};
  

end


csvwithred = find(cellfun(@(x) ~isempty(x),regexp(directoryonlycsv,'color2')));

for n = csvwithred
    
    
    loctagintensity = readtable([path,'/', directoryonlycsv{n}]);
    
    loctag = [loctag, loctagintensity{:,2}];
    
    spatialscale = loctagintensity{:, 1};
  

end

%% Normalizing the data

normmolofinterest = [];

for n = 1:length(molofinterest(1,:))
    
    normcolumn = (molofinterest(:, n) - min(molofinterest(:, n))) ./ (max(molofinterest(:, n)) - min(molofinterest(:, n)));
    normmolofinterest = [normmolofinterest, normcolumn];
end



normloctag = [];

for n = 1:length(loctag(1,:));
    
    normcolumn = (loctag(:, n) - min(loctag(:, n))) ./ (max(loctag(:, n)) - min(loctag(:, n)));
    normloctag = [normloctag, normcolumn];
end

%% estimate the SEM of each color




SEMmolofinterest = std(normmolofinterest, 0, 2) ./ sqrt(size(normmolofinterest, 2));
SEMloctag = std(normloctag, 0, 2) ./ sqrt(size(normloctag, 2));




%% plotting  

hold on;

title(append(nameofmolofinterest, ' intensity in ', nameNotchstatus, ' conditions'), 'FontSize', 20)
xlim([0 max(spatialscale)]);
xlabel('Distance (um)', 'FontSize', 14);

yyaxis left;
ylim([0 1]);
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


hold off;

%% saving the figure

orient(gcf,'landscape');

filename = fullfile('/Users/fjavierdha/Google Drive/MJG quantification figures/',...
                    append(nameofmolofinterest, nameNotchstatus, "n", string(n),'.pdf'))
                
print(filename, '-dpdf')

