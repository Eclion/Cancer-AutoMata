function newStepCells = undergoFateModelB(x,y,z,cells, newStepCells,survivalRules,birthRules)
%determine the fate of the cell at position x,y,z, in function of the previous state for the birth/survival rule, but also in function of its current state, to see if it can move or not

nz=size(cells,3);
dz=max(1,z-1):min(nz,z+1);

neighbors(:,:) = calculateNeighbors(x,y,cells);
eNeighbors = neighbors(:,2);
mNeighbors = neighbors(:,1);
nNeighbors = eNeighbors + mNeighbors;

if(cells(x,y,z)==0) %if there is no cell at grid(x,y), then check if a new one can live
    if (any(sum(nNeighbors(dz)) == birthRules))
        if (sum(eNeighbors)>sum(mNeighbors))
            newStepCells(x,y,z)=2;% an epithelial cell is born
        else
            newStepCells(x,y,z)=1;% a mesenchymal cell is born
        end
    end
elseif(cells(x,y,z)~=0)%else %if there is a cell at grid(x,y)
    if (~any(sum(nNeighbors(dz))-1 == survivalRules) && cells(x,y,z)==2) % '-1' because the current cell is living
        newStepCells(x,y,z) = 0;
    elseif (any(sum(nNeighbors(dz))-1 == survivalRules) && cells(x,y,z)==2) % '-1' because the current cell is living
        newStepCells(x,y,z) = 1;
    elseif (cells(x,y,z)==1)%movement of the cells
        availableNeighborPositions=listAvailableNeighborPositions(cells,newStepCells,x,y,z);
        rp=rand();%random number for the direction of the movement.
        availableNeighborPositionCount=size(availableNeighborPositions,1);
        if(availableNeighborPositionCount~=0)
            index=round(rp*(availableNeighborPositionCount-1))+1;
            nextPosition=availableNeighborPositions(index,:);
            
            newStepCells(nextPosition(1),nextPosition(2),nextPosition(3)) = 1;
            newStepCells(x,y,z) = 0;
        else
            newStepCells(x,y,z) = 2;
        end
        
        
    else
        newStepCells(x,y,z) = cells(x,y,z);
    end
end
end