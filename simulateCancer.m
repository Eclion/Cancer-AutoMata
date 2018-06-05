function [ratio,nbCells,Mpercents] = simulateCancer(save2DSnapshots, save3DSnapshots, dishSize, dishHeight, initialNumberOfCells, snapshotSteps,mean,survivalRules, birthRules, pMesen,folder,nbSteps,model)
% In :
%   * dishSize                - size of the square dish
%   * dishHeight              - height of the dish (and of the cancer)
%   * initialNumberOfCells    - number of cells at step = 0
%   * snapshotSteps           - integer[]. Logical times where we want the a
%                               snapshot of the simulation to be saved
%   * birthRules              - integer[]. Game-of-Life-like rules for the cell reproduction
%   * survivalRules           - integer[]. Game-of-Life-like rules for the cell survival
%   * pMesen                  - percentage of mesenchymal cells at the start of the simulation
%                               between 0 and 100
%   * folder                  - root folder where the data & pictures will be saved
%   * nbSteps                 - the number of steps the simulation will
%                               be ran.
%   * save2DSnapshots         - boolean. set to true if 2D snapshots of
%                               the dish need to be saved.
%   * save3DSnapshots         - boolean. set to true if 3D snapshots of
%                               the dish need to be saved.
%   * mean                    - the mean number of cells after treatment
%
% Out :
%   * ratio       - float. Ratio of cells living after TRAIL under the
%                   number of cells living before TRAIL (average pS)
%   * nbCells     - integer[]. Number of cells, at each step
%   * Mpercents   - percentage of mesenchymal cells for each steps

%creation of the folder if it doesn't exist
if(~strcmp(folder,'') && ~isempty(snapshotSteps))
    if(~exist(folder,'dir'))
        mkdir(folder);
    end
end

if strcmp(model,'modelA')
    undergoFate=@undergoFateModelA;
    pMesen=0;
elseif strcmp(model,'modelB')
    undergoFate=@undergoFateModelB;
else
    undergoFate=@undergoFateModelC;
end

%This variable "zoom" is used to scale up the picture gotten from the CA
zoom = 2;

%number of cells, calculated at each steps so we can trace the population
%if nbCells is different of 0 at start, the program will create the
%cells on the basis that nbCells are under the treatment. Please notice
%that these cells will be distributed in a disk.
nbCells=zeros(nbSteps+1,1);

Mpercents=zeros(1,nbSteps+1);

%setup of the CA's variables
cells=zeros(dishSize,dishSize,dishHeight);% 2: epithelial cells / 1: mesenchymal cells

spacingOffset = 0.6;
radius=sqrt(initialNumberOfCells/(spacingOffset*pi));

for i=1:dishSize
    for j=1:dishSize
        %for each gridcell, a random number in the gamma
        %distribution pS is drawn, and another random number is
        %drawn from an uniform distribution, between 0 and 1. By
        %comparing these two number, we can have an average number
        %of cells corresponding to pS.
        if (rand() < spacingOffset*mean) && ((((i-dishSize/2)^2 +(j-dishSize/2)^2) < (radius^2)))
            if (rand() < pMesen/100)
                cells(i,j,1)=1;
            else
                cells(i,j,1)=2;
            end
        end
    end
end


nbCells(1)=sumCells(cells, 1) + sumCells(cells, 2);%initial (after treatment) number of cells
if(nbCells(1) ~= 0)%if there is still some cells, we calculate the percentage of MCells
    Mpercents(1) = sumCells(cells, 1)/nbCells(1);
else
    Mpercents(1)=0;
end

ratio=nbCells(1)/initialNumberOfCells;%calculate the ratio of cells at this step compared to the initial number of cells

if(any(snapshotSteps==0))
    if(save2DSnapshots)
        saveSnapshot(zoom, folder, cells, 0)
    end
    if(save3DSnapshots) % for the 3D plot
        drawAndSave3DPlot(cells, folder,0);
    end
end

