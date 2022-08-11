local skeletonClass={}

function skeletonClass:load()
    self.skeletonDefinitions=require 'src/skeletons/skeletonDefinitions'
    self.behaviors=require 'src/skeletons/skeletonBehaviors'

    self.spriteSheets={}
    self.grids={}
    for name,def in pairs(self.skeletonDefinitions) do 
        local spriteSheetPath='assets/entities/'..name..'.png'
        self.spriteSheets[name]=love.graphics.newImage(spriteSheetPath)
        self.grids[name]=anim8.newGrid(
            def.drawData.frameWidth,def.drawData.frameHeight,
            self.spriteSheets[name]:getWidth(),
            self.spriteSheets[name]:getHeight()
        )
    end

    --Creates a table of animations given a skeleton, grid, and animation defs
    function self:parseAnimations(_skeleton,_grid,_animDefs)
        local anims={}  
        for anim,def in pairs(_animDefs) do
            anims[anim]=anim8.newAnimation(
                _grid(def.frames,def.row),def.duration
            ) 
        end
        return anims
    end
end

function skeletonClass:new(_skeletonType,_x,_y)
    local def=self.skeletonDefinitions[_skeletonType]

    local s={name=def.name}
    
    --Collider data
    s.collider=World:newBSGRectangleCollider(
        _x,_y,def.collider.width,def.collider.height,def.collider.corner
    )
    for fn,val in pairs(def.collider.modifiers) do
        s.collider[fn](s.collider,val)
    end
    s.collider:setFixedRotation(true) 
    s.collider:setCollisionClass('skeleton')
    s.collider:setObject(s)

    --General data
    s.x,s.y=s.collider:getPosition()
    s.health={current=def.health,max=def.health}
    s.moveSpeed=def.moveSpeed
    s.attackRange=def.attackRange
    s.attackSpeed=def.attackSpeed
    s.attackDamage=def.attackDamage
    s.knockback=def.knockback
    s.lungeSpeed=def.lungeSpeed or 0    
    s.canAttack=true
    s.moveTarget=s
    s.angle=0
    s.moveTargetOffset=0
    s.distanceFromPlayer=0
    s.returnToPlayerThreshold=150
    s.queryAttackTargetRate=1 --will target enemies every 1s
    s.canQueryAttackTarget=true 

    --Draw data
    s.xOffset=def.drawData.xOffset
    s.yOffset=def.drawData.yOffset
    s.scaleX=1
    s.spriteSheet=self.spriteSheets[def.name]
    s.animations=self:parseAnimations(
        s,self.grids[def.name],def.animations
    )
    s.animSpeed={min=0.25,max=3,current=1}
    s.damagingFrames=def.animations.attack.damagingFrames or 0
    
    --Actions/AI
    s.onLoopFunctions={}
    for i,fn in pairs(self.behaviors.onLoopFunctions) do
        s.onLoopFunctions[i]=fn(s)
    end
    s.methods={} --includes update and draw functions
    for i,method in pairs(self.behaviors.methods) do s[i]=method end 
    s.AI=self.behaviors.AI[s.name]

    s:changeState('raise')
    table.insert(Entities.table,s)
    return s
end

return skeletonClass
