local levelDefinitions={
    test={
        map='cave2',
        waves={
            {
                vampire=3,
            },
            {
                zombie=20,            
                tombstone=10,            
            },
            {
                spider=20,            
                spiderEgg=20,            
            },
            {
                pumpkin=10,       
                ent=10,  
                headlessHorseman=4,     
            },
        },
        maxEnemies=10, --used to limit summoner enemies' minion spawns
    },
}

local bgColors={
    black={53/255,53/255,64/255},
    swamp={68/255,99/255,80/255},
    cave={126/255,103/255,76/255},
    water={92/255,105/255,159/255},
    lava={229/255,111/255,75/255},
}

local mapDefinitions={
    swamp1={
        name='swamp1',
        animation={
            frameWidth=928,
            frameHeight=800,
            sheetWidth=3712,
            sheetHeight=800,
            frames='1-4',
            duration=0.25,
        },
        bgColor=bgColors.water,
        boundaries={
            {x=0,y=0,w=928,h=100}, 
            {x=0,y=693,w=928,h=107},
            {x=0,y=100,w=71,h=593}, 
            {x=857,y=100,w=71,h=593},
        },
        spawnArea={x=80,y=112,w=768,h=576},
        playerStartPos={x=432,y=368},
        terrain={
            -- rockCaveLarge=40,
            rockSwampSmall=10,
            rockSwampMedium=10,
            treeSmall=20,
            treeMedium=20,
            treeLarge=20,
            treePine=20,
            pitWater1=5,
            pitWater2=5,
            pitWater3=3,
            -- signPost1=2,
            -- signPost2=2,
            -- mushroomBig=30,
            mushroomSwamp=20,
            pitSwampSmall=5,
            pitSwampLarge=2,
            moundSwampSmall=5,
            moundSwampLarge=2,
        },
        decorations={
            swampSmall=300,
            swampBig=20,
        },
    },
    swamp2={
        name='swamp2',
        bgColor=bgColors.swamp,
        boundaries={
            {x=0,y=0,w=928,h=108}, 
            {x=0,y=697,w=928,h=103},
            {x=0,y=108,w=71,h=589}, 
            {x=857,y=108,w=71,h=589},
        },
        spawnArea={x=80,y=112,w=768,h=576},
        playerStartPos={x=432,y=368},
        terrain={
            -- rockCaveLarge=40,
            rockSwampSmall=10,
            rockSwampMedium=10,
            treeSmall=20,
            treeMedium=20,
            treeLarge=20,
            treePine=20,
            pitWater1=5,
            pitWater2=5,
            pitWater3=3,
            -- signPost1=2,
            -- signPost2=2,
            -- mushroomBig=30,
            mushroomSwamp=20,
            pitSwampSmall=5,
            pitSwampLarge=2,
            moundSwampSmall=5,
            moundSwampLarge=2,
        },
        decorations={
            swampSmall=300,
            swampBig=20,
        },
    },
    cave1={
        name='cave1',
        animation={            
            frameWidth=928,
            frameHeight=800,
            sheetWidth=3712,
            sheetHeight=800,
            frames='1-4',
            duration=0.25,
        },
        bgColor=bgColors.lava,
        boundaries={
            {x=0,y=0,w=928,h=112}, 
            {x=0,y=688,w=928,h=112},
            {x=0,y=112,w=80,h=576}, 
            {x=848,y=112,w=80,h=576},
        },
        spawnArea={x=80,y=112,w=768,h=576},
        playerStartPos={x=432,y=368},
        terrain={
            rockCaveLarge=10,
            rockCaveSmall=10,
            rockCaveMedium=10,
            rockGem=10,
            pitLava1=5,
            pitLava2=5,
            pitLava3=3,
            mushroomBig=30,
            mushroomCave=50,
        },
        decorations={
            caveSmall=300,
            caveBig=10,
        },
    },
    cave2={
        name='cave2',
        bgColor=bgColors.cave,
        boundaries={
            {x=0,y=0,w=928,h=108}, 
            {x=0,y=697,w=928,h=103},
            {x=0,y=108,w=71,h=589}, 
            {x=857,y=108,w=71,h=589},
        },
        spawnArea={x=80,y=112,w=768,h=576},
        playerStartPos={x=432,y=368},
        terrain={
            rockCaveLarge=10,
            rockCaveSmall=10,
            rockCaveMedium=10,
            rockGem=10,
            pitLava1=5,
            pitLava2=5,
            pitLava3=3,
            mushroomBig=30,
            mushroomCave=30,
            pitCaveSmall=5,
            pitCaveLarge=2,
            moundCaveSmall=5,
            moundCaveLarge=2,
        },
        decorations={
            caveSmall=300,
            caveBig=10,
        },
    },
}

