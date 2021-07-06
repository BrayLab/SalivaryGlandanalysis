%%personal startup
mkdir('/Users/fjavierdha/Documents/MATLAB')

warning ('off','all')

f = filesep


Path = uigetdir()  %set the parent folder that contains the folders with the lifs files

Parentdirectory = dir(Path)

Listdirectory = [];

for t = 1:length({Parentdirectory.name}) %this loop is to get the folder that will contain many folders at the same time with the diffrent replicates
    
    if  Parentdirectory(t).name(1) == "." %this avoids all the folders that are part of the system and begin with ".", ie '.DS_Store'
    
    elseif contains(Parentdirectory(t).name, ".csv")
        
      Listdirectory = [Listdirectory, dir(append(Parentdirectory(t).folder, f , Parentdirectory(t).name))];
    
    end
%     directoryonlycsv = {};
    
end
% 
% listFiles = {'Check if quantifications have been done', 'Do not check if quantifications have been done'};
% 
% [indx,tf] = listdlg('ListString',listFiles);
% 
%     if isequal('Check if quantifications have been done', listFiles{indx});
% 
%         Override = [];
% 
%     elseif isequal('Do not check if quantifications have been done', listFiles{indx});
%         
%         Override = [1];
%         
%     end



IDR = readtable( append(Listdirectory(1).folder, f,  Listdirectory(2).name));

figure('Color', 'none')
set(gcf, 'Position',  [100, 100, 1000, 400])
hold on 
xlabel('Amino acid position', 'FontSize', 20);

ylabel('Disordered prediction', 'FontSize', 20);

ylim([0, 1])
position = IDR{1500:end,1};

xlim([1500 position(end)]);
iupred = IDR{1500:end,2};
plot(position, iupred, '-', 'color', [126/255 101/255 157/255], 'LineWidth', 3);

% Width = 0.03;
% topcurve = (iupred + Width).';
% lowercurve = (iupred - Width).';
% 
% pfill1 = fill([position.' fliplr(position.')], [topcurve fliplr(lowercurve)], ...
%              [193/255 37/255 101/255] , 'linestyle', 'none', 'FaceAlpha', .7);

yticks([0:0.1:1])
xticks([0:5:20 50:50:timescale(end)])
xtickangle(45)


halftimedot = plot(timescale(dsearchn(mean(frapmatrix, 2, 'omitnan'),0.5)),0.5,'.', 'MarkerSize', 15, 'color', colour) 

legend(halftimedot,'Points')

 orient(gcf,'landscape');
 saveas(gcf, append(Path,f, 'NICD IDR.pdf'));


