--divides a map's spawnArea into a grid of tiles. Returns the grid
local generate=function(self,spawnArea,startPos)
    self.spawnArea=spawnArea
    local grid={}

    local tileSize=self.tileSize
    for col=1, spawnArea.w/tileSize do
        grid[col]={}
        for row=1, spawnArea.h/tileSize do 
            grid[col][row]={
                x=spawnArea.x+(col-1)*tileSize,
                y=spawnArea.y+(row-1)*tileSize,
                taken=false
            }
        end
    end

    --flag tiles surrounding startPos as taken
    local tileX,tileY=self:getTileCoords(startPos)
    local distanceFromStartPos=3
    for x=-distanceFromStartPos,distanceFromStartPos do
        if grid[tileX+x] then 
            for y=-distanceFromStartPos,distanceFromStartPos do 
                if grid[tileX+x][tileY+y] then 
                    grid[tileX+x][tileY+y].taken=true 
                end 
            end
        end
    end

    return grid 
end

local getTileCoords=function(self,pos) 
    local tileX=((pos.x-self.spawnArea.x)/self.tileSize)+1 
    local tileY=((pos.y-self.spawnArea.y)/self.tileSize)+1
    return tileX,tileY
end

--returns the tileSize of an object
local getTileSize=function(def) return {w=ceil(def.w/16),h=ceil(def.h/16)} end

--returns the tileSize of an object with a 1-tile surrounding border
local getBorderedTileSize=function(def)
    local tileW=ceil((def.w+32)/16)
    local tileH=ceil((def.h+32)/16)
    return {w=tileW,h=tileH}
end

--takes in a grid of tiles and returns a table of all tiles that aren't taken
--and which can be used to spawn a terrain object of a certain tile size.
local getAvailableTiles=function(grid,tileSize)
    local tiles={}
    --loop through grid. if a certain tile and all of its adjacent tiles that
    --would be taken up by the terrain object aren't taken, add tile to table.
    for col=1,#grid do 
        for row=1,#grid[col] do
            local tileTaken=false 
            for i=0, tileSize.w-1 do 
                for j=0, tileSize.h-1 do 
                    if grid[col+i] and grid[col+i][row+j] then 
                        if grid[col+i][row+j].taken then tileTaken=true end
                    else
                        tileTaken=true 
                    end
                end
            end
            if not tileTaken then table.insert(tiles,grid[col][row]) end
        end
    end
    return tiles 
end

--spawns the map terrain, using getAvailableTiles() to ensure terrain 
--objects never spawn on top of one another.
local generateTerrain=function(self,mapTerrain,terrainClass,grid)
    for name,count in pairs(mapTerrain) do 
        local tileSize=self.getBorderedTileSize(terrainClass.definitions[name])
        local availableTiles=self.getAvailableTiles(grid,tileSize)        

        for i=1,count do 
            if #availableTiles>0 then
                --select a tile at which to spawn the terrain object
                local selectedIndex=rnd(#availableTiles)
                local selectedTile=availableTiles[selectedIndex]
                local tileX,tileY=self:getTileCoords(selectedTile)
                terrainClass:new(name,selectedTile.x+16,selectedTile.y+16)
    
                --update grid and availableTiles to reflect tiles taken by terrain
                if tileSize.w==1 and tileSize.h==1 then 
                    table.remove(availableTiles,selectedIndex)
                    grid[tileX][tileY].taken=true
                else
                    --if terrain is larger than tileSize={1,1}, then mark all 
                    --appropriate tiles in grid as taken, rebuild availableTiles
                    for j=0,tileSize.w-1 do 
                        for k=0,tileSize.h-1 do                     
                            grid[tileX+j][tileY+k].taken=true 
                        end
                    end
                    if i<count then --don't rebuild after last of a certain terrain
                        availableTiles=self.getAvailableTiles(grid,tileSize)
                    end
                end
            else 
                print('no tiles available to spawn '..name)
            end
        end
    end
end

return { --The Module  
    tileSize=16,
    spawnArea={},
    generate=generate,
    getTileCoords=getTileCoords,
    getTileSize=getTileSize,
    getBorderedTileSize=getBorderedTileSize,
    getAvailableTiles=getAvailableTiles,
    generateTerrain=generateTerrain,
}