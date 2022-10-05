local mapDefinitions=require 'src/levels/mapDefinitions'

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

local increaseEntityCount=function(self,class,name)
    local level=self.currentLevel 
    if class=='ally' then
        level.allyCount[name]=level.allyCount[name]+1
    else
        level.enemyCount=level.enemyCount+1
    end
end

local decreaseEntityCount=function(self,class,name)
    local level=self.currentLevel 
    if class=='ally' then
        level.allyCount[name]=level.allyCount[name]-1
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

local killEnemies=function(self) 
    for i=1,#Objects.table do 
        local o=Objects.table[i]
        if o.collisionClass 
        and o.collisionClass=='enemy' 
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

local buildLevel=function(self,lvl,skeletons)
    local levelDef=self.levelDefinitions[lvl]
    local map=self.mapDefinitions[levelDef.map]
    local startPos=map.playerStartPos

    love.graphics.setBackgroundColor(map.bgColor)

    --move player to start position
    Player.x,Player.y=startPos.x,startPos.y 
    World:update(Player,Player.x,Player.y)
    Camera:lookAt(startPos.x,startPos.y)

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
        allyCount={
            skeletonWarrior=0,
            skeletonArcher=0,
            skeletonMageFire=0,
            skeletonMageIce=0,
            skeletonMageElectric=0,
        },
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
        local summonSkeleton=function() Player:summon(name) end 
        for i=1,count do Timer:after(0.5,summonSkeleton) end
    end

    self.update=self.wait --wait until any fading/camera panning is done
end

--spawns level chest and exit, pans to both in sequence
local spawnExit=function()
    local level=LevelManager.currentLevel 

    --if level exit pos isn't specified, generate it using gridClass
    local spawnPos=level.exit.pos or LevelManager.gridClass:generateExitSpawnPosition(
        level.exit.name,LevelManager.exitsClass,level.grid
    )
    local exitDef=LevelManager.exitsClass.definitions[level.exit.name]
    local exitCenter={x=spawnPos.x+exitDef.w*0.5,y=spawnPos.y+exitDef.h*0.5}
    local panObjects={
        -- { 
        --     target={x=0,y=0}, --pan to chest
        --     afterFn=function() --spawn chest
        --         print('this is where the chest would be IF I HAD ONE!')
        --     end,
        --     holdTime=1.3 --hold for spawn anim duration
        -- }, 
        { 
            target=exitCenter, --pan to exit pos (center)
            afterFn=function() --spawn level exit
                LevelManager.exitsClass:new(level.exit.name,spawnPos.x,spawnPos.y)
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
    if acceptInput then self.update=self.updateStandard end 
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
                        LevelManager.currentLevel.boss=Entities:new(
                            bossDef.name,spawnPos.x,spawnPos.y
                        )
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
        Timer:after(0.1*enemyCount,enableCheck)
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
        self:killEnemies() --destroy any other enemies

        --if level exit pos isn't specified, generate it using gridClass
        local spawnPos=level.exit.pos or self.gridClass:generateExitSpawnPosition(
            level.exit.name,self.exitsClass,level.grid
        )
        local exitDef=self.exitsClass.definitions[level.exit.name]
        local exitCenter={x=spawnPos.x+exitDef.w*0.5,y=spawnPos.y+exitDef.h*0.5}
        local panObjects={
            { --watch boss death animation
                target=level.boss.center,
                holdTime=level.bossData.deathAnimDuration,
            },
            -- { 
            --     target={x=0,y=0}, --pan to chest
            --     afterFn=function() --spawn chest
            --         print('this is where the chest would be IF I HAD ONE!')
            --     end,
            --     holdTime=1.3 --hold for spawn anim duration
            -- }, 
            { 
                target=exitCenter, --pan to exit pos (center)
                afterFn=function() --spawn level exit
                    LevelManager.exitsClass:new(level.exit.name,spawnPos.x,spawnPos.y)
                end,
                holdTime=1.3 --hold for spawn anim duration
            }, 
            {target=Player.center} --pan back to player
        }
        PanState:panTo(panObjects)
    end
end

return { --The Module
    terrainClass=require 'src/levels/terrain',
    gridClass=require 'src/levels/grid',
    decorationsClass=require 'src/levels/decorations',
    exitsClass=require 'src/levels/exits',
    levelDefinitions=require 'src/levels/levelDefinitions',
    mapDefinitions=mapDefinitions,
    sprites=sprites,
    animations=animations,
    foregrounds=foregrounds,
    currentLevel={},
    generateLevelBoundaries=generateLevelBoundaries,
    increaseEntityCount=increaseEntityCount,
    decreaseEntityCount=decreaseEntityCount,
    maxEnemiesReached=maxEnemiesReached,
    getWaveEnemyCount=getWaveEnemyCount,
    setEntityAggro=setEntityAggro,
    getEntityAggro=getEntityAggro,
    drawForeground=drawForeground,
    startNextLevel=startNextLevel,
    buildLevel=buildLevel,
    spawnExit=spawnExit,
    killEnemies=killEnemies,
    wait=wait,
    updateStandard=updateStandard,
    updateBoss=updateBoss,
    update=updateStandard,

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
        --         end
        --     end
        -- end
        for i=1,#level.boundaries do 
            local b=level.boundaries[i]
            love.graphics.rectangle('line',b.x,b.y,b.w,b.h)
        end
        --testing------------------------------------------------------
    end,
}