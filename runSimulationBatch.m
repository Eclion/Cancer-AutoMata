function runSimulationBatch(handles, rootFolder, mesenchymalPercentages, dishSize, dishHeight, initNbCells, nbSimulations, nbSteps, survival, birth, enableSnapshots, enable3DSnapshots, snapshotSteps, model)

backupConfig(rootFolder, mesenchymalPercentages, dishSize, dishHeight, initNbCells, nbSimulations, nbSteps, survival, birth, enableSnapshots, enable3DSnapshots, snapshotSteps, model);

names = {'WT' 'TRAIL' 'TR+BIM'};
colors = 'brg';

if strcmp(model,'modelC')
    means = [0.92  0.29 0.0125];
else
    means = [1  0.59 0.05];
end

defaultMesenchymalPercentages = [2, 10, 95];

totalNumberOfSimulations = length(names) * nbSimulations * max(length(mesenchymalPercentages),1);
emptyMesenchymalPercentageInput = isempty(mesenchymalPercentages);

for k=1:max(length(mesenchymalPercentages),1)
    if(isstruct(handles))
        axes(handles.curvesPlot);
        cla reset;
    end
    
    mesenchymalPercentage = 0;
    if(~emptyMesenchymalPercentageInput)
        mesenchymalPercentage = mesenchymalPercentages(k);
    end
    
    curvesData = zeros(length(names),nbSimulations,nbSteps+1);
    
    for j=1:length(names)
        if(emptyMesenchymalPercentageInput)
            mesenchymalPercentage = defaultMesenchymalPercentages(j);
        end
        pts = zeros(nbSimulations,nbSteps+1);
        
        treatmentName = char(names(j));
        
        simulationName = strcat(treatmentName, '_with_',num2str(mesenchymalPercentage), '%MCells');
        
        snapshotFolder = strcat(rootFolder, simulationName, '_snapshots/');
        
        data = zeros(2,nbSimulations);
        mPercents = zeros(nbSimulations,nbSteps+1);
        for i = 1:nbSimulations
            simulationIndex = i + (j-1)*nbSimulations + (k-1)*length(names)*nbSimulations
            
            if(isstruct(handles))
                set(handles.progressText, 'string', strcat('Current simulation: ', simulationName, '(', num2str(simulationIndex), '/', num2str(totalNumberOfSimulations), ')'));
                drawnow;
            end
            
            [a,b,c]=simulateCancer(enableSnapshots, enable3DSnapshots, dishSize,dishHeight,initNbCells,snapshotSteps,means(j),survival, birth,mesenchymalPercentage,snapshotFolder,nbSteps,model);
            
            data(1,i) = a;
            data(2,i) = b(nbSteps+1)/min(b);
            
            pts(i,:) = b;
            
            if(isstruct(handles))
                plot(0:nbSteps,b(:), 'Color',colors(j), 'LineWidth',5);hold on;
                drawnow;
            end
            
            mPercents(i,:)=c;
        end
        curvesData(j,:,:) = pts;
        
        % save of the workspace's data(ratio/simu, growth rate /simu) and pts(nb of cells per steps / simu) variables
        save(strcat(rootFolder, simulationName, '.mat'), 'data', 'pts', 'mPercents');
    end
    
    if(emptyMesenchymalPercentageInput)
        saveFigure(rootFolder, names, colors, curvesData, '');
    else
        saveFigure(rootFolder, names, colors, curvesData, num2str(mesenchymalPercentage));
    end
end

if(isstruct(handles))
    set(handles.progressText, 'string', strcat(num2str(totalNumberOfSimulations), ' done.'));
    drawnow;
end

end


function saveFigure(rootFolder, names, colors, points, mesenchymalPercentage)

global isMatlab;
if(isMatlab)
    f=figure('visible', 'off');
else
    f=figure();
end
for i=1:length(names)
    for j=1:size(points, 2)
        pts = points(i,j,:);
        plot(0:(length(pts)-1),pts(:), 'Color',colors(i), 'LineWidth',5);hold on;
    end
end
xlabel('Time (in steps)')
ylabel('Number of cells')
if isempty(mesenchymalPercentage)
    saveas(f,strcat(rootFolder, '/curves.png'));
else
    saveas(f,strcat(rootFolder, '/curves_with_',mesenchymalPercentage, '%MCells.png'));
end
close(f);

end

function backupConfig(rootFolder, mesenchymalPercentages, dishSize, dishHeight, initNbCells, nbSimulations, nbSteps, survival, birth, enableSnapshots, enable3DSnapshots, snapshotSteps,model)

backupFileID = fopen(strcat(rootFolder, 'config.ini'), 'wt');


fprintf(backupFileID, 'MODEL : %s;\n', model);
fprintf(backupFileID, 'SAVE_SNAPSHOTS : %d;\n', enableSnapshots);
fprintf(backupFileID, 'SAVE_3D_SNAPSHOTS : %d;\n', enable3DSnapshots);
fprintf(backupFileID, 'MAX_BIRTH : %d;\n', max(birth));
fprintf(backupFileID, 'MIN_BIRTH : %d;\n', min(birth));
fprintf(backupFileID, 'MIN_SURVIVAL : %d;\n', min(survival));
fprintf(backupFileID, 'MAX_SURVIVAL : %d;\n', max(survival));
fprintf(backupFileID, 'NB_STEPS : %d;\n', nbSteps);

if(~isempty(snapshotSteps))
    fprintf(backupFileID, 'SNAPSHOT_STEPS : %s;\n', mat2str(snapshotSteps));
end

if(~isempty(mesenchymalPercentages))
    fprintf(backupFileID, 'PERCENTAGE_MESENCHYMAL : %s;\n', mat2str(mesenchymalPercentages));
end

fprintf(backupFileID, 'DISH_SIZE : %d;\n', dishSize);
fprintf(backupFileID, 'DISH_HEIGHT : %d;\n', dishHeight);
fprintf(backupFileID, 'NB_SIMULATIONS : %d;\n', nbSimulations);
fprintf(backupFileID, 'INIT_NB_CELLS : %d;\n', initNbCells);

fprintf(backupFileID, 'END;');
fclose(backupFileID);

end
