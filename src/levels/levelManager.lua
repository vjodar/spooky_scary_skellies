local mapDefinitions=require 'src.levels.mapDefinitions'

local generateDrawData=function(defs)
    local sprites,anims,foregrounds={},{},{}

    for name,def in pairs(defs) do 
        local path='assets/maps/'..name..'.png'
        sprites[name]=love.graphics.newImage(path)

        if def.animation then    
            local animDef=def.animation         
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
            collisionClass=b.class or 'boundary',
            side='top',
        }
        World:addItem(boundary)
        table.insert(levelBoundaries,boundary)
    end
    for i=1,#boundaries.b do         
        local b=boundaries.b[i]
        local boundary={
            x=b.x,y=b.y,
            w=b.w,h=boundaryThickness,
            collisionClass=b.class or 'boundary',
            side='bottom',
        }
        World:addItem(boundary)
        table.insert(levelBoundaries,boundary)
    end
    for i=1,#boundaries.l do 
        local b=boundaries.l[i]
        local boundary={
            x=b.x-boundaryThickness,y=b.y,
            w=boundaryThickness,h=b.h,
            collisionClass=b.class or 'boundary',
            side='left',
        }
        World:addItem(boundary)
        table.insert(levelBoundaries,boundary)
    end
    for i=1,#boundaries.r do 
        local b=boundaries.r[i]
        local boundary={
            x=b.x,y=b.y,
            w=boundaryThickness,h=b.h,
            collisionClass=b.class or 'boundary',
            side='right',
        }
        World:addItem(boundary)
        table.insert(levelBoundaries,boundary)
    end
    return levelBoundaries
end

local isEntityOutOfBounds=function(self,entity)
    local entityCollision=""
    if entity.name=='player' then 
        entityCollision='player'
    else 
        entityCollision=Entities.definitions[entity.name].collider.collisionFilter or entity.class
    end
    
    --Go through each boundary in the current level. If the entity is outside any of the
    --boundaries and that boundary is either of class 'boundary' or 'solid' or if the 
    --boundary is a 'pit' and the entity can't fly, they are out of bounds.
    local bounds=self.currentLevel.boundaries
    for i=1,#bounds do 
        boundary=bounds[i]
        if (boundary.side=='top' and entity.y<boundary.y)
        or (boundary.side=='bottom' and entity.y>boundary.y)
        or (boundary.side=='left' and entity.x<boundary.x)
        or (boundary.side=='right' and entity.x>boundary.x)
        then 
            if boundary.collisionClass=='boundary'
            or boundary.collisionClass=='solid'
            or (boundary.collisionClass=='pit' and entityCollision~='enemyFlying')
            then 
                return true 
            end 
        end
    end

    return false 
end

local returnEntityToLevel=function(self,entity)
    local gridClass=self.gridClass
    local levelGrid=self.currentLevel.grid
    if entity.class=='enemy' then --don't move enemies near player
        gridClass.clearPlayerTiles(levelGrid)
        gridClass:markPlayerTiles(levelGrid,4)
    end
    local entityColliderDef={w=entity.w,h=entity.h}
    local entityTileSize=gridClass:getTileSize(entityColliderDef)
    local availableTiles=gridClass:getAvailableTiles(levelGrid,entityTileSize,'entity')
    local selectedTile=rndElement(availableTiles)
    local goalX,goalY=gridClass:throughoutTiles(
        selectedTile.x,selectedTile.y,entityColliderDef.w,entityColliderDef.h,entityTileSize
    )
    entity.x,entity.y=goalX,goalY   --set entity to new position
    World:update(entity,goalX,goalY) --set collider to new position
end

local increaseEntityCount=function(self,class,name)
    local level=self.currentLevel 
    if class=='ally' then
        level.allyCount[name]=level.allyCount[name]+1
        level.allyTotal=level.allyTotal+1
    else
        level.enemyCount=level.enemyCount+1
    end
end

local decreaseEntityCount=function(self,class,name)
    local level=self.currentLevel 
    if class=='ally' then
        level.allyCount[name]=level.allyCount[name]-1
        level.allyTotal=level.allyTotal-1
    else
        level.enemyCount=level.enemyCount-1
    end
end

