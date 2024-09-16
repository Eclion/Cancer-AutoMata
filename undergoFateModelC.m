function newStepCells = undergoFateModelC(x,y,z,cells, newStepCells,survivalRules,birthRules)
% determine the fate of the cell at position x,y,z, in function of the previous state for the birth/survival rule, but also in function of its current state, to see if it can move or not

% Model C rules from "Defining rules for cancer cell proliferation in TRAIL stimulation", Available from: https://www.researchgate.net/publication/331128049_Defining_rules_for_cancer_cell_proliferation_in_TRAIL_stimulation.
% i. Any E cell with less than min(survivalRules)(four in paper) live neighbors become M cell on the next generation.
% ii. Any M cell with more than max(survivalRules)(eight in paper) live neighbors become E cell on the next generation.
% iii. Any dead/empty cell with min(birthRules)(two in paper) to max(survivalRules)(six in paper) live neighbors (E or M) becomes live cell (E or M) as by division.
% iv. Any M cell is able to move randomly to an empty cell on to the next generation.
% v. Any M cell that is unable to move becomes an E cell on to the next generation.

nz=size(cells,3);
dz=max(1,z-1):min(nz,z+1);

neighbors(:,:) = calculateNeighbors(x,y,cells);
eNeighbors = neighbors(:,2);
mNeighbors = neighbors(:,1);
nNeighbors = eNeighbors + mNeighbors;

if(cells(x,y,z)==0) %if there is no cell at grid(x,y), then check if a new one can live
    if (any(sum(nNeighbors(dz)) == birthRules)) % rule iii)
        if (sum(eNeighbors)>sum(mNeighbors))
            newStepCells(x,y,z)=2;% an epithelial cell is born
        else
            newStepCells(x,y,z)=1;% a mesenchymal cell is born
        end
    end
elseif(cells(x,y,z)==2) %if there is a living E cell at grid(x,y,z)
    if (sum(nNeighbors(dz))-1 < min(survivalRules))
        newStepCells(x,y,z) = 1; % rule i)
    else
        newStepCells(x,y,z)=cells(x,y,z);
    end
elseif(cells(x,y,z)==1) %if there is a living M cell at grid(x,y,z)
    if (sum(nNeighbors(dz))-1 > max(survivalRules))
        newStepCells(x,y,z) = 2; % rule ii)
    else
        availableNeighborPositions=listAvailableNeighborPositions(cells,newStepCells,x,y,z);
        rp=rand();
        availableNeighborPositionCount=size(availableNeighborPositions,1);
        if(availableNeighborPositionCount~=0) % rule iv)
            index=round(rp*(availableNeighborPositionCount-1))+1;
            nextPosition=availableNeighborPositions(index,:);
            
            newStepCells(nextPosition(1),nextPosition(2),nextPosition(3)) = 1;
            newStepCells(x,y,z) = 0;
        else % rule v)
            newStepCells(x,y,z) = 2;
        end
    end
end

end