local generateDrawData=function(defs)
    local sprites,anims={},{}

    for name,def in pairs(defs) do 
        local path='assets/maps/'..name..'.png'
        sprites[name]=love.graphics.newImage(path)

        if def.animation then    
            animDef=def.animation         
            local grid=anim8.newGrid(
                animDef.frameWidth,animDef.frameHeight,
                animDef.sheetWidth,animDef.sheetHeight
            )
            anims[name]=anim8.newAnimation(grid(animDef.frames,1), animDef.duration)
        end
    end

    return sprites,anims 
end
local sprites,animations=generateDrawData(mapDefinitions)

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

local maxEnemiesReached=function(self)
    return self.currentLevel.enemyCount>=self.currentLevel.definition.maxEnemies
end

return { --The Module
    terrainClass=require 'src/levels/terrain',
    gridClass=require 'src/levels/grid',
    decorationsClass=require 'src/levels/decorations',
    levelDefinitions=levelDefinitions,
    mapDefinitions=mapDefinitions,
    sprites=sprites,
    animations=animations,
    currentLevel={},
    generateLevelBoundaries=generateLevelBoundaries,
    increaseEntityCount=increaseEntityCount,
    decreaseEntityCount=decreaseEntityCount,
    maxEnemiesReached=maxEnemiesReached,
    
    update=function(self) 
        local level=self.currentLevel 
        if level.anim then level.anim:update(dt) end
        --testing-----------------------------
        -- if love.timer.getAverageDelta()>0.1 then self:destroyLevel() end
        --testing-----------------------------

        if level.complete then return end

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
        local level=self.currentLevel
        if level.anim then 
            level.anim:draw(self.currentLevel.sprite,0,0) 
        else
            love.graphics.draw(level.sprite,0,0)
        end

        for i=1,#self.currentLevel.decorations do --draw ground decorations
            self.currentLevel.decorations[i]:draw()
        end
        --testing------------------------------------------------------
        -- for i=1,#self.currentLevel.grid do 
        --     for j=1,#self.currentLevel.grid[i] do
        --         local tile=self.currentLevel.grid[i][j] 
        --         love.graphics.rectangle('line',tile.x,tile.y,16,16)
        --         if #tile.occupiedBy>0 then 
        --             local o=tile.occupiedBy[1]
        --             if o=='player' then love.graphics.setColor(1,0,0)
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
            sprite=self.sprites[map.name],
            anim=self.animations[map.name] or nil,
            boundaries=self.generateLevelBoundaries(map.boundaries),
            decorations=decorations,
            grid=grid,
            allyCount=0,
            enemyCount=0,
            currentWave=0,
            complete=false,
        }
    end,

    destroyLevel=function(self)
        for i=1,#self.currentLevel.boundaries do 
            local b=self.currentLevel.boundaries[i]
            World:remove(b)
        end
        self.currentLevel.boundaries={}
        self.currentLevel.allyCount=0
        self.currentLevel.enemyCount=0
        Objects:clear()
    end,
}