%%personal startup
mkdir('/Users/fjavierdha/Documents/MATLAB')

warning ('on','all')


%% the following section is to get all the intensity values from each channel into a csv file

 %colour1 is the molecule that is tagged (in the original script it was
 %green)
 
%colour2 is the loctag (originally it was named red)
 

% this is for the figure that is generated

nameofmolofinterest = 'suh nt idr' 
nameofloctag = "loctag"

nameNotchstatus = "Notch ON"
notchstatus = "Notch"

%nameNotchstatus = "Notch OFF"
%notchstatus = "LacZ"

% creating empty matrixes in which to store each of the channels


molofinterest = []; %make color 1 the molecule that is tagged
loctag  = []; %make color 2 the loctag








%% run with as many folders with all the same genotypes

path = uigetdir()

directory = dir([path, '/*.csv']);

directoryonlycsv = {directory.name};


csvlist = find(cellfun(@(x) ~isempty(x),regexp(directoryonlycsv,string(notchstatus))));

molofinterest = [];
spatialscale = [];

for n = csvlist
    
    
    nuclearmoleculeintensity = readtable([path,'/', directoryonlycsv{n}]);
    
    molofinterest = [molofinterest, nuclearmoleculeintensity{:, 4:4:end}];
    
    spatialscale = nuclearmoleculeintensity{:, 1};
  

end


% 
% for n = csvlist
%     
%     
%     loctagintensity = readtable([path,'/', directoryonlycsv{n}]);
%     
%     loctag = [loctag, loctagintensity{:,2:4:end}];
%     
%     spatialscale = loctagintensity{:, 1};
%   
% 
% end


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

spatialscaleforindividual = repmat(spatialscale, 1, size(FoldChangeMolofInterest, 2))

plot(spatialscaleforindividual, FoldChangeMolofInterest)

pline1 = plot(spatialscale, mean(FoldChangeMolofInterest, 2, 'omitnan'), '-', 'DisplayName', nameofmolofinterest, 'color', colour);

pfill1 = fill([spatialscale.' fliplr(spatialscale.')], [topcurve fliplr(lowercurve)], ...
              colour, 'linestyle', 'none', 'FaceAlpha', .3, 'DisplayName', 'SEMmol');

 
 legend([pline1],  notchstatus, ...
     'FontSize', 14);



orient(gcf,'landscape');

saveas(gcf, append(path, "/", nameNotchstatus, nameofmolofinterest));


%% plotting 

hold off
hold on;

title(append(nameofmolofinterest, ' intensity in ', notchstatus, ' conditions'), 'FontSize', 20)
xlim([0 max(spatialscale)]);
xlabel('Distance (um)', 'FontSize', 14);


yyaxis left;
ylim([0.5 1.5]);
ylabel(append('Normalised ', nameofmolofinterest, ' intensity'), 'FontSize', 14);

topcurve = (nanmean(normmolofinterest, 2) + SEMmolofinterest).';
lowercurve = (nanmean(normmolofinterest, 2) - SEMmolofinterest).';

pline1 = plot(spatialscale, nanmean(normmolofinterest, 2), '-o', 'DisplayName', nameofmolofinterest);

pfill1 = fill([spatialscale.' fliplr(spatialscale.')], [topcurve fliplr(lowercurve)], ...
              [0 0.5 1], 'linestyle', 'none', 'FaceAlpha', .3, 'DisplayName', 'SEMmol');


yyaxis right;
ylim([0 1]);
ylabel(append('Normalised ', nameofloctag, ' intensity'), 'FontSize', 14);

topcurve2 = (nanmean(normloctag, 2) + SEMloctag).';
lowercurve2 = (nanmean(normloctag, 2) - SEMloctag).';

pline2 = plot(spatialscale, mean(normloctag, 2), '-ro', 'DisplayName', nameofloctag);

pfill2 = fill([spatialscale.' fliplr(spatialscale.')], [topcurve2 fliplr(lowercurve2)], ...
              [1 0.1 0.1], 'linestyle', 'none', 'FaceAlpha', .3, 'DisplayName', 'SEMloc');



legend([pline1,pline2], nameofmolofinterest, nameofloctag, ...
       'FontSize', 14);




%% saving the figure

orient(gcf,'landscape');

filename = fullfile('/Users/fjavierdha/Google Drive/MJG quantification figures/quantification trials/',...
                    append(nameofmolofinterest, nameNotchstatus, "new quantification, n", string(n),'.pdf'))
                
print(filename, '-dpdf')

