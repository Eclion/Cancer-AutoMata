function newStepCells = undergoFateModelC( x,y,z,cells, newStepCells,survivalRules,birthRules )
%determine the fate of the cell at position x,y,z, in function of the previous state for the birth/survival rule, but also in function of its current state, to see if it can move or not

nz=size(cells,3);
dz=max(1,z-1):min(nz,z+1);

neighbors(:,:) = calculateNeighbors(x,y,cells);
eNeighbors = neighbors(:,2);
mNeighbors = neighbors(:,1);
nNeighbors = eNeighbors + mNeighbors;

if(cells(x,y,z)==0) %if there is no cell at grid(x,y), then check if a new one can live
    if (any(sum(nNeighbors(dz)) == birthRules)) % rule iv)
        if (sum(eNeighbors)>sum(mNeighbors))
            newStepCells(x,y,z)=2;% an epithelial cell is born
        else
            newStepCells(x,y,z)=1;% a mesenchymal cell is born
        end
    end
elseif(cells(x,y,z)==2)%if there is a living E cell at grid(x,y,z)
    if (sum(nNeighbors(dz))-1 < min(survivalRules))
        newStepCells(x,y,z) = 1; % rule i)
    else
        newStepCells(x,y,z)=cells(x,y,z);
    end
elseif(cells(x,y,z)==1)%if there is a living M cell at grid(x,y,z)
    if (sum(nNeighbors(dz))-1 > max(survivalRules))
        newStepCells(x,y,z) = 2; % rule iii)
    else
        availableNeighborPositions=listAvailableNeighborPositions(cells,newStepCells,x,y,z);
        rp=rand();
        availableNeighborPositionCount=size(availableNeighborPositions,1);
        if(availableNeighborPositionCount~=0) % rule v)
            index=round(rp*(availableNeighborPositionCount-1))+1;
            nextPosition=availableNeighborPositions(index,:);
            
            newStepCells(nextPosition(1),nextPosition(2),nextPosition(3)) = 1;
            newStepCells(x,y,z) = 0;
        else % rule vi)
            newStepCells(x,y,z) = 2;
        end
    end
end

end

