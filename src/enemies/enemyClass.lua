local enemyClass={}

function enemyClass:load()
    self.spriteSheets={
        slime=love.graphics.newImage('assets/entities/slime.png'),
    }
    local function getWidth(_type) return self.spriteSheets[_type]:getWidth() end 
    local function getHeight(_type) return self.spriteSheets[_type]:getHeight() end 
    self.grids={
        slime=anim8.newGrid(16,14,getWidth('slime'),getHeight('slime')),
    }

    self.enemyDefinitions=require 'src/enemies/enemyDefinitions'
    self.behaviors=require 'src/enemies/enemyBehaviors'
    
    --Creates a table of animations given an enemy, grid, and animation defs
    function self:parseAnimations(_enemy,_grid,_animDefs)
        local anims={}  
        for anim,def in pairs(_animDefs) do
            local onLoopFn=function() end 
            if def.onLoop then
                onLoopFn=self.behaviors.onLoopFunctions[def.onLoop](_enemy)
            end 
            anims[anim]=anim8.newAnimation(
                _grid(def.frames,def.row),def.duration,onLoopFn
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
    e.collider:setLinearDamping(def.collider.linearDamping)
    e.collider:setMass(def.collider.mass)
    e.collider:setFixedRotation(true) 
    e.collider:setCollisionClass('enemy')
    e.collider:setObject(e)

    --General data
    e.x,e.y=e.collider:getPosition()
    e.moveSpeed=def.moveSpeed
    e.moveTarget=e
    e.attackRange=def.attackRange 
    e.aggroRange={w=400,h=300}
    e.nearbyAttackTargets={}
    e.queryAttackTargetRate=1 --check for targets every 1s
    e.queryAttackTargetReady=true

    --Draw data
    e.xOffset=def.drawData.xOffset
    e.yOffset=def.drawData.yOffset
    e.scaleX=1
    e.spriteSheet=self.spriteSheets[def.name]
    e.animations=self:parseAnimations(
        e,self.grids[def.name],def.animations
    )
    e.animSpeed={min=0.25,max=3,current=1}
    
    --Actions/AI
    e.onLoopFunctions={}
    for i,fn in pairs(self.behaviors.onLoopFunctions) do 
        e.onLoopFunctions[i]=fn(e)
    end
    e.changeState=self.behaviors.changeState
    e.AI=self.behaviors.AI[e.name]    
    function e:update() self.AI[self.state](self) end
    function e:draw()
        self.animations.current:draw(
            self.spriteSheet,self.x,self.y,
            nil,self.scaleX,1,self.xOffset,self.yOffset
        )
    end

    e:changeState('idle')
    table.insert(Entities.table,e)
    return e
end

return enemyClass
