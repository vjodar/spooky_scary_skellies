local player={}

function player:load(_x,_y)
    self.collider=World:newBSGRectangleCollider(_x,_y,12,5,3)    
    self.collider:setLinearDamping(20) --apply increased 'friction'
    self.collider:setFixedRotation(true) --collider won't spin/rotate
    self.collider:setCollisionClass('player')
    self.collider:setObject(self) --attach collider to this object
    self.collider:setMass(10) --player is base unit for mass

    self.x,self.y=self.collider:getPosition()
    self.scaleX=1 --used to flip sprites horizontally
    self.moveSpeed=24000
    
    self.xOffset,self.yOffset=10,19
    self.spriteSheet=love.graphics.newImage('assets/entities/player.png')
    self.grid=anim8.newGrid(20,19,self.spriteSheet:getWidth(),self.spriteSheet:getHeight())
    self.animations={}
    self.animations.idle=anim8.newAnimation(self.grid('1-4',1), 0.1)
    self.animations.moving=anim8.newAnimation(self.grid('1-4',2), 0.1)
    self.animations.current=self.animations.idle
    self.animSpeed={min=0.25,max=3,current=1}

    table.insert(Entities.table,self)
end

function player:update()
    self.animations.current:update(dt*self.animSpeed.current)
    self:move()
    self.x,self.y=self.collider:getPosition()
end

function player:draw()
    self.animations.current:draw(
        self.spriteSheet,self.x,self.y,
        nil,self.scaleX,1,self.xOffset,self.yOffset
    )
end

function player:move()
    if not acceptInput then return end 

    local moving=false
    local xVel,yVel=0,0
    local target={x=self.x,y=self.y}

    if Controls.down.dirLeft then
        target.x=target.x-1
        self.scaleX=-1
        moving=true
    end
    if Controls.down.dirRight then
        target.x=target.x+1
        self.scaleX=1
        moving=true 
    end
    if Controls.down.dirUp then
        target.y=target.y-1
        moving=true 
    end
    if Controls.down.dirDown then
        target.y=target.y+1
        moving=true 
    end

    if moving then 
        local angle=atan2((target.y-self.y),(target.x-self.x))
        if target.x~=self.x then xVel=(cos(angle)*self.moveSpeed) end 
        if target.y~=self.x then yVel=(sin(angle)*self.moveSpeed) end

        self.animations.current=self.animations.moving
    else 
        self.animations.current=self.animations.idle
    end

    self.collider:applyForce(xVel,yVel)
end

return player
