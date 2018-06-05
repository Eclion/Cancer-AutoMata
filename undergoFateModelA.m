function newStepCells = undergoFateModelA(x,y,z,cells, newStepCells,survivalRules,birthRules)
%determine the fate of the cell at position x,y,z, in function of the previous state for the birth/survival rule, but also in function of its current state, to see if it can move or not

    nz=size(cells,3);
    dz=max(1,z-1):min(nz,z+1);
    
    neighbors(:,:) = calculateNeighbors(x,y,cells);
    eNeighbors = neighbors(:,2);
    nNeighbors = eNeighbors;
        
    if(cells(x,y,z)==0) %if there is no cell at grid(x,y), then check if a new one can live
        if (any(sum(nNeighbors(dz)) == birthRules))
                newStepCells(x,y,z)=2;% an epithelial cell is born
        end
    elseif(cells(x,y,z)==2) && (~any(sum(nNeighbors(dz))-1 == survivalRules))
        newStepCells(x,y,z) = 0;
    end
end