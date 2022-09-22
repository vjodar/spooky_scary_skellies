local levelDefinitions={
    test={
        map='dungeon6',
        waves={
            {
                werebear=30,
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
    swamp1={ --island in water
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
            t={{x=0,y=100,w=928,},},
            b={{x=0,y=693,w=928,},},
            l={{x=71,y=0,h=800,},},
            r={{x=856,y=0,h=800,},},
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
    swamp2={ --enclosed
        name='swamp2',
        bgColor=bgColors.swamp,
        boundaries={
            t={{x=0,y=61,w=800,class='solid'},}, 
            b={{x=0,y=655,w=800,class='solid'},},
            l={{x=8,y=0,h=656,class='solid'},},
            r={{x=791,y=0,h=656,class='solid'},},
        },
        foreground='swamp',
        spawnArea={x=16,y=64,w=768,h=576},
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
    cave1={ --island in lava
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
            t={{x=0,y=100,w=928,},},
            b={{x=0,y=693,w=928,},},
            l={{x=71,y=0,h=800,},},
            r={{x=856,y=0,h=800,},},
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
    cave2={ --enclosed
        name='cave2',
        bgColor=bgColors.cave,
        boundaries={
            t={{x=0,y=61,w=800,class='solid'},}, 
            b={{x=0,y=655,w=800,class='solid'},},
            l={{x=8,y=0,h=656,class='solid'},},
            r={{x=791,y=0,h=656,class='solid'},},
        },
        foreground='cave',
        spawnArea={x=16,y=64,w=768,h=576},
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
    dungeon1={ --green carpet
        name='dungeon1',
        bgColor=bgColors.black,
        foreground='dungeon',
        boundaries={
            t={{x=0,y=26,w=544,class='solid'},},
            b={{x=0,y=390,w=544,class='solid'},},
            l={{x=10,y=0,h=400,class='solid'},},
            r={{x=533,y=0,h=400,class='solid'},},
        },
        spawnArea={x=16,y=32,w=496,h=336},
        playerStartPos={x=332,y=268},
        terrain={
            tableSmall=3,
            tableVertical=3,
            tableLarge=3,
            crateSmall=5,
            crateLarge=5,
        }
    },
    dungeon2={ --red carpet
        name='dungeon2',
        bgColor=bgColors.black,
        foreground='dungeon',
        boundaries={
            t={{x=0,y=26,w=544,class='solid'},},
            b={{x=0,y=390,w=544,class='solid'},},
            l={{x=10,y=0,h=400,class='solid'},},
            r={{x=533,y=0,h=400,class='solid'},},
        },
        spawnArea={x=16,y=32,w=496,h=336},
        playerStartPos={x=332,y=268},
        terrain={
            tableSmall=3,
            tableVertical=3,
            tableLarge=3,
            crateSmall=5,
            crateLarge=5,
        }
    },
    dungeon3={ --blue carpet
        name='dungeon3',
        bgColor=bgColors.black,
        foreground='dungeon',
        boundaries={
            t={{x=0,y=26,w=544,class='solid'},},
            b={{x=0,y=390,w=544,class='solid'},},
            l={{x=10,y=0,h=400,class='solid'},},
            r={{x=533,y=0,h=400,class='solid'},},
        },
        spawnArea={x=16,y=32,w=496,h=336},
        playerStartPos={x=332,y=268},
        terrain={
            tableSmall=3,
            tableVertical=3,
            tableLarge=3,
            crateSmall=5,
            crateLarge=5,
        }
    },
    dungeon4={ --surrounded by water
        name='dungeon4',
        animation={
            frameWidth=544,
            frameHeight=400,
            sheetWidth=2176,
            sheetHeight=400,
            frames='1-4',
            duration=0.25,
        },
        bgColor=bgColors.black,
        foreground='dungeon',
        boundaries={
            t={
                {x=0,y=26,w=544,class='solid'},
                {x=0,y=53,w=544,class='pit'},
            },
            b={
                {x=0,y=390,w=544,class='solid'},
                {x=0,y=361,w=544,class='pit'},
            },
            l={
                {x=10,y=0,h=400,class='solid'},
                {x=38,y=0,h=400,class='pit'},
            },
            r={
                {x=533,y=0,h=400,class='solid'},
                {x=505,y=0,h=400,class='pit'},
            },
        },
        spawnArea={x=48,y=64,w=448,h=288},
        playerStartPos={x=100,y=100},
        terrain={
            pitDungeonWaterSmall=3,
        },
    },
    dungeon5={ --surrounded by lava
        name='dungeon5',
        animation={
            frameWidth=544,
            frameHeight=400,
            sheetWidth=2176,
            sheetHeight=400,
            frames='1-4',
            duration=0.25,
        },
        bgColor=bgColors.black,
        foreground='dungeon',
        boundaries={
            t={
                {x=0,y=26,w=544,class='solid'},
                {x=0,y=69,w=544,class='pit'},
            },
            b={
                {x=0,y=390,w=544,class='solid'},
                {x=0,y=344,w=544,class='pit'},
            },
            l={
                {x=10,y=0,h=400,class='solid'},
                {x=54,y=0,h=400,class='pit'},
            },
            r={
                {x=533,y=0,h=400,class='solid'},
                {x=489,y=0,h=400,class='pit'},
            },
        },
        spawnArea={x=64,y=80,w=416,h=256},
        playerStartPos={x=100,y=100},
        terrain={
            pitDungeonLavaSmall=3,
        },
    },
    dungeon6={ --surrounded by acid
        name='dungeon6',
        animation={
            frameWidth=544,
            frameHeight=400,
            sheetWidth=2176,
            sheetHeight=400,
            frames='1-4',
            duration=0.25,
        },
        bgColor=bgColors.black,
        foreground='dungeon',
        boundaries={
            t={
                {x=0,y=26,w=544,class='solid'},
                {x=0,y=85,w=544,class='pit'},
            },
            b={
                {x=0,y=390,w=544,class='solid'},
                {x=0,y=328,w=544,class='pit'},
            },
            l={
                {x=10,y=0,h=400,class='solid'},
                {x=70,y=0,h=400,class='pit'},
            },
            r={
                {x=533,y=0,h=400,class='solid'},
                {x=473,y=0,h=400,class='pit'},
            },
        },
        spawnArea={x=80,y=96,w=384,h=224},
        playerStartPos={x=100,y=100},
        terrain={
            pitDungeonAcidSmall=3,
        },
    },
}

local generateDrawData=function(defs)
    local sprites,anims,foregrounds={},{},{}

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

        if def.foreground then 
            local foregroundPath='assets/maps/foreground/'..def.foreground..'.png'
            foregrounds[name]=love.graphics.newImage(foregroundPath)
        end
    end 

    return sprites,anims,foregrounds
end
local sprites,animations,foregrounds=generateDrawData(mapDefinitions)

--creates the physical level boundaries that no entity can go
local generateLevelBoundaries=function(boundaries)
    local boundaryThickness=64
    local levelBoundaries={}
    for i=1,#boundaries.t do 
        local b=boundaries.t[i]
        local boundary={
            x=b.x,y=b.y-boundaryThickness,
            w=b.w,h=boundaryThickness,
            collisionClass=b.class or 'boundary'
        }
        World:addItem(boundary)
        table.insert(levelBoundaries,boundary)
    end
    for i=1,#boundaries.b do         
        local b=boundaries.b[i]
        local boundary={
            x=b.x,y=b.y,
            w=b.w,h=boundaryThickness,
            collisionClass=b.class or 'boundary'
        }
        World:addItem(boundary)
        table.insert(levelBoundaries,boundary)
    end
    for i=1,#boundaries.l do 
        local b=boundaries.l[i]
        local boundary={
            x=b.x-boundaryThickness,y=b.y,
            w=boundaryThickness,h=b.h,
            collisionClass=b.class or 'boundary'
        }
        World:addItem(boundary)
        table.insert(levelBoundaries,boundary)
    end
    for i=1,#boundaries.r do 
        local b=boundaries.r[i]
        local boundary={
            x=b.x,y=b.y,
            w=boundaryThickness,h=b.h,
            collisionClass=b.class or 'boundary'
        }
        World:addItem(boundary)
        table.insert(levelBoundaries,boundary)
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

local drawForeground=function(self)
    if self.currentLevel.foreground then 
        love.graphics.draw(self.currentLevel.foreground,0,0) 
    end
end

return { --The Module
    terrainClass=require 'src/levels/terrain',
    gridClass=require 'src/levels/grid',
    decorationsClass=require 'src/levels/decorations',
    levelDefinitions=levelDefinitions,
    mapDefinitions=mapDefinitions,
    sprites=sprites,
    animations=animations,
    foregrounds=foregrounds,
    currentLevel={},
    generateLevelBoundaries=generateLevelBoundaries,
    increaseEntityCount=increaseEntityCount,
    decreaseEntityCount=decreaseEntityCount,
    maxEnemiesReached=maxEnemiesReached,
    drawForeground=drawForeground,
    
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
        for i=1,#level.boundaries do 
            local b=level.boundaries[i]
            love.graphics.rectangle('line',b.x,b.y,b.w,b.h)
        end
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
        local decorations={}
        
        --spawn randomly generated map terrain, using gridClass to ensure no overlap
        if map.terrain then 
            self.gridClass:generateTerrain(map.terrain,self.terrainClass,grid)
        end

        --spawn randomly generate ground decorations, using gridClass to ensure no overlap
        if map.decorations then 
            local decor=self.gridClass:generateDecorations(
                map.decorations,self.decorationsClass,grid
            )
            for i=1,#decor do table.insert(decorations,decor[i]) end
        end

        self.currentLevel={
            name=lvl,
            definition=levelDef,
            sprite=self.sprites[map.name],
            anim=self.animations[map.name] or nil,
            foreground=self.foregrounds[map.name] or nil,
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