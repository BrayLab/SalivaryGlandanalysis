
%% get the folder that contains our same genotype and same day data 

path = uigetdir();


%get the files inside that contain a .csv file

warning('on')
directory = dir([path, '/*.csv']);

directoryonlycsv = {directory.name};

%' the number of frames prior to the pulse is prepulseframes: '
prepulseframes = 10
%make a loop with all the .csv files in the folder

frapmatrix = [];
frapmatrixnonbleached = []; 

frapmatrixraw = [];
frapmatrixrawnonbleached = [];

for n = 1:length(directoryonlycsv)
    
    frapdata = [];
    
    disp(directoryonlycsv{n})
    
    opts = detectImportOptions([path, '/', directoryonlycsv{n}]);
    opts.VariableNamesLine = 2;
    
   
    
    frapdata = readtable([path, '/', directoryonlycsv{n}], 'HeaderLines',1);
    
    frapdata.Properties.VariableNames{:,1} = 'Time';
    frapdata.Properties.VariableNames{:,2} = 'bleachROI';
    frapdata.Properties.VariableNames{:,3} = 'nonbleachROIs';
    frapdata.Properties.VariableNames{:,4} = 'otherregionROI';
    frapdata.Properties.VariableNames{:,5} = 'bgROI';
    
        if mean(frapdata.otherregionROI) < mean(frapdata.bgROI)
         warning('mean of the totalROI is smaller than the background; check if rois are in the appropiate order, where ROI_02__ = bleachROI, ROI_03__ = totalROI and ROI_04__ = bgROI', '');
        end
        
        if mean(frapdata.bleachROI) < mean(frapdata.bgROI)
         warning('mean of the bleachROI is smaller than the background; check if rois are in the appropiate order, where ROI_02__ = bleachROI, ROI_03__ = totalROI and ROI_04__ = bgROI', '');
        end
    
    frapmatrixraw = padconcatenation(frapmatrixraw, frapdata{:, 'bleachROI'}, 2);
    frapmatrixrawnonbleached = padconcatenation(frapmatrixrawnonbleached, frapdata{:, 'nonbleachROIs'}, 2);
     
    Tpre = mean(frapdata{1:prepulseframes, 'otherregionROI'});
    Bpre = mean(frapdata{1:prepulseframes, 'bleachROI'});
    Bprenonbleached = mean(frapdata{prepulseframes:prepulseframes+5, 'nonbleachROIs'});
    BG = mean(frapdata{:, 'bgROI'});
    
    Bt = frapdata{:, 'bleachROI'};
    Btrenonbleached = frapdata{:, 'nonbleachROIs'};
    Tt = frapdata{:, 'otherregionROI'};

    
    frapdata.DoubleNorm = ( (Tpre - BG) .* (Bt - BG) ) ./ ( (Tt - BG) .* (Bpre - BG) );
    
    frapdata.DoubleNormnonbleached = ( (Tpre - BG) .* (Btrenonbleached - BG) ) ./ ( (Tt - BG) .* (Bprenonbleached - BG) );
    
    frapdata.NormOver1 = ( frapdata{:,'DoubleNorm'} - frapdata{prepulseframes + 1,'DoubleNorm'} ) ./ ( 1 -  frapdata{prepulseframes + 1,'DoubleNorm'});
                           
    frapdata.NormOver1nonbleached = ( frapdata{:,'DoubleNormnonbleached'} - frapdata{prepulseframes+1 ,'DoubleNormnonbleached'} ) ./ ( 1 -  frapdata{prepulseframes+1,'DoubleNormnonbleached'});
   
    frapmatrix = padconcatenation(frapmatrix, frapdata.NormOver1, 2);
    frapmatrixnonbleached = padconcatenation(frapmatrixnonbleached, frapdata.DoubleNormnonbleached, 2);

end



timescale = table2array(frapdata(:, 'Time'));


%% plotting the raw data


timescaleforplot = repmat(timescale,1, length(frapmatrix(1,:)));



 try
     close(gcf)
 end

figure;

plot(timescaleforplot, frapmatrixraw, 'color', '#0072BD');
hold on;
plot(timescaleforplot, frapmatrixrawnonbleached, 'color', '#FF3333');
xlim([0,timescaleforplot(end)]);

h = get(gca,'Children')

legend([h(1), h(7)], 'Non bleached region', 'Actively bleached region', 'FontSize', 15); %picked two h lines that were  different 

orient(gcf,'landscape');
saveas(gcf, append(path,'/frap on part of the MAM band colour sorted raw data.pdf'));

%% plotting individual lines with normalised data

 try
     close(gcf)
 end

hold off

plot(timescaleforplot, frapmatrix, 'color', '#0072BD');
hold on;
plot(timescaleforplot, frapmatrixnonbleached, 'color', '#FF3333');
xlim([0,timescaleforplot(end)]);
ylim([0,2])
h = get(gca,'Children')



