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
                occupiedBy={}
            }
        end
    end

    self:markPlayerTiles(grid,1) --occupy tiles surrounding player

    return grid 
end

local getTileCoords=function(self,pos) 
    local tileX=floor(((pos.x-self.spawnArea.x)/self.tileSize)+1)
    local tileY=floor(((pos.y-self.spawnArea.y)/self.tileSize)+1)
    return tileX,tileY
end

local markPlayerTiles=function(self,grid,radius)
    local tileX,tileY=self:getTileCoords(Player)
    local distanceFromPlayer=radius
    for x=-distanceFromPlayer,distanceFromPlayer do
        if grid[tileX+x] then 
            for y=-distanceFromPlayer,distanceFromPlayer do 
                if grid[tileX+x][tileY+y] then 
                    table.insert(grid[tileX+x][tileY+y].occupiedBy,'player')
                end 
            end
        end
    end
end

local clearPlayerTiles=function(grid)
    for row=1,#grid do 
        for col=1,#grid[row] do 
            for i=1,#grid[row][col].occupiedBy do 
                local occupier=grid[row][col].occupiedBy[i]
                if occupier=='player' then
                    table.remove(grid[row][col].occupiedBy,i)
                end
            end
        end
    end
end

--returns the tileSize of an object
local getTileSize=function(self,def) 
    local tileW=ceil(def.w/self.tileSize)
    local tileH=ceil(def.h/self.tileSize)
    return {w=tileW,h=tileH} 
end

--returns the tileSize of an object with a 1-tile surrounding border
local getBorderedTileSize=function(self,def)
    local tileW=ceil((def.w+self.tileSize*2)/self.tileSize)
    local tileH=ceil((def.h+self.tileSize*2)/self.tileSize)
    return {w=tileW,h=tileH}
end

--takes in a grid of tiles and returns a table of all tiles that aren't taken
--and which can be used to spawn an object of a certain tile size. A tile can
--be considered taken or available depending on the type of object to check for.
local getAvailableTiles=function(self,grid,objectTileSize,type)
    local tiles={}
    --loop through grid. if a certain tile and all of its adjacent tiles that
    --would be taken up by the terrain object aren't taken, add tile to table.
    for col=1,#grid do 
        for row=1,#grid[col] do
            local tileTaken=false 
            for i=0, objectTileSize.w-1 do 
                for j=0, objectTileSize.h-1 do 
                    if grid[col+i] and grid[col+i][row+j] then
                        if self.isOccupied(
                            grid[col+i][row+j],self.tileOccupiedKey[type]
                        ) then tileTaken=true end
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

--[key] cannot occupy a tile already taken by any of the types in its table.
local tileOccupiedKey={
    terrain={'player','terrain','border','decoration'},
    decoration={'terrain','decoration'},
    enemy={'player','terrain'}
}

--checks if any element of key is in tile.occupiedBy
local isOccupied=function(tile,key)
    if #key==0 then return false end
    local res=false
    for i=1,#tile.occupiedBy do 
        for j=1,#key do 
            if tile.occupiedBy[i]==key[j] then res=true end
        end
    end
    return res
end

local throughoutTiles=function(self,x,y,w,h,tileSize)
    local smallRect={w=w,h=h}
    local bigRect={w=tileSize.w*self.tileSize,h=tileSize.h*self.tileSize}
    local maxX=(bigRect.w-smallRect.w) 
    local maxY=(bigRect.h-smallRect.h)
    return x+rnd()*maxX, y+rnd()*maxY
end