local maxEnemiesReached=function(self)
    return self.currentLevel.enemyCount>=self.currentLevel.definition.maxEnemies
end

local getWaveEnemyCount=function(waveDef)
    local total=0
    for name,count in pairs(waveDef) do total=total+count end
    return total
end

local setEntityAggro=function(self,bool) self.currentLevel.entityAggro=bool end
local getEntityAggro=function(self) return self.currentLevel.entityAggro end 

local killEntities=function(self,class) 
    for i=1,#Objects.table do 
        local o=Objects.table[i]
        if o.collisionClass 
        and o.collisionClass==class
        and o.state~='dead'
        then o:die() end  
    end
end

local drawForeground=function(self)
    if self.currentLevel.foreground then 
        love.graphics.draw(self.currentLevel.foreground,0,0) 
    end
end

local startNextLevel=function(self)
    local buildNextLevel=function()        
        self.currentLevel.boundaries={}
        Objects:clear()
        LevelManager.update=LevelManager.updateStandard
        self:buildLevel(self.currentLevel.nextLevel,self.currentLevel.allyCount)
    end
    FadeState:fadeBoth({fadeTime=0.4,afterFn=buildNextLevel,holdTime=0.4})
end

local restartLevel=function(self)
    --fill skeleton capacity with an even distribution of skeletons
    local allyCount={
        skeletonWarrior=0,
        skeletonArcher=0,
        skeletonMageFire=0,
        skeletonMageIce=0,
        skeletonMageElectric=0,
    }
    --only add archers and mages if they've been unlocked
    local skeletonPool={'skeletonWarrior'}
    if Player.upgrades.skeletonArcher then 
        table.insert(skeletonPool,'skeletonArcher') 
    end 
    if Player.upgrades.skeletonMageFire then 
        table.insert(skeletonPool,'skeletonMageFire')
    elseif Player.upgrades.skeletonMageIce then 
        table.insert(skeletonPool,'skeletonMageIce') 
    elseif Player.upgrades.skeletonMageElectric then 
        table.insert(skeletonPool,'skeletonMageElectric') 
    end 

    --Fill in allyCount
    local numPerType=floor(Player.maxMinions/#skeletonPool)
    for i=1,#skeletonPool do 
        local currentAllyCount=allyCount[skeletonPool[i]]
        allyCount[skeletonPool[i]]=currentAllyCount+numPerType
    end

    --Fill in any remaining slots with skeletonWarriors    
    local remainder=Player.maxMinions-(numPerType * #skeletonPool)
    allyCount.skeletonWarrior=allyCount.skeletonWarrior+remainder

    local rebuildCurrentLevel=function()
        Objects:clear()
        Player.health.current=Player.health.max 
        Player.status:clear(Player)
        Player.state='idle'
        Hud.health:calculateHeartPieces()
        LevelManager.update=LevelManager.updateStandard
        self:buildLevel(self.currentLevel.name,allyCount)
    end
    FadeState:fadeBoth({fadeTime=0.4,afterFn=rebuildCurrentLevel,holdTime=0.4})
end

local buildLevel=function(self,lvl,skeletons)
    local levelDef=self.levelDefinitions[lvl]
    local map=self.mapDefinitions[levelDef.map]
    local startPos=map.playerStartPos

    love.graphics.setBackgroundColor(map.bgColor)

    --move player to start position
    Player.status:clear(Player)
    Player.x,Player.y=startPos.x,startPos.y 
    World:update(Player,Player.x,Player.y)
    Camera:lookAt(startPos.x,startPos.y)

    --divide the map's spawnArea into a grid, reserving tiles for startPos
    local grid=self.gridClass:generate(map.spawnArea) 
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
        allyCount={
            skeletonWarrior=0,
            skeletonArcher=0,
            skeletonMageFire=0,
            skeletonMageIce=0,
            skeletonMageElectric=0,
        },
        allyTotal=0,
        enemyCount=0,
        currentWave=0,
        bossData=levelDef.bossData or nil,
        entityAggro=true, --used to enable/disable entity aggression
        canCheckWaveCompletion=true,
        complete=false,
        exit=levelDef.exit,
        nextLevel=levelDef.nextLevel,
    }        

    --spawn in the skeleton minions
    for name,count in pairs(skeletons) do 
        if count>0 then 
            local summonSkeletons=function() Player:summon(name,count) end
            Timer:after(0.5,summonSkeletons)
        end 
    end

    if lvl=='dungeonBoss' then CutsceneState:bossCutscene() end  

    self.update=self.wait --wait until any fading/camera panning is done
end

--finds a open space in a level grid for a chest to spawn in, then returns
--that position and the chests' center (for camera panning)
local getChestSpawnPos=function(self,chestName,grid)    
    local chestPos=self.gridClass:generateObjectSpawnPosition(
        chestName,Upgrades.chests,self.currentLevel.grid
    )
    local chestDef=Upgrades.chests.definitions[chestName]
    local chestCenter={x=chestPos.x+chestDef.w*0.5,y=chestPos.y+chestDef.h*0.5}
    return chestPos,chestCenter 
end

--spawns level chest and exit, pans to both in sequence
local spawnExit=function() --callback function, no arguments
    local level=LevelManager.currentLevel 

    local chestName='chestSmall'
    local chestPos,chestCenter=LevelManager:getChestSpawnPos(chestName,level.grid)

    --if level exit pos isn't specified, generate it using gridClass
    local exitPos=level.exit.pos or LevelManager.gridClass:generateObjectSpawnPosition(
        level.exit.name,LevelManager.exitsClass,level.grid
    )
    local exitDef=LevelManager.exitsClass.definitions[level.exit.name]
    local exitCenter={x=exitPos.x+exitDef.w*0.5,y=exitPos.y+exitDef.h*0.5}
    local panObjects={
        { 
            target=chestCenter, --pan to chest
            afterFn=function() --spawn chest
                Upgrades.chests:new(chestName,chestPos.x,chestPos.y)
            end,
            holdTime=1 --hold for spawn anim duration
        }, 
        { 
            target=exitCenter, --pan to exit pos (center)
            afterFn=function() --spawn level exit
                LevelManager.exitsClass:new(level.exit.name,exitPos.x,exitPos.y)
            end,
            holdTime=1.3 --hold for spawn anim duration
        }, 
        {target=Player.center} --pan back to player
    }
    PanState:panTo(panObjects)
end

local wait=function(self)
    --if acceptInput is true, it means the playState is on top of the 
    --gameStates stack and that no other states are waiting to finish
    if GameStates.acceptInput then self.update=self.updateStandard end 
end

local updateStandard=function(self) 
    --testing-----------------------------
    -- if love.timer.getAverageDelta()>0.1 then Objects:clear() end
    --testing-----------------------------
    local level=self.currentLevel 
    if level.anim then level.anim:update(dt) end
    if level.complete then return end

    --Current wave of enemies are defeated
    --Will wait until every enemy in wave has spawned before checking
    if level.canCheckWaveCompletion and level.enemyCount==0 then 

        --no more waves, proceed to next level
        if level.currentWave==#level.definition.waves then 
            level.complete=true
            Timer:after(1,self.spawnExit) --wait 1s after last enemy dies     
            return 
        end

        --if he next wave is a boss, spawn boss and change state machine,
        --otherwise spawn the next wave of enemies.
        level.currentWave=level.currentWave+1
        local nextWaveDef=level.definition.waves[level.currentWave]

        if level.bossData and level.bossData.wave==level.currentWave then 
            local bossDef=Entities.definitions[level.bossData.name] 
            local spawnPos=level.bossData.spawnPos
            local spawnCenter={
                x=spawnPos.x+bossDef.collider.w*0.5,
                y=spawnPos.y+bossDef.collider.h*0.5,
            }
            self.update=self.updateBoss
            self:setEntityAggro(false) --disable entity aggro

            local panObjects={
                { --watch boss spawn
                    target=spawnCenter,
                    afterFn=function()
                        local boss=Entities:new(
                            bossDef.name,spawnPos.x,spawnPos.y
                        )
                        boss.dialog=UI:newDialog(boss,45,'dialogWitch')
                        LevelManager.currentLevel.boss=boss
                    end,
                    holdTime=level.bossData.spawnAnimDuration,
                }, 
                { --back to player
                    target=Player.center,
                    afterFn=function() LevelManager:setEntityAggro(true) end,
                },
            }
            PanState:panTo(panObjects)
        else 
            self.gridClass:generateEnemies(nextWaveDef,Entities,level.grid)
        end

        --set timer to force level to wait until all enemies are spawned 
        --before checking for wave completion.
        level.canCheckWaveCompletion=false 
        local enemyCount=self.getWaveEnemyCount(nextWaveDef)
        local enableCheck=function() level.canCheckWaveCompletion=true end 
        Timer:after(0.05*enemyCount,enableCheck)
    end
end

local updateBoss=function(self)
    local level=self.currentLevel
    if level.anim then level.anim:update(dt) end 
    if level.complete then return end --waiting for player to exit level
    if level.boss==nil then return end --waiting for boss to spawn
    if level.boss.state=='spawn' then return end --waiting for spawn animation

    if level.boss.state=='dead' then 
        level.complete=true
        self:killEntities('enemy') --destroy any other enemies
        if level.name=='dungeonBoss' then 
            self:endTheGame()
            return 
        end

        --One large and two small chests for boss levels
        local chest1='chestLarge'
        local chest2='chestSmall'
        local chest3='chestSmall'
        local chestPos1,chestCenter1=self:getChestSpawnPos(chest1,level.grid)
        local chestPos2,chestCenter2=self:getChestSpawnPos(chest2,level.grid)
        local chestPos3,chestCenter3=self:getChestSpawnPos(chest3,level.grid)
    
        --if level exit pos isn't specified, generate it using gridClass
        local exitPos=level.exit.pos or self.gridClass:generateObjectSpawnPosition(
            level.exit.name,self.exitsClass,level.grid
        )
        local exitDef=self.exitsClass.definitions[level.exit.name]
        local exitCenter={x=exitPos.x+exitDef.w*0.5,y=exitPos.y+exitDef.h*0.5}
        local panObjects={
            { --watch boss death animation
                target=level.boss.center,
                holdTime=level.bossData.deathAnimDuration,
            },
            { 
                target=chestCenter1, --pan to chest
                afterFn=function() --spawn chest
                    Upgrades.chests:new(chest1,chestPos1.x,chestPos1.y)
                end,
                holdTime=1 --hold for spawn anim duration
            }, 
            { 
                target=chestCenter2, --pan to chest
                afterFn=function() --spawn chest
                    Upgrades.chests:new(chest2,chestPos2.x,chestPos2.y)
                end,
                holdTime=1 --hold for spawn anim duration
            }, 
            { 
                target=chestCenter3, --pan to chest
                afterFn=function() --spawn chest
                    Upgrades.chests:new(chest3,chestPos3.x,chestPos3.y)
                end,
                holdTime=1 --hold for spawn anim duration
            }, 
            { 
                target=exitCenter, --pan to exit pos (center)
                afterFn=function() --spawn level exit
                    self.exitsClass:new(level.exit.name,exitPos.x,exitPos.y)
                end,
                holdTime=1.3 --hold for spawn anim duration
            }, 
            {target=Player.center} --pan back to player
        }
        PanState:panTo(panObjects)
    end
end

local endTheGame=function(self)
    local level=self.currentLevel
    local panObjects={
        { --watch boss die
            target=level.boss.center,
            holdTime=level.bossData.deathAnimDuration,
        }, 
        { --back to player
            target=Player.center,
            afterFn=function()
                GameOverState:win()
            end,
        },
    }
    PanState:panTo(panObjects)
end

local buildTitleScreenLevel=function(self)
    local levelDef=self.levelDefinitions['swampL1']
    local map=self.mapDefinitions[rndElement({'swamp2','cave2'})]
    local startPos={x=16,y=64}
    love.graphics.setBackgroundColor(map.bgColor)
    local grid=self.gridClass:generate(map.spawnArea) 
    local decorations={}

    Camera.target={x=800/6, y=672/6} --look at top left of level
    
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
        allyCount={
            skeletonWarrior=0,
            skeletonArcher=0,
            skeletonMageFire=0,
            skeletonMageIce=0,
            skeletonMageElectric=0,
        },
        allyTotal=0,
        enemyCount=0,
        currentWave=0,
        bossData=levelDef.bossData or nil,
        entityAggro=true,
        canCheckWaveCompletion=false,
        complete=false,
        exit=levelDef.exit,
        nextLevel=levelDef.nextLevel,
    }

    --spawn all the enemies! (exept bosses)
    local enemies={}
    local notBoss=function(name)
        return not (name=='witch' or name=='witchClone' or name=='giantTombstone' or name=='obsidianGolem')
    end
    for name,def in pairs(Entities.definitions) do 
        if def.collider.class=='enemy' and notBoss(def.name) then enemies[name]=rnd(4) end 
    end
    self.gridClass:generateEnemies(enemies,Entities,self.currentLevel.grid,'idle')

    self.update=self.wait --wait until game starts
