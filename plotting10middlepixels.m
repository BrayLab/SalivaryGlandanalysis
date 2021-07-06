mkdir('/Users/fjavierdha/Documents/MATLAB')

warning ('on','all')


blue = [0 0.5 1];
red = [1 0.2 0.2];
green = [0.11 0.7 0.32];
orange = [1 0.58 0.01];
purple = [0.74 0.01 1];
listConditions = {'wRi', 'skd', 'kto', 'med1'};
listColor = cat(1, green, red, blue ,purple);


nameofmolofinterest = 'med1';
nameofloctag = "loctag ";


path = uigetdir()


parentdirectory = dir(append(path, '/*middle pixels*.txt'));
MeansofConditions = []

 
ktoMeans = readmatrix(append(parentdirectory(1).folder, '/', parentdirectory(1).name));
med1Means = readmatrix(append(parentdirectory(2).folder, '/', parentdirectory(2).name));
skdMeans = readmatrix(append(parentdirectory(3).folder, '/', parentdirectory(3).name));
wMeans = readmatrix(append(parentdirectory(4).folder, '/', parentdirectory(4).name));

AllMatrix = [];

AllMatrix = padconcatenation(AllMatrix, wMeans.', 2)
AllMatrix = padconcatenation(AllMatrix, skdMeans.', 2)
AllMatrix = padconcatenation(AllMatrix, ktoMeans.', 2)
AllMatrix = padconcatenation(AllMatrix, med1Means.', 2)



blue = [0 0.5 1];
red = [1 0.2 0.2];
green = [0.11 0.7 0.32];
orange = [1 0.58 0.01];
purple = [0.74 0.01 1];

MyColorMap = [green; red; blue; orange];

hold on
plotBoxplot(AllMatrix, listConditions, listConditions, 0.5 , 0.25, 'kto 10 middle pixels', 14, 14, MyColorMap, 0.3, 5, 18, [0, 2.1])

% plotBoxplot(All,Nicknames,ExpLabels,Jitter,BarW,Title,FontSize,DotSize,CMAP,FaceAlpha,LineWidth,FontSizeTitle,Ylim)
% 
% plotBoxplot('All', AllMatrix, 'Nicknames', listConditions, 'ExpLabels', listConditions, ...
%          'Jitter', 0.5 , 'BarW', 0.01, 'Title', 'MamGFP intensity with MedKDs', 'FontSize', 5,...
%          'DotSize',  2, 'CMAP',  [0.1, 1, 0.1], 'LineWidth',  1, 'FontSizeTitle', 1, ...
%          'Ylim', [0, 10])
%     

orient(gcf,'landscape');
saveas(gcf, append(path, "/","boxplot middle new.pdf"));

%%

[h, p] = ttest(AllMatrix(:, 1), AllMatrix(:, 2))
[h, p] = ttest(AllMatrix(:, 1), AllMatrix(:, 3))
[h, p] = ttest(AllMatrix(:, 1), AllMatrix(:, 4))


[p, h] = ranksum(AllMatrix(:, 1), AllMatrix(:, 2))
[p, h] = ranksum(AllMatrix(:, 1), AllMatrix(:, 3))
[p, h] = ranksum(AllMatrix(:, 1), AllMatrix(:, 4))
