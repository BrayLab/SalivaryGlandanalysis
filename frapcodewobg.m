
%% get the folder that contains our same genotype and same day data 
blue = [0 0.5 1];
red = [1 0.2 0.2];
green = [0.11 0.7 0.32];
orange = [1 0.58 0.01];
purple = [0.74 0.01 1];
suhgreen = [141/255 191/255 68/255];
mampurple = [193/255 37/255 101/255];


path = uigetdir();
colour = red;

%get the files inside that contain a .csv file

warning('on')
directory = dir([path, '/*HRi*.csv']);

directoryonlycsv = {directory.name};

%' the number of frames prior to the pulse is prepulseframes: '
prepulseframes = 10
%make a loop with all the .csv files in the folder

frapmatrix = [];
frapmatrixraw = [];
bleachinginfo = [];

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
    
    
    
    BtNorm1 = (Bt) ./ (Bpre).';
           
    Bleaching = (Tt) ./ (Tpre).';
    
    BtNorm2 = BtNorm1 ./ Bleaching;
           
    BtNorm3 = (BtNorm2 - BtNorm2(prepulseframes + 1)) ./ (1 - BtNorm2(prepulseframes + 1));


    bleachinginfo = padconcatenation(bleachinginfo, Bleaching, 2);
    frapdata.DoubleNorm = ( (Tpre) .* (Bt) ) ./ ( (Tt) .* (Bpre) );
    
    frapdata.NormOver1 = ( frapdata{:,'DoubleNorm'} - frapdata{prepulseframes + 1,'DoubleNorm'} ) ./ ( 1 -  frapdata{prepulseframes + 1,'DoubleNorm'});
                           
    
   
    frapmatrix = padconcatenation(frapmatrix, frapdata.NormOver1, 2);
    
end



timescale = table2array(frapdata(:, 'Time'));
timescale = timescale - timescale(prepulseframes+1);

%% estimating the percentage 


percentageofbleaching = 100* (1- frapmatrixraw(prepulseframes+1, :) ./ mean(frapmatrixraw(1:prepulseframes,:), 1));


%% plotting the raw data

 try
     close(gcf)
 end
 
timescaleforplot = repmat(timescale,1, length(frapmatrix(1,:)));


plot(timescaleforplot, frapmatrixraw);
xlim([timescaleforplot(1, 1),timescaleforplot(end)]);


orient(gcf,'landscape');
saveas(gcf, append(path,'/mam hRi individual tracks sorted by day.pdf'));


plot(timescaleforplot, frapmatrix)
xlim([timescaleforplot(1, 1),timescaleforplot(end, 1)]);
ylim([0,1.1])

%plotting different days with different colors
hold off
hold on 
plot(timescaleforplot(:, 1:5), frapmatrix(:, 1:5), 'r');
plot(timescaleforplot(:, 6), frapmatrix(:, 6), 'g');
plot(timescaleforplot(:, 7), frapmatrix(:, 7), 'b');
plot(timescaleforplot(:, 8:end), frapmatrix(:, 8:end), 'k');

xlim([timescaleforplot(1:1),timescaleforplot(end, 1)]);
ylim([0,1.1])


legend(directory.name, 'FontSize', 10, 'Location', 'eastoutside');

orient(gcf,'landscape');
saveas(gcf, append(path,'/frap mam gfp new settings individual recoveries.pdf'));

% frapmatrix = frapmatrix(:, [1:3,6, 7, 10, 11, 12, 14, 16, 19, 21:23, 28 ])
%frapdataforexport = horzcat(timescale, frapmatrix)
%writetable(array2table(frapdataforexport), 'notchon.csv' ,'Delimiter' ,',')

%% checking the individual tracks


% 
% 
% frapmatrix = frapmatrix(:, [11:21 23:end]);
% legend()
% 
plot(timescale,frapmatrix);

legend()
%% plotting average and SEM of normalised data

tl = tiledlayout(2, 5,'TileSpacing','Compact');

