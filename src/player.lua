local player={name='player'}

--Collider data
player.x,player.y=0,0
player.w,player.h=12,7
player.center=getCenter(player)
player.vx,player.vy=0,0
player.moveSpeed=17*60 --17units/sec at 60fps 
player.linearDamping=10
player.stopThreshold=3*60 --speed slow enough to consider stopped (at 60FPS)
player.collisionClass='ally'
player.filter=World.collisionFilters[player.collisionClass]

--General Data
player.health={current=100,max=100}
player.nearbyEnemies={}
player.aggroRange={w=600,h=450}
player.attackPeriod=0.5
player.allyReturnThreshold={x=220,y=150} --distance from player before skeletons run back

--Draw data
player.spriteSheet=love.graphics.newImage('assets/entities/player.png')
player.frameWidth=20
player.frameHeight=19
player.xOffset=player.w*0.5
player.yOffset=(player.h-player.frameHeight)*0.5
player.xOrigin=player.frameWidth*0.5
player.yOrigin=player.frameHeight*0.5
player.grid=anim8.newGrid(
    player.frameWidth,player.frameHeight,
    player.spriteSheet:getWidth(),player.spriteSheet:getHeight()
)
player.animations={}
player.animations.idle=anim8.newAnimation(player.grid('1-4',1), 0.1)
player.animations.moving=anim8.newAnimation(player.grid('1-4',2), 0.1)
player.animations.current=player.animations.idle
player.animSpeed={min=0.25,max=3,current=1}
player.scaleX=1 --used to flip sprites horizontally

--Cooldown flags, periods, and callback functions
player.canTurn={flag=true,cooldownPeriod=0.2}
Timer:giveCooldownCallbacks(player.canTurn)

player.canAttack={flag=true,cooldownPeriod=player.attackPeriod}
Timer:giveCooldownCallbacks(player.canAttack)

player.canQueryAttackTargets={flag=true,cooldownPeriod=0.5}
Timer:giveCooldownCallbacks(player.canQueryAttackTargets)

--Shadow
player.shadow=Shadows:new('player',player.w,player.h)

function player:update()
    self.animations.current:update(dt*self.animSpeed.current)
    self:updatePosition() --also handles collisions

    if self.canQueryAttackTargets.flag then 
        self.canQueryAttackTargets.setOnCooldown()
        self.nearbyEnemies=self:queryForEnemies()
    end

    if acceptInput then 
        self:move()
        if Controls.down.mouse and self.canAttack.flag then 
            self:launchBone() 
            self.canAttack.setOnCooldown()
        end
    end
end

function player:draw()
    self.shadow:draw(self.x,self.y)
    self.animations.current:draw(
        self.spriteSheet,self.x+self.xOffset,self.y+self.yOffset,
        nil,self.scaleX,1,self.xOrigin,self.yOrigin
    )
    -- --testing------------------------------------------
    -- love.graphics.print(self.vx,self.x-10,self.y-10)
    -- love.graphics.print(self.vy,self.x-10,self.y)
    love.graphics.print(love.timer.getFPS(),self.x-10,self.y-30)
    love.graphics.print(#Objects.table,self.x-10,self.y-60)
    -- --testing------------------------------------------
end

function player:updatePosition()
    local goalX=self.x+self.vx*dt 
    local goalY=self.y+self.vy*dt 
    local realX,realY,cols=World:move(self,goalX,goalY,self.filter)
    self.x,self.y=realX,realY 
    self.center=getCenter(self)

    --apply friction/linearDamping
    self.vx=self.vx-(self.vx*self.linearDamping*dt)
    self.vy=self.vy-(self.vy*self.linearDamping*dt)

    --stop moving when sufficiently slow
    if abs(self.vx)<self.stopThreshold*dt then self.vx=0 end
    if abs(self.vy)<self.stopThreshold*dt then self.vy=0 end

    --handle collisions
    for i=1,#cols do
        local other=cols[i].other --other collider
        local touch=cols[i].touch --point of collision
    
        local magnitude=getMagnitude(player.vx,player.vy)         
        local angleBefore=getAngle(player,touch)
        local angleAfter=angleBefore+pi 
    
        self.vx=cos(angleAfter)*magnitude
        self.vy=sin(angleAfter)*magnitude
    end
end

function player:move()
    if not acceptInput then return end 

    local moving=false
    local target={x=self.x,y=self.y} --used to find angle to goal

    --Change velocity by finding angle to target
    if Controls.down.dirLeft then
        target.x=target.x-1
        if self.canTurn.flag then self.scaleX=-1 end 
        moving=true
    end
    if Controls.down.dirRight then
        target.x=target.x+1
        if self.canTurn.flag then self.scaleX=1 end 
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
        --use angle to get new (normalized) velocity vector
        local angle=getAngle(self,target)
        local vxIncrement=cos(angle)*self.moveSpeed*dt 
        local vyIncrement=sin(angle)*self.moveSpeed*dt 

        if target.x~=self.x then self.vx=self.vx+vxIncrement end 
        if target.y~=self.y then self.vy=self.vy+vyIncrement end

        self.animations.current=self.animations.moving
    else 
        self.animations.current=self.animations.idle
    end
end

--return a table of all enemies onscreen
function player:queryForEnemies() 
    local queryData={
        x=self.center.x-(self.aggroRange.w*0.5),
        y=self.center.y-(self.aggroRange.h*0.5),
        w=self.aggroRange.w,
        h=self.aggroRange.h,
        filter=World.queryFilters.ally 
    }    
    local targets=World:queryRect(
        queryData.x,queryData.y,queryData.w,queryData.h,queryData.filter
    )     
    return targets
end

function player:takeDamage(source)
    local hp=self.health.current 
    local damage=source.attackDamage or 0 
    local knockback=source.knockback or 0
    local kbAngle=getAngle(source.center,self.center)
    
    hp=max(0,hp-damage)
    self.health.current=hp

    --Apply knockback force
    self.vx=self.vx+cos(kbAngle)*knockback
    self.vy=self.vy+sin(kbAngle)*knockback

    if self.health.current==0 then print("I'm dead! :O") end
end

function player:launchBone()
    local mouseX,mouseY=Controls.getMousePosition()
    Projectiles:new({
        x=self.center.x,y=self.center.y,name='bone',
        attackDamage=1,knockback=500,
        angle=getAngle(self.center,{x=mouseX,y=mouseY}),yOffset=-10
    })

    --testing-----------------------------------------------
    -- self.collisionClass='enemy'
    -- Projectiles:new({
    --     x=mouseX,y=mouseY,name='bone',attackDamage=1,knockback=200,
    --     angle=getAngle({x=mouseX,y=mouseY},getCenter(Player)),yOffset=-10
    -- })
    --testing-----------------------------------------------

    --face target direction, lock turning
    self.scaleX=(mouseX>self.x and 1 or -1)
    self.canTurn.setOnCooldown()
end

World:addItem(player)
table.insert(Objects.table,player)

return player