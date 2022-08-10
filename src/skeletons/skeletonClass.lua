local skeletonClass={}

function skeletonClass:load()
    self.spriteSheets={
        warrior=love.graphics.newImage('assets/entities/skeleton_warrior.png'),
        archer=love.graphics.newImage('assets/entities/skeleton_archer.png'),
        mageFire=love.graphics.newImage('assets/entities/skeleton_mage_fire.png'),
        mageIce=love.graphics.newImage('assets/entities/skeleton_mage_ice.png'),
        mageElectric=love.graphics.newImage('assets/entities/skeleton_mage_electric.png'),
    }
    local function getWidth(_type) return self.spriteSheets[_type]:getWidth() end 
    local function getHeight(_type) return self.spriteSheets[_type]:getHeight() end 
    self.grids={
        warrior=anim8.newGrid(10,17,getWidth('warrior'),getHeight('warrior')),
        archer=anim8.newGrid(42,22,getWidth('archer'),getHeight('archer')),
        mage=anim8.newGrid(24,24,getWidth('mageFire'),getHeight('mageFire')),
    }

    self.skeletonDefinitions=require 'src/skeletons/skeletonDefinitions'
    self.behaviors=require 'src/skeletons/skeletonBehaviors'
    
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
    s.collider:setLinearDamping(def.collider.linearDamping)
    s.collider:setMass(def.collider.mass)
    s.collider:setFixedRotation(true) 
    s.collider:setCollisionClass('skeleton')
    s.collider:setObject(s)

    --General data
    s.x,s.y=s.collider:getPosition()
    s.moveSpeed=def.moveSpeed
    s.attackRange=def.attackRange
    s.moveTarget=s
    s.moveTargetOffset=0
    s.distanceFromPlayer=0
    s.returnToPlayerThreshold=100
    s.queryAttackTargetRate=1 --will target enemies every 1s
    s.queryAttackTargetReady=true 

    --Draw data
    s.xOffset=def.drawData.xOffset
    s.yOffset=def.drawData.yOffset
    s.scaleX=1
    s.spriteSheet=self.spriteSheets[def.name]
    s.animations=self:parseAnimations(
        s,self.grids[def.name],def.animations
    )
    s.animSpeed={min=0.25,max=3,current=1}
    
    --Actions/AI
    s.onLoopFunctions={}
    for i,fn in pairs(self.behaviors.onLoopFunctions) do
        s.onLoopFunctions[i]=fn(s)
    end
    s.changeState=self.behaviors.changeState
    s.AI=self.behaviors.AI[s.name]
    
    function s:update() self.AI[self.state](self) end
    function s:draw()
        self.animations.current:draw(
            self.spriteSheet,self.x,self.y,
            nil,self.scaleX,1,self.xOffset,self.yOffset
        )
    end

    s:changeState('raise')
    table.insert(Entities.table,s)
    return s
end

return skeletonClass
