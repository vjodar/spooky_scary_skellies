local player={name='player'}

--Collider data
player.x,player.y=0,0
player.w,player.h=12,7
player.center=getCenter(player)
player.vx,player.vy=0,0
player.moveSpeedMax=12*60 --12units/sec at 60fps 
player.moveSpeed=player.moveSpeedMax 
player.linearDamping=10
player.stopThreshold=3*60 --speed slow enough to consider stopped (at 60FPS)
player.collisionClass='ally'
player.collisionFilter=World.collisionFilters[player.collisionClass]

--General Data
player.health={current=500,max=500}
player.kbResistance=0
player.attack={
    damage=10,
    knockback=100,
    projectile={name='bone',yOffset=-10},
}
player.minionsPerSummon=1
player.maxMinions=5
player.selectedMage='Fire'
player.healthPerParticle=0.1
player.nearbyEnemies={}
player.aggroRange={w=600,h=450}
player.allyReturnThreshold={x=220,y=150} --distance from player before skeletons run back

player.upgrades={
    skeletonWarrior=true,
    skeletonArcher=false,
    skeletonMageFire=false,
    skeletonMageIce=false,
    skeletonMageElectric=false,
    boneShield=false,
    bounceBone=false,
    corpseExplosion=false,
    panicSummon=false,
    warriorIce=false,
    warriorElectric=false,
    bounceArrow=false,
    archerFire=false,
    archerIce=false,
    archerElectric=false,
}

local calculateBoneShieldAngles=function()
    local angles={}
    local boneCount=16
    local fraction=(2*pi)/boneCount 
    for i=1,boneCount do table.insert(angles,i*fraction) end
    return angles
end
player.boneShieldAngles=calculateBoneShieldAngles()

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
player.animSpeedMax=1
player.animSpeed=player.animSpeedMax 
player.scaleX=1 --used to flip sprites horizontally

--Shadow
player.shadow=Shadows:new('player',player.w,player.h)

--Status system
player.status=Statuses:new()

--Cooldown flags, periods, and callback functions
player.canTurn={flag=true,cooldownPeriod=0.2}
player.canTurn.setOnCooldown=Timer:giveCooldownCallbacks(player.canTurn)

player.canAttack={flag=true,cooldownPeriod=0.5}
player.canAttack.setOnCooldown=Timer:giveCooldownCallbacks(player.canAttack)

player.canSummon={flag=true,cooldownPeriod=6}
player.canSummon.setOnCooldown=Timer:giveCooldownCallbacks(player.canSummon)

player.canQueryAttackTargets={flag=true,cooldownPeriod=0.5}
player.canQueryAttackTargets.setOnCooldown=Timer:giveCooldownCallbacks(player.canQueryAttackTargets)

function player:update()
    if self.state=='dead' then return false end 

    self.animations.current:update(dt*self.animSpeed)
    self:updatePosition() --also handles collisions
    self.status:update(self)

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
        if self.canSummon.flag then 
            if Controls.pressed.btn1 then self:summonMinions('skeletonWarrior')
            elseif Controls.pressed.btn2 then self:summonMinions('skeletonArcher')
            elseif Controls.pressed.btn3 then 
                self:summonMinions('skeletonMage'..self.selectedMage) 
            end 
        end
    else 
        self.animations.current=self.animations.idle 
    end
end

