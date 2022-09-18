local levelDefinitions={
    test={
        map='swamp1',
        waves={
            {
                pumpkin=10,        
                zombie=10,        
            },
            {
                zombie=10,            
                tombstone=5,            
            },
            {
                spider=10,            
                spiderEgg=10,            
            },
            {
                pumpkin=10,       
                ent=5,  
                headlessHorseman=1,     
            },
        }
    },
}

local bgColors={
    water={92/255,105/255,159/255},
    black={53/255,53/255,64/255},
    lava={229/255,111/255,75/255},
}

local mapDefinitions={
    swamp1={
        name='swamp1',
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
        playerStartPos={x=432,y=368}, --testing-- center spawn --testing--
        -- playerStartPos={x=80,y=672}, 
        terrain={
            -- rockCaveLarge=30,
            treeMedium=20,
            treeLarge=20,
            treePine=20,
            pitWater1=8,
            pitWater2=6,
            pitWater3=4,
            -- mushroomBig=30,
            mushroomSwamp=50,
        },
        decorations={
            swampSmall=200,
            swampBig=10,
        },
    },
}

local generateDrawData=function(defs)
    local sheets,anims={},{}

    for name,def in pairs(defs) do 
        local path='assets/maps/'..name..'.png'
        sheets[name]=love.graphics.newImage(path)

        local grid=anim8.newGrid(
            def.frameWidth,def.frameHeight,def.sheetWidth,def.sheetHeight
        )
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

local increaseEntityCount=function(self,class)
    self.currentLevel[class..'Count']=self.currentLevel[class..'Count']+1
end

local decreaseEntityCount=function(self,class)
    self.currentLevel[class..'Count']=self.currentLevel[class..'Count']-1
end

return { --The Module
    terrainClass=require 'src/levels/terrain',
    gridClass=require 'src/levels/grid',
    decorationsClass=require 'src/levels/decorations',
    levelDefinitions=levelDefinitions,
    mapDefinitions=mapDefinitions,
    spriteSheets=spriteSheets,
    animations=animations,
    currentLevel={},
    generateLevelBoundaries=generateLevelBoundaries,
    increaseEntityCount=increaseEntityCount,
    decreaseEntityCount=decreaseEntityCount,
    
    update=function(self) 
        local level=self.currentLevel 
        level.anim:update(dt) 
        --testing-----------------------------
        if love.timer.getAverageDelta()>0.1 then self:destroyLevel() end
        --testing-----------------------------

        if level.complete then
            return 
        end

        if level.enemyCount==0 then --current wave of enemies defeated

            --no more waves, proceed to next level
            if level.currentWave==#level.definition.waves then 
                level.complete=true 
                print('level complete!')
                return 
            end

            --spawn the next wave of enemies
            level.currentWave=level.currentWave+1
            self.gridClass:generateEnemies(
                level.definition.waves[level.currentWave],Entities,level.grid
            )
        end
    end,    

    draw=function(self) 
        self.currentLevel.anim:draw(self.currentLevel.spriteSheet,0,0) 
        for i=1,#self.currentLevel.decorations do --draw ground decorations
            self.currentLevel.decorations[i]:draw()
        end
        --testing------------------------------------------------------
        -- for i=1,#self.currentLevel.grid do 
        --     for j=1,#self.currentLevel.grid[i] do
        --         local tile=self.currentLevel.grid[i][j] 
        --         if #tile.occupiedBy>0 then 
        --             local o=tile.occupiedBy[1]
        --             if o=='playerSpawn' then love.graphics.setColor(1,0,0)
        --             elseif o=='terrain' then love.graphics.setColor(0,1,0)
        --             elseif o=='border' then love.graphics.setColor(0,0,1)
        --             elseif o=='decoration' then love.graphics.setColor(0,1,1)
        --             end
        --             love.graphics.rectangle('line',tile.x,tile.y,16,16)
        --             love.graphics.setColor(1,1,1,1)
        --         end
        --     end
        -- end
        --testing------------------------------------------------------
    end,
    
    buildLevel=function(self,lvl)
        local levelDef=self.levelDefinitions[lvl]
        local map=self.mapDefinitions[levelDef.map]
        local startPos=map.playerStartPos

        love.graphics.setBackgroundColor(map.bgColor)

        --move player to start position
        Player.x,Player.y=startPos.x,startPos.y 
        World:update(Player,Player.x,Player.y)

        --divide the map's spawnArea into a grid, reserving tiles for startPos
        local grid=self.gridClass:generate(map.spawnArea,startPos) 

        --spawn map terrain, using gridClass to ensure no overlap
        self.gridClass:generateTerrain(map.terrain,self.terrainClass,grid)

        --spawn ground decorations, using gridClass to ensure no overlap
        local decorations=self.gridClass:generateDecorations(
            map.decorations,self.decorationsClass,grid
        )

        self.currentLevel={
            name=lvl,
            definition=levelDef,
            spriteSheet=self.spriteSheets[map.name],
            anim=self.animations[map.name],
            levelBoundaries=self.generateLevelBoundaries(map.boundaries),
            decorations=decorations,
            grid=grid,
            allyCount=0,
            enemyCount=0,
            currentWave=0,
            complete=false,
        }
    end,

    destroyLevel=function(self)
        for i=1,#self.currentLevel.levelBoundaries do 
            local b=self.currentLevel.levelBoundaries[i]
            World:remove(b)
        end
        self.currentLevel.levelBoundaries={}
        self.currentLevel.allyCount=0
        self.currentLevel.enemyCount=0
        Objects:clear()
    end,
}