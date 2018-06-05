function list = listAvailableNeighborPositions(cells, nextStepCells, x, y, z)

dx=max(1,x-1):min(size(cells,1),x+1);
dy=max(1,y-1):min(size(cells,2),y+1);
dz=max(1,z-1):min(size(cells,3),z+1);
list=[];

for i=dx
    for j=dy
        for k=dz
            if(cells(i,j,k)==0 && nextStepCells(i,j,k)==0)
                list(size(list,1)+1,1:3)=[i j k];
            end
        end
    end
end
end