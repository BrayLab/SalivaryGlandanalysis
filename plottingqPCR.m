mkdir('/Users/fjavierdha/Documents/MATLAB')

warning ('on','all')



listConditions = {'Noth OFF wRi', 'Notch ON wRi', 'Notch ON skdRi',  'Notch ON ktoRi'};


path = uigetdir()


parentdirectory = dir(append(path, '/*.csv'));


 
qpcrdata = readmatrix(append(parentdirectory(1).folder, '/', parentdirectory(1).name));

qpcrdata = qpcrdata(2:end, 2:end)



blue = [0 0.5 1];
red = [1 0.2 0.2];
green = [0.11 0.7 0.32];
orange = [1 0.58 0.01];
purple = [0.74 0.01 1];
MyColorMap = [purple; green; red; blue];

tl = tiledlayout(1, 3,'TileSpacing','Compact');

All = [] ;
for n = 3:size(qpcrdata, 1);


genotype1 = qpcrdata(n,1:2);
genotype2 = qpcrdata(n, 3:5);
genotype3 = qpcrdata(n,6:8);
genotype4 = qpcrdata(n, 9:10);
All = padconcatenation(genotype1.', genotype2.', 2);
All = padconcatenation(All, genotype3.', 2);
All = padconcatenation(All, genotype4.', 2);

nexttile
hold off

plotBoxplot(All, listConditions, listConditions, 0.5 , 0.25, 'm', 14, 14, MyColorMap, 0.3, 5, 18, [0, 350])

end 


% plotBoxplot(All,Nicknames,ExpLabels,Jitter,BarW,Title,FontSize,DotSize,CMAP,FaceAlpha,LineWidth,FontSizeTitle,Ylim)
% 
% plotBoxplot('All', AllMatrix, 'Nicknames', listConditions, 'ExpLabels', listConditions, ...
%          'Jitter', 0.5 , 'BarW', 0.01, 'Title', 'MamGFP intensity with MedKDs', 'FontSize', 5,...
%          'DotSize',  2, 'CMAP',  [0.1, 1, 0.1], 'LineWidth',  1, 'FontSizeTitle', 1, ...
%          'Ylim', [0, 10])
%     

orient(gcf,'landscape');
saveas(gcf, append(path, "/","boxplot with average intensities.pdf"));

%%

[h,p,ci,stats] = ttest(AllMatrix(:, 1), AllMatrix(:, 2))
[h,p,ci,stats] = ttest(AllMatrix(:, 1), AllMatrix(:, 3))
