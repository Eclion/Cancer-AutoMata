% this function calculate the number of living (mesenchymal & epithelial) cells for all the gridcell at the position x,y and its surrounding
function neighbors=calculateNeighbors(x,y,grid)
    nx=size(grid,1);
    ny=size(grid,2);
    nz=size(grid,3);
    dx=max(1,x-1):min(nx,x+1);
    dy=max(1,y-1):min(ny,y+1);
    
    neighbors=zeros(nz,2);
    
    for i = 1:nz
        for j= 1:2
            neighbors(i,j) = sumCells(grid(dx,dy,i), j);
        end
    end
end