--spawns the map terrain, using getAvailableTiles() to ensure terrain 
--objects never spawn on top of one another.
local generateTerrain=function(self,mapTerrain,terrainClass,grid)
    for name,maxCount in pairs(mapTerrain) do 
        --terrain has a 1-tile size surrounding border
        local terrainDef=terrainClass.definitions[name]
        local terrainTileSize=self:getBorderedTileSize(terrainDef)
        local availableTiles=self:getAvailableTiles(grid,terrainTileSize,'terrain')    

        for i=1,rnd(maxCount) do 
            if #availableTiles>0 then
                --select a tile at which to spawn the terrain object
                local selectedIndex=rnd(#availableTiles)
                local selectedTile=availableTiles[selectedIndex]
                local tileX,tileY=self:getTileCoords(selectedTile)

                --spawn the terrain object somewhere throughout its tiles, 
                --taking into account the 1-tile surrounding border
                local spawnX,spawnY=self:throughoutTiles(                    
                    selectedTile.x+self.tileSize,selectedTile.y+self.tileSize,
                    terrainDef.w,terrainDef.h,self:getTileSize(terrainDef)
                )
                terrainClass:new(name,spawnX,spawnY)
    
                --update grid to reflect tiles taken by terrain, rebuild availableTiles
                for j=0,terrainTileSize.w-1 do --occupy tiles with 'border'
                    for k=0,terrainTileSize.h-1 do                     
                        table.insert(grid[tileX+j][tileY+k].occupiedBy,'border') 
                    end
                end
                for j=1,terrainTileSize.w-2 do --occupy tiles with 'terrain'
                    for k=1,terrainTileSize.h-2 do                     
                        table.remove(grid[tileX+j][tileY+k].occupiedBy) --remove 'border'
                        table.insert(grid[tileX+j][tileY+k].occupiedBy,'terrain') 
                    end
                end
                if i<maxCount then --don't rebuild after last of a certain terrain
                    availableTiles=self:getAvailableTiles(
                        grid,terrainTileSize,'terrain'
                    )
                end
            else 
                print('no more tiles available to spawn '..name) 
                break
            end
        end
    end
end

local generateDecorations=function(self,mapDecorations,decorationsClass,grid)
    local decorations={}

    for name,maxCount in pairs(mapDecorations) do 
        local decorTileSize=self:getTileSize(decorationsClass.definitions[name])
        local availableTiles=self:getAvailableTiles(grid,decorTileSize,'decoration')    

        for i=1,rnd(maxCount) do 
            if #availableTiles>0 then
                --select a tile at which to spawn the decoration object
                local selectedIndex=rnd(#availableTiles)
                local selectedTile=availableTiles[selectedIndex]
                local tileX,tileY=self:getTileCoords(selectedTile)
                table.insert( decorations,
                    decorationsClass:new(
                        name,selectedTile.x,selectedTile.y
                    )
                )
    
                --update grid and availableTiles to reflect tiles taken by decoration
                if decorTileSize.w==1 and decorTileSize.h==1 then 
                    table.remove(availableTiles,selectedIndex)
                    table.insert(grid[tileX][tileY].occupiedBy,'decoration')
                else
                    --if decoration is larger than tileSize={1,1}, then mark all 
                    --appropriate tiles in grid as taken, rebuild availableTiles
                    for j=0,decorTileSize.w-1 do 
                        for k=0,decorTileSize.h-1 do                     
                            table.insert(grid[tileX+j][tileY+k].occupiedBy,'decoration')
                        end
                    end
                    if i<maxCount then --don't rebuild after last of a certain decoration
                        availableTiles=self:getAvailableTiles(grid,decorTileSize,'decoration')
                    end
                end
            else 
                print('no more tiles available to spawn '..selectedDecor) 
                break
            end
        end
    end

    return decorations
end

local generateEnemies=function(self,enemyWave,entitiesClass,grid)
    --update grid with the tile currently occupied by player
    self.clearPlayerTiles(grid)
    self:markPlayerTiles(grid,3)

    for name,count in pairs(enemyWave) do 
        local enemyColliderDef=entitiesClass.definitions[name].collider
        local enemyTileSize=self:getTileSize(enemyColliderDef)
        local availableTiles=self:getAvailableTiles(grid,enemyTileSize,'enemy')

        for i=1,count do 
            if #availableTiles>0 then
                --select a tile at which to spawn the decoration object
                local selectedIndex=rnd(#availableTiles)
                local selectedTile=availableTiles[selectedIndex]
                local tileX,tileY=self:getTileCoords(selectedTile)
                local spawnX,spawnY=self:throughoutTiles(
                    selectedTile.x,selectedTile.y,
                    enemyColliderDef.w,enemyColliderDef.h,enemyTileSize
                )
                entitiesClass:new(name,spawnX,spawnY)
            else print('no available tiles for '..name) break end
        end
    end
end

return { --The Module  
    tileSize=16,
    spawnArea={},
    generate=generate,
    getTileCoords=getTileCoords,
    getTileSize=getTileSize,
    markPlayerTiles=markPlayerTiles,
    clearPlayerTiles=clearPlayerTiles,
    getBorderedTileSize=getBorderedTileSize,
    getAvailableTiles=getAvailableTiles,
    tileOccupiedKey=tileOccupiedKey,
    isOccupied=isOccupied,
    throughoutTiles=throughoutTiles,
    generateTerrain=generateTerrain,
    generateDecorations=generateDecorations,
    generateEnemies=generateEnemies,
}