function player:draw()
    if self.state=='dead' then return false end 

    self.shadow:draw(self.x,self.y)
    if self:isBurning() then love.graphics.setColor(1,0.8,0.8,1) end
    if self:isFrozen() then love.graphics.setColor(0.8,0.9,1,1) end 
    self.animations.current:draw(
        self.spriteSheet,self.x+self.xOffset,self.y+self.yOffset,
        nil,self.scaleX,1,self.xOrigin,self.yOrigin
    )
    love.graphics.setColor(1,1,1,1)
    -- --testing------------------------------------------
    -- love.graphics.print(self.center.x,self.x-10,self.y-10)
    -- love.graphics.print(self.center.y,self.x-10,self.y)
    -- love.graphics.print('STATES: '..#gameStates,self.x-10,self.y-30)
    -- love.graphics.print('objects: '..#Objects.table,self.x-10,self.y-60)
    -- love.graphics.print('items: '..World:countItems(),self.x-10,self.y-90)
    -- love.graphics.print('ENEMIES()[]: '..LevelManager.currentLevel.enemyCount,self.x-10,self.y-60)
    -- --testing------------------------------------------
end

function player:updatePosition()
    local goalX=self.x+self.vx*dt 
    local goalY=self.y+self.vy*dt 
    local realX,realY,cols,len=World:move(self,goalX,goalY,self.collisionFilter)
    self.x,self.y=realX,realY 
    local c=getCenter(self)
    self.center.x,self.center.y=c.x,c.y

    --apply friction/linearDamping
    self.vx=self.vx-(self.vx*self.linearDamping*dt)
    self.vy=self.vy-(self.vy*self.linearDamping*dt)

    --stop moving when sufficiently slow
    if abs(self.vx)<self.stopThreshold*dt then self.vx=0 end
    if abs(self.vy)<self.stopThreshold*dt then self.vy=0 end

    for i=1,len do
        local other=cols[i].other 
        if other.collisionClass=='ally' then --push allies out of the way
            local angle=getAngle(self.center,other.center)
            other.vx=other.vx+cos(angle)*self.moveSpeed*2*dt
            other.vy=other.vy+sin(angle)*self.moveSpeed*2*dt
        end

        if acceptInput then --wait for all other above states to close
            if other.name=='exit' then other:activateExit() end 
            if other.name=='chest' then other:activateChest() end 
        end
    end

    if LevelManager:isEntityOutOfBounds(self) then 
        LevelManager:returnEntityToLevel(self)
    end
end

function player:move()
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
        filter=World.queryFilters.enemy 
    }    
    local targets=World:queryRect(
        queryData.x,queryData.y,queryData.w,queryData.h,queryData.filter
    )     
    return targets
end

function player:takeDamage(args)
    if self.state=='dead' then print('dead') return end 

    local damage=max(args.damage,1)
    local knockback=args.knockback
    local kbAngle=args.angle
    knockback=knockback-knockback*(self.kbResistance/100)

    --Apply knockback force
    self.vx=self.vx+cos(kbAngle)*knockback
    self.vy=self.vy+sin(kbAngle)*knockback

    local damageTextColor=args.textColor or 'gray'
    UI.damage:new(self.center.x,self.center.y,floor(damage),damageTextColor)

    self:updateHealth(-damage)

    if self.upgrades.boneShield then
        for i=1,#self.boneShieldAngles do 
            local damage=self.attack.damage*0.25
            local knockback=self.attack.knockback*2
            Projectiles:new({
                x=self.center.x,y=self.center.y,name=self.attack.projectile.name,
                damage=damage,knockback=knockback,angle=self.boneShieldAngles[i],
                yOffset=self.attack.projectile.yOffset,
            })
        end
    end
end

function player:updateHealth(val)
    local newHealth=min(max(self.health.current+val,0),self.health.max)
    self.health.current=newHealth 
    Hud.health:calculateHeartPieces()

    if self.health.current==0 then self:die() end 
end

function player:die()
    self.state='dead'
    self.status:clear()
    self.animSpeed=self.animSpeedMax
    Camera:shake({magnitude=20,damping=2})    
    LevelManager:setEntityAggro(false)
    Timer:after(2,function()
        LevelManager:killEntities('ally')
    end)
    --TODO: do a game over thing here
end

function player:launchBone()
    local mouseX,mouseY=Controls.getMousePosition()
    Projectiles:new({
        x=self.center.x,y=self.center.y,name=self.attack.projectile.name,
        damage=self.attack.damage,knockback=self.attack.knockback,
        angle=getAngle(self.center,{x=mouseX,y=mouseY}),
        yOffset=self.attack.projectile.yOffset,
    })

    --face target direction, lock turning
    self.scaleX=(mouseX>self.center.x and 1 or -1)
    self.canTurn.setOnCooldown()
end

--Actually summons skeletal minions
function player:summon(name,count)
    for i=1,count do
        --spawn directly under player
        local skelly=Entities:new(name,self.x,self.y)
        
        --move skeleton using world collision to a point around player
        local angle=rnd()*2*pi 
        local distance=rnd()*(50+self.maxMinions)
        local goalX=self.x+cos(angle)*distance
        local goalY=self.y+sin(angle)*distance
        local realX,realY=World:move(skelly,goalX,goalY,skelly.collisionFilter)
        skelly.x,skelly.y=realX,realY
    end
end

--Uses summon() to summon minions, amount is definied by minionsPerSummon
--and limited by maxMinions and the canSummon cooldown
function player:summonMinions(name)
    if self.canSummon.flag==false then return end

    if not self.upgrades[name] then 
        --TODO: say "Can't summon that yet" message 
        print("can't summon",name)
        return
    end

    local currentMinionCount=LevelManager.currentLevel.allyTotal
    local availableMinionSlots=self.maxMinions-currentMinionCount

    if availableMinionSlots<1 then 
        --TODO: say "Max minions reached!" message
        return 
    end

    local summonCount=min(self.minionsPerSummon,availableMinionSlots)
    self:summon(name,summonCount)
    self.canSummon.setOnCooldown()
end

function player:isBurning() return #self.status.table.burn>0 end
function player:isFrozen() return #self.status.table.freeze>0 end

World:addItem(player)
table.insert(Objects.table,player)

return player