for step = 1:nbSteps % main loop
    tic
    
    nextStepCells = cells;%we save the cancer current state
    
    %we make a random order for the cell's simulation
    order=randperm(dishSize^2);
    x=mod(order,dishSize)+1;
    y=mod(order/dishSize,dishSize)-mod(order/dishSize,1)+1;
    for i=1:dishSize^2 % and then we simulate each cell
        for j=1:dishHeight
            nextStepCells = undergoFate(x(i),y(i),j,cells,nextStepCells,survivalRules,birthRules);
        end
    end
    
    cells = nextStepCells; % we replace the previous state by the current one
    
    nbCells(step+1)=sumCells(cells, 1)+sumCells(cells, 2);%calculation of the number of cells at this step
    if(nbCells(step+1) ~= 0)%if there is still some cells, we calculate the percentage of MCells
        Mpercents(step+1) = sumCells(cells, 1)/nbCells(step+1);
    else
        Mpercents(step+1)=0;
    end
    
    %save the snapshot of the cellular automata
    if(any(step == snapshotSteps))%if step correspond at the time where we want to get picture
        if(save2DSnapshots)
            saveSnapshot(zoom, folder, cells, step)
        end
        if(save3DSnapshots) % for the 3D plot
            drawAndSave3DPlot(cells, folder, step);
        end
    end
    toc
end
end

% --------------- GRAPHIC RELATED METHODS -----------------

function saveSnapshot(zoom, folder, cells, step)
[red,green,blue]=cellsToRGB(cells);
[red2,green2,blue2] = zoomRGB(red,green,blue,zoom);
imwrite(cat(3,red2,green2,blue2),strcat(folder,'2D_snapshot_at_step_',num2str(step,'%04.0f'),'.png'));
end

% zoom the picture matrice
function [r2,g2,b2] = zoomRGB(r,g,b,zoom)
w=size(r,1);
h=size(r,2);
w2=w*zoom;
h2=h*zoom;
r2=zeros(w2,h2);
g2=zeros(w2,h2);
b2=zeros(w2,h2);

for i=1:w
    for j=1:h
        itt=(i-1)*zoom+1:i*zoom;
        jtt=(j-1)*zoom+1:j*zoom;
        r2(itt,jtt)= r(i,j);
        g2(itt,jtt)= g(i,j);
        b2(itt,jtt)= b(i,j);
    end
end

end

% get the RGB matrice from the cells
function [r,g,b] = cellsToRGB(cells)
[x,y,z] = size(cells);
r = zeros(x,y);
g = zeros(x,y);
b = zeros(x,y);
for k = 1:z
    for i = 1:x
        for j = 1:y
            if cells(i,j,k)==0
                continue;
            else
                r(i,j) = (cells(i,j,k)==1);
                g(i,j) = (cells(i,j,k)==2);
                b(i,j) = (cells(i,j,k)==3);
            end
        end
    end
end
end

%function for the 3D plot
function drawAndSave3DPlot(cells, folder, step)
[x,y,z] = size(cells);

vertices = [0 0 0; 0 1 0; 1 1 0; 1 0 0; 0 0 1; 0 1 1; 1 1 1; 1 0 1];
dx = [1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0];
dy = [0 1 0; 0 1 0; 0 1 0; 0 1 0; 0 1 0; 0 1 0; 0 1 0; 0 1 0];
dz = [0 0 1; 0 0 1; 0 0 1; 0 0 1; 0 0 1; 0 0 1; 0 0 1; 0 0 1];
faces = [1 2 3 4; 2 6 7 3; 4 3 7 8; 1 5 8 4; 1 2 6 5; 5 6 7 8];
f = figure();
patch('Faces',faces,'Vertices',vertices,'FaceAlpha',0.0, 'EdgeAlpha',0.0);
patch('Faces',faces,'Vertices',vertices+(x-1)*dx + (y-1)*dy + (2*z-1)*dz,'FaceAlpha',0.0, 'EdgeAlpha',0.0);
for i = 1:x
    for j = 1:y
        for k = 1:z
            if cells(i,j,k) == 1
                patch('Faces',faces,'Vertices',vertices+(i-1)*dx + (j-1)*dy + (k-1)*dz,'FaceColor','r');
            elseif cells(i,j,k) == 2
                patch('Faces',faces,'Vertices',vertices+(i-1)*dx + (j-1)*dy + (k-1)*dz,'FaceColor','g');
            end
        end
    end
end
view(30,30);
saveas(f,strcat(folder, '3D_snapshot_at_step_',num2str(step,'%04.0f'),'.png'));
close(f);
end
