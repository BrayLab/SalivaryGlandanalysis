
%% get the folder that contains our same genotype and same day data 

path = uigetdir();

blue = [0 0.5 1];
red = [1 0.2 0.2];
green = [0.11 0.7 0.32];
orange = [1 0.58 0.01];
purple = [0.74 0.01 1];

colour = green

%get the files inside that contain a .csv file

warning('on')
directory = dir([path, '/*wRi*.csv']);

directoryonlycsv = {directory.name};

%' the number of frames prior to the pulse is prepulseframes: '
prepulseframes = 10
%make a loop with all the .csv files in the folder

frapmatrix = [];
frapmatrixraw = [];

for n = 1:length(directoryonlycsv)
    
    frapdata = [];
    
    disp(directoryonlycsv{n})
    
    opts = detectImportOptions([path, '/', directoryonlycsv{n}]);
    opts.VariableNamesLine = 2;
    
   
    
    frapdata = readtable([path, '/', directoryonlycsv{n}], 'HeaderLines',1);
    
    frapdata.Properties.VariableNames{:,1} = 'Time';
    frapdata.Properties.VariableNames{:,2} = 'bleachROI';
    frapdata.Properties.VariableNames{:,3} = 'otherregionROI';
    frapdata.Properties.VariableNames{:,4} = 'bgROI';
    
        if mean(frapdata.otherregionROI) < mean(frapdata.bgROI)
         warning('mean of the totalROI is smaller than the background; check if rois are in the appropiate order, where ROI_02__ = bleachROI, ROI_03__ = totalROI and ROI_04__ = bgROI', '');
        end
        
        if mean(frapdata.bleachROI) < mean(frapdata.bgROI)
         warning('mean of the bleachROI is smaller than the background; check if rois are in the appropiate order, where ROI_02__ = bleachROI, ROI_03__ = totalROI and ROI_04__ = bgROI', '');
        end
    
    frapmatrixraw = padconcatenation(frapmatrixraw, frapdata{:, 'bleachROI'}, 2);
    
    Tpre = mean(frapdata{1:prepulseframes, 'otherregionROI'});
    Bpre = mean(frapdata{1:prepulseframes, 'bleachROI'});
    BG = mean(frapdata{:, 'bgROI'});
    
    Bt = frapdata{:, 'bleachROI'};
    Tt = frapdata{:, 'otherregionROI'};

    
    frapdata.DoubleNorm = ( (Tpre - BG) .* (Bt - BG) ) ./ ( (Tt - BG) .* (Bpre - BG) );
    
    frapdata.NormOver1 = ( frapdata{:,'DoubleNorm'} - frapdata{prepulseframes + 1,'DoubleNorm'} ) ./ ( 1 -  frapdata{prepulseframes + 1,'DoubleNorm'});
                           
    
   
    frapmatrix = padconcatenation(frapmatrix, frapdata.NormOver1, 2);

end



timescale = table2array(frapdata(:, 'Time'));
timescale = timescale - timescale(prepulseframes)



%% plotting the raw data

 try
     close(gcf)
 end
 
timescaleforplot = repmat(timescale,1, length(frapmatrix(1,:)));


plot(timescaleforplot, frapmatrixraw);
xlim([0,timescaleforplot(end)]);


orient(gcf,'landscape');
saveas(gcf, append(path,'/frap MAM color sorted raw data.pdf'));


plot(timescaleforplot, frapmatrix);
xlim([0,timescaleforplot(end)]);
ylim([0,2])


legend(directoryonlycsv, 'FontSize', 5);


saveas(gcf, append(path,'/frap MAM color sorted normalised data.pdf'));

% frapmatrix = frapmatrix(:, [1:3,6, 7, 10, 11, 12, 14, 16, 19, 21:23, 28 ])
%frapdataforexport = horzcat(timescale, frapmatrix)
%writetable(array2table(frapdataforexport), 'notchon.csv' ,'Delimiter' ,',')

%% plotting average and SEM of normalised data

%frapmatrixON = []
SEM = std(frapmatrix, 0, 2, 'omitnan') ./ sqrt(size(frapmatrix, 2));



%  try
%      close(gcf)
%  end

hold on 
xlabel('Time (s)', 'FontSize', 14);

ylabel('Su(H) recovery', 'FontSize', 14);
xlim([0, timescale(end)])

topcurve = (mean(frapmatrix, 2, 'omitnan') + SEM).';
lowercurve = (mean(frapmatrix, 2, 'omitnan') - SEM).';

plot(timescale, mean(frapmatrix, 2, 'omitnan'), '-',  'color', colour);




pfill1 = fill([timescale.' fliplr(timescale.')], [topcurve fliplr(lowercurve)], ...
             colour , 'linestyle', 'none', 'FaceAlpha', .3);


         
h = get(gca,'Children');

legend([h(2), h(4)], 'NDECD, wRi experiments', 'NDECD, January experiments', 'FontSize', 15); %picked two h lines that were  different 


orient(gcf,'landscape');
saveas(gcf, append(path,'/frap MAM average cropped new.pdf'));


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
% 
% x = NotchOFF(:, 8)
% 
% frapmatrixforadjust = frapmatrix(prepulseframes+1:length(frapmatrix(:,1)), :);
% 
% timescaleforadjust = repmat(timescale(prepulseframes+1:length(frapmatrix(:,1))),1, length(frapmatrixforadjust(1,:)));
% 
% % modelfun = @ 1 - Inmobile - C1 * exp(-0.69*x / Halftime1) - C2 * exp(-0.69*x / Halftime2) 
% %  1 - i - c*exp(x/h) - d*exp(x/j)
% 
% cftool()
% % 

