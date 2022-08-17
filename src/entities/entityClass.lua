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

local entityClass={}
entityClass.definitions=require 'src/entities/entityDefinitions'
entityClass.behaviors=require 'src/entities/entityBehaviors'
entityClass.spriteSheets,entityClass.grids=sheetsAndGrids(entityClass.definitions)
entityClass.parseAnimations=parseAnimations 

function entityClass:new(entity,x,y) --constructor
    local def=self.definitions[entity]
    
    --Collider data
    local e=World:newBSGRectangleCollider(
        x,y,def.collider.width,def.collider.height,def.collider.corner
    )
    for fn,val in pairs(def.collider.modifiers) do
        e[fn](e,val)
    end
    e:setFixedRotation(true) 
    e:setCollisionClass(def.collider.class)

    --General data
    e.name=def.name 
    e.x,e.y=e:getPosition()
    e.health={current=def.health,max=def.health}
    e.moveSpeed=def.moveSpeed
    e.attackRange=def.attackRange
    e.attackSpeed=def.attackSpeed
    e.attackDamage=def.attackDamage
    e.knockback=def.knockback
    e.lungeSpeed=def.lungeSpeed or nil
    e.projectile=def.projectile or nil
    e.projectilesPerShot=def.projectilesPerShot or 1
    e.canAttack=true
    e.moveTarget=e
    e.angle=0
    e.returnToPlayerThreshold=150
    e.aggroRange={w=400,h=300}
    e.nearbyAttackTargets={}
    e.queryAttackTargetRate=0.5
    e.canQueryAttackTarget=true 

    --Draw data
    e.xOffset=def.drawData.xOffset
    e.yOffset=def.drawData.yOffset
    e.scaleX=1
    e.spriteSheet=self.spriteSheets[e.name]
    e.animations=self.parseAnimations(self.grids[e.name],def.animations)
    e.animSpeed={min=0.25,max=3,current=1}
    e.damagingFrames=def.animations.attack.damagingFrames or nil 
    e.firingFrame=def.animations.attack.firingFrame or nil

    e.shadow=Shadows:new(e.name)
    
    --Actions/AI
    e.onLoops={}
    for i,fn in pairs(self.behaviors.onLoops) do e.onLoops[i]=fn(e) end
    e.methods={} --includes update and draw functions
    for i,method in pairs(self.behaviors.methods) do e[i]=method end 
    e.AI=self.behaviors.AI[e.name]

    local startState=def.startState or 'idle'
    e:changeState(startState)
    table.insert(Objects.table,e)
    return e
end

return entityClass