legend([pline1],  notchstatus, ...
      'FontSize', 14);

legend([h(1), h(7)], 'Non bleached region', 'Actively bleached region', 'FontSize', 15); %picked two h lines that were  different 

orient(gcf,'landscape');
saveas(gcf, append(path,'/frap MAM color sorted normalised data.pdf'));


% frapmatrix = frapmatrix(:, [1:3,6, 7, 10, 11, 12, 14, 16, 19, 21:23, 28 ])
%frapdataforexport = horzcat(timescale, frapmatrix)
%writetable(array2table(frapdataforexport), 'notchon.csv' ,'Delimiter' ,',')

%% plotting average and SEM of normalised data

%frapmatrixON = []
SEM = std(frapmatrix, 0, 2, 'omitnan') ./ sqrt(size(frapmatrix, 2));
SEMnonbleached = std(frapmatrixnonbleached, 0, 2, 'omitnan') ./ sqrt(size(frapmatrixnonbleached, 2));


 try
     close(gcf)
 end
 
hold on 
xlabel('Time (s)', 'FontSize', 14);

ylabel('Mastermind', 'FontSize', 14);
 
topcurve = (mean(frapmatrix, 2, 'omitnan') + SEM).';
lowercurve = (mean(frapmatrix, 2, 'omitnan') - SEM).';

topcurvenonbleached = (mean(frapmatrixnonbleached, 2, 'omitnan') + SEM).';
lowercurvenonbleached = (mean(frapmatrixnonbleached, 2, 'omitnan') - SEM).';

plot(timescale, mean(frapmatrix, 2, 'omitnan'), '-', 'color', '#0072BD');
 xlim([0, 160]);
 ylim([0, 2]);   
pfill1 = fill([timescale.' fliplr(timescale.')], [topcurve fliplr(lowercurve)], ...
              [0 0.5 1], 'linestyle', 'none', 'FaceAlpha', .3);
    
          
plot(timescale, mean(frapmatrixnonbleached, 2, 'omitnan'), '-', 'color', '#FF3333');

pfill2 = fill([timescale.' fliplr(timescale.')], [topcurvenonbleached fliplr(lowercurvenonbleached)], ...
              [1 0.2 0.2], 'linestyle', 'none', 'FaceAlpha', .3);


h = get(gca,'Children');

legend([h(2), h(4)], 'Non bleached region', 'Actively bleached region', 'FontSize', 15); %picked two h lines that were  different 


orient(gcf,'landscape');
saveas(gcf, append(path,'/partial frap average cropped adding the whole band.pdf'));


%% plotting jsut the recovery according to droplet size

Directorytxt = dir([path, '/*.txt']);
Directorytxt.name;

DropletInfo = readtable([path, '/', Directorytxt.name], 'HeaderLines',1);
DropletSize = table2array(DropletInfo(:, 2));

col = [180/255, 191/255, 220/255; 0/255, 153/255, 212/255; 11/255, 57/255, 139/255];
gscatter(timescale(:, :)', frapmatrix(:,:, 1)', DropletSize, col)



%% saving the previous experiments



NotchON = frapmatrix;
timescaleNotchON = timescale;
SEMNotchON =SEM;



pNotchON = boundedline(timescaleNotchON, mean(NotchON, 2), SEMNotchON, '-bo');
pNotchON.MarkerSize = 3; %in red


set(p,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])


%% saving the previous experiments

NotchOFF = frapmatrix;
timescaleNotchOFF = timescale;
SEMNotchOFF =SEM;



pNotchOFF = boundedline(timescaleNotchOFF, mean(NotchOFF, 2), SEM, '-o');
pNotchOFF.MarkerSize = 3; %in blue


%%


hold on 

pNotchON = boundedline(timescaleNotchON, mean(NotchON, 2), SEMNotchON, '-ro');
pNotchON.MarkerSize = 3; %in red

pNotchOFF = boundedline(timescaleNotchOFF, mean(NotchOFF, 2), SEMNotchOFF, '-o');
pNotchOFF.MarkerSize = 3; %in blue

hold off


%% try to fit both data sets into the model
% 
% y = timescaleNotchOFF;

x = NotchOFF(:, 8)

frapmatrixforadjust = frapmatrix(prepulseframes+1:length(frapmatrix(:,1)), :);

timescaleforadjust = repmat(timescale(prepulseframes+1:length(frapmatrix(:,1))),1, length(frapmatrixforadjust(1,:)));

% modelfun = @ 1 - Inmobile - C1 * exp(-0.69*x / Halftime1) - C2 * exp(-0.69*x / Halftime2) 
%  1 - i - c*exp(x/h) - d*exp(x/j)

cftool()
% 