nexttile([1, 4])

%frapmatrixON = []
SEM = std(frapmatrix, 0, 2, 'omitnan') ./ sqrt(size(frapmatrix, 2));
SEMbleaching = std(bleachinginfo, 0, 2, 'omitnan') ./ sqrt(size(bleachinginfo, 2));

% 
%  try
%      close(gcf)
%  end
hold on 
xlabel('Time (s)', 'FontSize', 14);

ylabel('Recovery', 'FontSize', 14);
xlim([timescale(1),  timescale(end)])
ylim([0, 1.05])
topcurve = (mean(frapmatrix, 2, 'omitnan') + SEM).';
lowercurve = (mean(frapmatrix, 2, 'omitnan') - SEM).';

plot(timescale, mean(frapmatrix, 2, 'omitnan'), '-',  'color', colour);


dsearchn(mean(frapmatrix, 2, 'omitnan'),0.5)

pfill1 = fill([timescale.' fliplr(timescale.')], [topcurve fliplr(lowercurve)], ...
             colour , 'linestyle', 'none', 'FaceAlpha', .3);

yticks([0:0.1:1])
xticks([0:5:49 50:50:timescale(end)])
xtickangle(45)


halftimedot = plot(timescale(dsearchn(mean(frapmatrix, 2, 'omitnan'),0.5)),0.5,'.', 'MarkerSize', 15, 'color', colour) 

% legend(halftimedot,'Points')
         

yyaxis right;

ylim([0, 1.2])
ylabel(append('Bleaching due to acquisition'), 'FontSize', 14, 'color', 'red');



topcurveb = (mean(bleachinginfo, 2, 'omitnan') + SEM).';
lowercurveb = (mean(bleachinginfo, 2, 'omitnan') - SEM).';

plot(timescale, mean(bleachinginfo, 2, 'omitnan'), '-',  'color', red);


pfill1b = fill([timescale.' fliplr(timescale.')], [topcurveb fliplr(lowercurveb)], ...
             red , 'linestyle', 'none', 'FaceAlpha', .3);
         
grid on
   


nexttile

label = {'Intentional bleaching'};

plotBoxplot(percentageofbleaching.', label, label, 0.5 , 0.25, ' ', 14, 14, blue, 0.3, 5, 18, [0, 100])
grid on

timescale(dsearchn(mean(frapmatrix, 2, 'omitnan'),0.5))

% plotBoxplot(All,Nicknames,ExpLabels,Jitter,BarW,Title,FontSize,DotSize,CMAP,FaceAlpha,LineWidth,FontSizeTitle,Ylim)
% 
% plotBoxplot('All', AllMatrix, 'Nicknames', listConditions, 'ExpLabels', listConditions, ...
%          'Jitter', 0.5 , 'BarW', 0.01, 'Title', 'MamGFP intensity with MedKDs', 'FontSize', 5,...
%          'DotSize',  2, 'CMAP',  [0.1, 1, 0.1], 'LineWidth',  1, 'FontSizeTitle', 1, ...
%          'Ylim', [0, 10])
%     

% 
%  h = get(gca,'Children');
% 
%  legend([h(6), h(4), h(2)], 'Su(H) wtGFP','Su(H) LLL', 'Su(H) wt', 'FontSize', 15); %picked two h lines that were  different 
% 
% 
%  orient(gcf,'landscape');
%  saveas(gcf, append(path,'/frap Mam HRi quality after removing.pdf'));


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
frapmatrixforadjust = frapmatrix(prepulseframes+1:end, :);
% 
timescaleforadjust = repmat(timescale(prepulseframes+1:length(frapmatrix(:,1))),1, length(frapmatrixforadjust(1,:)));
% 
% % modelfun = @ 1 - Inmobile - C1 * exp(-0.69*x / Halftime1) - C2 * exp(-0.69*x / Halftime2) 
% %  1 - i - c*exp(x/h) - d*exp(x/j)
% 
% cftool()
% % 

