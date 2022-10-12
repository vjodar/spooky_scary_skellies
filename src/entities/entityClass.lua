--Generates spriteSheets and animation grids for all defined entities
local sheetsAndGrids=function(def)
    local spriteSheets,grids={},{}

    for name,def in pairs(def) do 
        local spriteSheetPath='assets/entities/'..name..'.png'
        spriteSheets[name]=love.graphics.newImage(spriteSheetPath)
        grids[name]=anim8.newGrid(
            def.drawData.frameWidth,def.drawData.frameHeight,
            spriteSheets[name]:getWidth(),
            spriteSheets[name]:getHeight()
        )

        --create spriteSheets for any alternates
        if def.drawData.altSpriteSheets then 
            for i=1,#def.drawData.altSpriteSheets do 
                local altSheetName=def.drawData.altSpriteSheets[i]
                local altPath='assets/entities/'..altSheetName..'.png'
                spriteSheets[altSheetName]=love.graphics.newImage(altPath)
                grids[altSheetName]=grids[name] --same grid as main spriteSheet
            end
        end
    end

    return spriteSheets,grids
end

--Generates all animations given a grid and animation definitions
local parseAnimations=function(grid,animDefs)
    local anims={}  
    for anim,def in pairs(animDefs) do
        anims[anim]=anim8.newAnimation(grid(def.frames,def.row),def.duration) 
    end
    return anims
end

--Return a spriteSheet's name among an entity's main and alternates, if any.
local chooseSpriteSheet=function(def)
    --if entity has alternate spriteSheets, choose randomly
    if def.drawData.altSpriteSheets then 
        local selections={def.name}
        for i=1,#def.drawData.altSpriteSheets do 
            table.insert(selections,def.drawData.altSpriteSheets[i])
        end
        return rndElement(selections)

    else --no alternates, just choose the main spriteSheet
        return def.name 
    end
end

local generateParticleEmitters=function(defs)
    local emitters={}
    for name,def in pairs(defs) do
        if def.particles then 
            emitters[name]=ParticleSystem:generateEmitter(def.particles)
        else print(name, 'has no particle definition') end
    end
    return emitters 
end

local entityClass={}
entityClass.definitions=require 'src/entities/entityDefinitions'
entityClass.behaviors=require 'src/entities/entityBehaviors'
entityClass.spriteSheets,entityClass.grids=sheetsAndGrids(entityClass.definitions)
entityClass.parseAnimations=parseAnimations 
entityClass.chooseSpriteSheet=chooseSpriteSheet
entityClass.particleEmitters=generateParticleEmitters(entityClass.definitions)
entityClass.new=function(self,entity,x,y,startState) --constructor
    local def=self.definitions[entity]
    local e={name=def.name}
    
    --Collider data
    e.x,e.y=x,y 
    e.w,e.h=def.collider.w,def.collider.h
    e.center=getCenter(e)
    e.vx,e.vy=0,0
    e.linearDamping=def.collider.linearDamping or 10
    e.restitution=def.collider.restitution or 0.5
    e.stopThreshold=3*60 --at 60fps, stop moving when speed<3
    e.collisionClass=def.collider.class
    local collisionFilter=def.collider.collisionFilter or def.collider.class
    local moveFilter=def.collider.moveFilter or 'pitOrSolidOrBoundary'
    local losFilter=def.collider.losFilter or 'pitOrSolid'
    e.collisionFilter=World.collisionFilters[collisionFilter]
    e.moveFilter=World.queryFilters[moveFilter]
    e.losFilter=World.queryFilters[losFilter]

    --General data
    e.health={current=def.health,max=def.health}
    e.moveSpeedMax=def.moveSpeed
    e.moveSpeed=e.moveSpeedMax
    e.kbResistance=def.kbResistance or 0
    e.attack=def.attack 
    e.moveTarget=e
    e.angle=0
    e.aggroRange={w=1000,h=750}
    e.nearbyAttackTargets={}
    e.targetsAlreadyAttacked={} --only damage a given target once per attack
    e.idleTime=rnd()*3
    e.maxIdleTime=3 --3s of idle until entity wanders around

    --Draw data
    e.spriteSheet=self.spriteSheets[self.chooseSpriteSheet(def)]
    e.xOffset=e.w*0.5
    e.yOffset=(e.h-def.drawData.frameHeight)*0.5
    e.xOrigin=def.drawData.frameWidth*0.5
    e.yOrigin=def.drawData.frameHeight*0.5
    e.scaleX=def.drawData.scaleX or rndSign() --used to face right (1) or left (-1)
    e.animations=self.parseAnimations(self.grids[e.name],def.animations)
    e.animSpeedMax=1
    e.animSpeed=e.animSpeedMax 
    e.visibleFrame=def.animations.spawn.visibleFrame --only draw shadow after this frame
    e.damagingFrames=def.animations.attack.damagingFrames or nil 
    e.firingFrame=def.animations.attack.firingFrame or nil
    e.spawnMinionFrame=def.animations.attack.spawnMinionFrame or nil

    e.shadow=Shadows:new(e.name,e.w,e.h) --Shadow
    e.status=Statuses:new() --status system 
    e.particles=self.particleEmitters[e.name] --particle emitter
    e.deathShake=def.deathShake or {magnitude=2}

    --Cooldown flags, periods, and callbacks
    e.canAttack={flag=true,cooldownPeriod=def.attack.period}
    e.canAttack.setOnCooldown=Timer:giveCooldownCallbacks(e.canAttack)

    e.canQueryAttackTargets={flag=true,cooldownPeriod=0.5}
    e.canQueryAttackTargets.setOnCooldown=Timer:giveCooldownCallbacks(e.canQueryAttackTargets)
    
    --Actions/AI
    e.methods={} --includes update and draw functions
    local methods=self.behaviors.methods
    for i,method in pairs(methods.common) do e[i]=method end 
    for i,method in pairs(methods[e.collisionClass]) do e[i]=method end 
    e.AI=self.behaviors.AI[e.name]

    local state=startState or 'spawn'
    e:changeState(state)

    World:addItem(e)
    table.insert(Objects.table,e)
    LevelManager:increaseEntityCount(e.collisionClass,e.name)

    return e
end

return entityClass