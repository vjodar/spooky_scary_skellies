local player=World:newBSGRectangleCollider(0,0,11,5,3)    
player:setLinearDamping(20) --apply increased 'friction'
player:setFixedRotation(true) --collider won't spin/rotate
player:setCollisionClass('player')
player:setMass(10) --player is base unit for mass

player.name='player'
player.x,player.y=player:getPosition()
player.health={current=100,max=100}
player.moveSpeed=18000
player.queryForEnemiesRate=0.5 --will query for enemies every 0.5s
player.queryForEnemiesReady=true
player.nearbyEnemies={}
player.aggroRange={w=600,h=450}
player.attackRate=0.5
player.attackReady=true

player.scaleX=1 --used to flip sprites horizontally
player.canTurn=true --used to keep player facing a certain direction
player.xOffset,player.yOffset=10,19
player.spriteSheet=love.graphics.newImage('assets/entities/player.png')
player.grid=anim8.newGrid(20,19,player.spriteSheet:getWidth(),player.spriteSheet:getHeight())
player.animations={}
player.animations.idle=anim8.newAnimation(player.grid('1-4',1), 0.1)
player.animations.moving=anim8.newAnimation(player.grid('1-4',2), 0.1)
player.animations.current=player.animations.idle
player.animSpeed={min=0.25,max=3,current=1}

player.shadow=Shadows:new('player')

function player:update()
    self.animations.current:update(dt*self.animSpeed.current)
    self.x,self.y=self:getPosition()

    if self.queryForEnemiesReady then 
        Timer:setOnCooldown(self,'queryForEnemiesReady',self.queryForEnemiesRate)
        self.nearbyEnemies=self:queryForEnemies()
    end

    if acceptInput then 
        self:move()
        if Controls.down.mouse and self.attackReady then 
            self:launchBone() 
            Timer:setOnCooldown(self,'attackReady',self.attackRate)
        end
    end
end

function player:draw()
    self.shadow:draw(self.x,self.y)
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
        if self.canTurn then self.scaleX=-1 end 
        moving=true
    end
    if Controls.down.dirRight then
        target.x=target.x+1
        if self.canTurn then self.scaleX=1 end 
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

    self:applyForce(xVel,yVel)
end

--return a table of all enemies onscreen
function player:queryForEnemies() 
    local queryData={
        x=self.x-(self.aggroRange.w*0.5),
        y=self.y-(self.aggroRange.h*0.5),
        w=self.aggroRange.w,
        h=self.aggroRange.h,
        colliderNames={'enemy'}
    }    
    local targets=World:queryRectangleArea(
        queryData.x,queryData.y,queryData.w,queryData.h,queryData.colliderNames
    )
    return targets
end

function player:takeDamage(args)
    local damage=args.damage or 1
    local hp=self.health.current
    hp=max(0,hp-damage)
    self.health.current=hp
end

function player:launchBone()
    local mouseX,mouseY=Controls.getMousePosition()
    Projectiles:new({
        x=self.x,y=self.y,name='bone',attackDamage=1,knockback=1,
        angle=getAngle(Player,{x=mouseX,y=mouseY}),yOffset=-10
    })
    if mouseX>self.x then self.scaleX=1 
    else self.scaleX=-1 
    end
    Timer:setOnCooldown(self,'canTurn',0.2)
end

table.insert(Objects.table,player)

return player