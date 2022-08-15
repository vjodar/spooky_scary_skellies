local entityClass={}

function entityClass:load()
    self.definitions=require 'src/entities/entityDefinitions'
    self.behaviors=require 'src/entities/entityBehaviors'

    self.spriteSheets={}
    self.grids={}
    for name,def in pairs(self.definitions) do 
        local spriteSheetPath='assets/entities/'..name..'.png'
        self.spriteSheets[name]=love.graphics.newImage(spriteSheetPath)
        self.grids[name]=anim8.newGrid(
            def.drawData.frameWidth,def.drawData.frameHeight,
            self.spriteSheets[name]:getWidth(),
            self.spriteSheets[name]:getHeight()
        )
    end

    --Creates a table of animations given a grid and animation defs
    function self:parseAnimations(grid,animDefs)
        local anims={}  
        for anim,def in pairs(animDefs) do
            anims[anim]=anim8.newAnimation(
                grid(def.frames,def.row),def.duration
            ) 
        end
        return anims
    end
end

function entityClass:new(entity,x,y)
    local def=self.definitions[entity]
    local e={name=def.name}
    
    --Collider data
    e.collider=World:newBSGRectangleCollider(
        x,y,def.collider.width,def.collider.height,def.collider.corner
    )
    for fn,val in pairs(def.collider.modifiers) do
        e.collider[fn](e.collider,val)
    end
    e.collider:setFixedRotation(true) 
    e.collider:setCollisionClass(def.collider.class)
    e.collider:setObject(e)

    --General data
    e.x,e.y=e.collider:getPosition()
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
    e.moveTargetOffset=0
    e.distanceFromPlayer=0
    e.returnToPlayerThreshold=150
    e.aggroRange={w=400,h=300}
    e.nearbyAttackTargets={}
    e.queryAttackTargetRate=1
    e.canQueryAttackTarget=true 

    --Draw data
    e.xOffset=def.drawData.xOffset
    e.yOffset=def.drawData.yOffset
    e.scaleX=1
    e.spriteSheet=self.spriteSheets[e.name]
    e.animations=self:parseAnimations(self.grids[e.name],def.animations)
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