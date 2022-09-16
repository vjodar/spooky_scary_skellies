local levelDefinitions={
    { --level 1
        map='forest1',
        wave1={
            pumpkin=5,            
        },
        wave2={
            zombie=5,            
        },
        wave3={
            ent=5,            
        },
    },
}

local bgColors={
    water={92/255,105/255,159/255},
    black={53/255,53/255,64/255},
    lava={229/255,111/255,75/255},
}

local mapDefinitions={
    forest1={
        name='forest1',
        frameWidth=928,
        frameHeight=800,
        sheetWidth=3712,
        sheetHeight=800,
        bgColor=bgColors.water,
        boundaries={
            {x=0,y=0,w=928,h=100}, 
            {x=0,y=693,w=928,h=107},
            {x=0,y=100,w=71,h=593}, 
            {x=857,y=100,w=71,h=593},
        },
        spawnArea={x=80,y=112,w=768,h=576},
        -- playerStartPos={x=432,y=368}, --testing-- center spawn --testing--
        playerStartPos={x=80,y=672}, 
        terrain={
            treeSmall=10,
            treeMedium=10,
            treeLarge=10,
            treePine=10,
            pitWater1=8,
            pitWater2=6,
            pitWater3=4,
        },
    },
}

local generateDrawData=function(defs)
    local sheets,anims={},{}

    for name,def in pairs(defs) do 
        local path='assets/maps/'..name..'.png'
        sheets[name]=love.graphics.newImage(path)

        local grid=anim8.newGrid(def.frameWidth,def.frameHeight,def.sheetWidth,def.sheetHeight)
        anims[name]=anim8.newAnimation(grid('1-4',1), 0.25)
    end

    return sheets,anims 
end
local spriteSheets,animations=generateDrawData(mapDefinitions)

--creates the physical level boundaries that no entity can go
local generateLevelBoundaries=function(boundaries)
    local levelBoundaries={}
    for i=1,#boundaries do 
        local b=boundaries[i]
        b.collisionClass='boundary'
        World:addItem(b)
        table.insert(levelBoundaries,b)
    end
    return levelBoundaries
end

return { --The Module
    terrainClass=require 'src/levels/terrain',
    gridClass=require 'src/levels/grid',
    levelDefinitions=levelDefinitions,
    mapDefinitions=mapDefinitions,
    spriteSheets=spriteSheets,
    animations=animations,
    currentMap={},
    generateLevelBoundaries=generateLevelBoundaries,
    
    update=function(self) 
        self.currentMap.anim:update(dt) 
        --testing-----------------------------
        if dt>0.1 then self:destroyLevel() end
        --testing-----------------------------
    end,    

    draw=function(self) 
        self.currentMap.anim:draw(self.currentMap.spriteSheet,0,0) 
        --testing------------------------------------------------------
        -- for i=1,#self.currentMap.grid do 
        --     for j=1,#self.currentMap.grid[i] do
        --         local tile=self.currentMap.grid[i][j] 
        --         if not tile.taken then 
        --             love.graphics.rectangle('line',tile.x,tile.y,16,16)
        --         end
        --     end
        -- end
        --testing------------------------------------------------------
    end,
    
    buildLevel=function(self,lvl)
        local level=self.levelDefinitions[lvl]
        local map=self.mapDefinitions[level.map]
        local startPos=map.playerStartPos

        love.graphics.setBackgroundColor(map.bgColor)

        --move player to start position
        Player.x,Player.y=startPos.x,startPos.y 
        World:update(Player,Player.x,Player.y)

        --divide the map's spawnArea into a grid, reserving tiles for startPos
        local grid=self.gridClass:generate(map.spawnArea,startPos) 

        --spawn map terrain, using gridClass to ensure no overlap
        self.gridClass:generateTerrain(map.terrain,self.terrainClass,grid)

        self.currentMap={
            spriteSheet=self.spriteSheets[map.name],
            anim=self.animations[map.name],
            levelBoundaries=self.generateLevelBoundaries(map.boundaries),
            grid=grid,
        }
    end,

    destroyLevel=function(self)
        for i=1,#self.currentMap.levelBoundaries do 
            local b=self.currentMap.levelBoundaries[i]
            World:remove(b)
        end
        self.currentMap.levelBoundaries={}
        Objects:clear()
    end,
}