end

local buildTutorialLevel=function(self)
    local levelDef=self.levelDefinitions['tutorial']
    local map=self.mapDefinitions[levelDef.map]
    local startPos=map.playerStartPos

    love.graphics.setBackgroundColor(map.bgColor)

    --move player to start position
    Player.status:clear(Player)
    Player.x,Player.y=startPos.x,startPos.y+24
    World:update(Player,Player.x,Player.y)
    Camera:lookAt(startPos.x,startPos.y)

    --divide the map's spawnArea into a grid, reserving tiles for startPos
    local grid=self.gridClass:generate(map.spawnArea,3) 
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
        allyCount={
            skeletonWarrior=0,
            skeletonArcher=0,
            skeletonMageFire=0,
            skeletonMageIce=0,
            skeletonMageElectric=0,
        },
        allyTotal=0,
        enemyCount=0,
        currentWave=0,
        bossData=levelDef.bossData or nil,
        entityAggro=false, --disable aggro for opening cutscene
        canCheckWaveCompletion=true,
        complete=false,
        exit=levelDef.exit,
        nextLevel=levelDef.nextLevel,
    }

    --Spawn exit immediately
    local exit=self.currentLevel.exit 
    Audio:mute() --mute the exit spawning in
    self.exitsClass:new(exit.name,exit.pos.x,exit.pos.y)
    Audio:unmute()
    self.update=function() end --just wait till player exits level
