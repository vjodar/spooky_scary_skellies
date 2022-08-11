local enemyClass={}

function enemyClass:load()
    self.enemyDefinitions=require 'src/enemies/enemyDefinitions'
    self.behaviors=require 'src/enemies/enemyBehaviors'

    self.spriteSheets={}
    self.grids={}
    for name,def in pairs(self.enemyDefinitions) do 
        local spriteSheetPath='assets/entities/'..name..'.png'
        self.spriteSheets[name]=love.graphics.newImage(spriteSheetPath)
        self.grids[name]=anim8.newGrid(
            def.drawData.frameWidth,def.drawData.frameHeight,
            self.spriteSheets[name]:getWidth(),
            self.spriteSheets[name]:getHeight()
        )
    end
    
    --Creates a table of animations given an enemy, grid, and animation defs
    function self:parseAnimations(_enemy,_grid,_animDefs)
        local anims={}  
        for anim,def in pairs(_animDefs) do
            anims[anim]=anim8.newAnimation(
                _grid(def.frames,def.row),def.duration
            ) 
        end
        return anims
    end
end

function enemyClass:new(_enemyType,_x,_y)
    local def=self.enemyDefinitions[_enemyType]

    local e={name=def.name}

    --Collider data
    e.collider=World:newBSGRectangleCollider(
        _x,_y,def.collider.width,def.collider.height,def.collider.corner
    )
    for fn,val in pairs(def.collider.modifiers) do 
        e.collider[fn](e.collider,val)
    end
    e.collider:setFixedRotation(true) 
    e.collider:setCollisionClass('enemy')
    e.collider:setObject(e)

    --General data
    e.x,e.y=e.collider:getPosition()
    e.health={current=def.health,max=def.health}
    e.moveSpeed=def.moveSpeed
    e.moveTarget=e
    e.angle=0
    e.attackRange=def.attackRange
    e.attackDamage=def.attackDamage
    e.lungeSpeed=def.lungeSpeed or 0
    e.knockback=def.knockback
    e.attackSpeed=def.attackSpeed 
    e.canAttack=true --attack not on cooldown
    e.aggroRange={w=400,h=300}
    e.nearbyAttackTargets={}
    e.queryAttackTargetRate=1 --check for targets every 1s
    e.canQueryAttackTarget=true

    --Draw data
    e.xOffset=def.drawData.xOffset
    e.yOffset=def.drawData.yOffset
    e.scaleX=1
    e.spriteSheet=self.spriteSheets[def.name]
    e.animations=self:parseAnimations(
        e,self.grids[def.name],def.animations
    )
    e.animSpeed={min=0.25,max=3,current=1}
    e.damagingFrames=def.animations.attack.damagingFrames or 0
    
    --Actions/AI
    e.onLoopFunctions={}
    for i,fn in pairs(self.behaviors.onLoopFunctions) do 
        e.onLoopFunctions[i]=fn(e)
    end
    e.methods={} --includes update/draw functions
    for i,method in pairs(self.behaviors.methods) do e[i]=method end
    e.AI=self.behaviors.AI[e.name]

    e:changeState('idle')
    table.insert(Entities.table,e)
    return e
end

return enemyClass