end

return { --The Module
    terrainClass=require 'src.levels.terrain',
    gridClass=require 'src.levels.grid',
    decorationsClass=require 'src.levels.decorations',
    exitsClass=require 'src.levels.exits',
    levelDefinitions=require 'src.levels.levelDefinitions',
    mapDefinitions=mapDefinitions,
    sprites=sprites,
    animations=animations,
    foregrounds=foregrounds,
    currentLevel={},
    generateLevelBoundaries=generateLevelBoundaries,
    isEntityOutOfBounds=isEntityOutOfBounds,
    returnEntityToLevel=returnEntityToLevel,
    increaseEntityCount=increaseEntityCount,
    decreaseEntityCount=decreaseEntityCount,
    maxEnemiesReached=maxEnemiesReached,
    getWaveEnemyCount=getWaveEnemyCount,
    setEntityAggro=setEntityAggro,
    getEntityAggro=getEntityAggro,
    drawForeground=drawForeground,
    startNextLevel=startNextLevel,
    buildLevel=buildLevel,
    restartLevel=restartLevel,
    spawnExit=spawnExit,
    killEntities=killEntities,
    wait=wait,
    getChestSpawnPos=getChestSpawnPos,
    buildTitleScreenLevel=buildTitleScreenLevel,
    buildTutorialLevel=buildTutorialLevel,
    updateStandard=updateStandard,
    updateBoss=updateBoss,
    update=updateStandard,
    endTheGame=endTheGame,

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
        --             -- elseif o=='terrain' then love.graphics.setColor(0,1,0)
        --             -- elseif o=='border' then love.graphics.setColor(0,0,1)
        --             -- elseif o=='decoration' then love.graphics.setColor(0,1,1)
        --             end
        --             love.graphics.rectangle('line',tile.x,tile.y,16,16)
        --             love.graphics.setColor(1,1,1)
        --         end
        --     end
        -- end
        -- for i=1,#level.boundaries do 
        --     local b=level.boundaries[i]
        --     love.graphics.rectangle('line',b.x,b.y,b.w,b.h)
        -- end
        --testing------------------------------------------------------
    end,
}