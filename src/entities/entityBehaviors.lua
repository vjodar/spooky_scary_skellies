local behaviors={}

behaviors.methods={} --Methods---------------------------------------------------------------------
behaviors.methods.common={

    update=function(self)
        return self.AI[self.state](self) 
    end,

    draw=function(self)
        --during spawn animation, only draw shadow when sprite is visible
        if self.state~='spawn' or self:onVisibleFrame() then 
            self.shadow:draw(self.x,self.y) --always draw shadow in any other state
        end
        if self:isBurning() then love.graphics.setColor(1,0.8,0.8,1) end
        if self:isFrozen() then love.graphics.setColor(0.8,0.9,1,1) end 
        self.animations.current:draw(
            self.spriteSheet,self.x+self.xOffset,self.y+self.yOffset,
            nil,self.scaleX,1,self.xOrigin,self.yOrigin
        )
        love.graphics.setColor(1,1,1,1)
    end,

    changeState=function(self,newState)
        self.state=newState 
        local associatedAnimation={
            spawn='spawn',
            idle='idle',
            idleCutscene='idle',
            attack='attack',
            despawn='despawn',
            dead='dead',
            moveToPlayer='move',
            moveToTarget='move',
            moveToLocation='move',
            teleport='teleport',
            fireball='fireball',                --obsidianGolem
            groundslam='groundslam',            --obsidianGolem
            projectile='projectile',            --witch
            chainLightning='chainLightning',    --witch
            clone='teleport',                   --witch
        }
        if self.animations[associatedAnimation[newState]] then
            self.animations.current=self.animations[associatedAnimation[newState]]
        end
    end,

    isBurning=function(self)
        return #self.status.table.burn>0 
    end,

    isFrozen=function(self)
        return #self.status.table.freeze>0
    end,

    move=function(self)
        --apply a force in the entity's angle to move it
        local fx=cos(self.angle)*self.moveSpeed*dt 
        local fy=sin(self.angle)*self.moveSpeed*dt 
        self.vx=self.vx+fx
        self.vy=self.vy+fy
    end,

    updatePosition=function(self)
        local goalX=self.x+self.vx*dt 
        local goalY=self.y+self.vy*dt 
        local realX,realY,cols,len=World:move(self,goalX,goalY,self.collisionFilter)
        self.x,self.y=realX,realY 
        local c=getCenter(self)
        self.center.x,self.center.y=c.x,c.y

        --update angle/direction, face target
        self.angle=getAngle(self.center,self.moveTarget.center)
        if self.moveTarget~=self then --only turn when moving
            self.scaleX=self.moveTarget.center.x>self.center.x and 1 or -1
        end
    
        --apply friction/linearDamping
        self.vx=self.vx-(self.vx*self.linearDamping*dt)
        self.vy=self.vy-(self.vy*self.linearDamping*dt)
    
        --stop moving when sufficiently slow
        if abs(self.vx)<self.stopThreshold*dt then self.vx=0 end
        if abs(self.vy)<self.stopThreshold*dt then self.vy=0 end        

        --push entities of same class out of the way (except player)
        for i=1,len do
            local other=cols[i].other 
            if other.collisionClass==self.collisionClass
            and other.name~='player' 
            then 
                local angle=getAngle(self.center,other.center)
                other.vx=other.vx+cos(angle)*other.moveSpeed*dt
                other.vy=other.vy+sin(angle)*other.moveSpeed*dt
            end
        end

        if LevelManager:isEntityOutOfBounds(self) then 
            LevelManager:returnEntityToLevel(self)
        end

        return cols --return the collisions this move produced
    end,

    updateAnimation=function(self)
        return self.animations.current:update(dt*self.animSpeed)
    end,

    takeDamage=function(self,args) --args={damage,knockback,angle,textColor,sfx}
        if self.state=='dead' then return end 

        local damage=max(args.damage,1)
        local knockback=args.knockback
        local kbAngle=args.angle
        knockback=knockback-knockback*(self.kbResistance/100)
        
        self.health.current=max(self.health.current-damage,0)

        --Apply knockback force
        self.vx=self.vx+cos(kbAngle)*knockback
        self.vy=self.vy+sin(kbAngle)*knockback

        local damageTextColor=args.textColor or 'gray'
        UI.damage:new(self.center.x,self.center.y,floor(damage),damageTextColor)

        if self.name=='skeletonWarrior' 
        and Player.upgrades.warriorElectric 
        then --discharge
            for i=1,4 do 
                Projectiles:new({
                    x=self.center.x,y=self.center.y,name='spark',
                    damage=self.attack.damage*0.25,knockback=self.attack.knockback*0.25,
                    angle=rnd()*2*pi,yOffset=-7,
                })
            end
        end

        local sfx=args.sfx or 'hitDefault'
        Audio:playSfx(sfx)

        if self.health.current==0 then self:die() end
    end,

    die=function(self)
        self.status:clear(self)
        self.animSpeed=self.animSpeedMax
        self:changeState('dead')
        if self.name=='witch' and self.dialog then 
            self.dialog:say("NOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO!")
        end
    end,

    clearMoveTarget=function(self)
        self.moveTarget=self
    end,

    onDamagingFrames=function(self)
        return self.animations.current.position >= self.damagingFrames[1]
            and self.animations.current.position <= self.damagingFrames[2]
    end,

    onFiringFrame=function(self)
        return self.animations.current.position==self.firingFrame
    end, 

    onSpawnMinionFrame=function(self)
        return self.animations.current.position==self.spawnMinionFrame
    end,

    onVisibleFrame=function(self)
        return self.animations.current.position>=self.visibleFrame 
    end,
}

behaviors.methods.ally={

    --if skeleton is too far from player, return to near the player
    remainNearPlayer=function(self)
        if abs(Player.center.x-self.center.x)>Player.allyReturnThreshold.x
        or abs(Player.center.y-self.center.y)>Player.allyReturnThreshold.y
        then
            self:setNearPlayerMoveTarget()
            self:changeState('moveToPlayer')
            return false 
        end
        return true 
    end,

    setNearPlayerMoveTarget=function(self)
        --choose an offset from the player's center point
        local xRange=Player.allyReturnThreshold.x*0.5
        local yRange=Player.allyReturnThreshold.y*0.5
        self.nearPlayerLocation={x=rnd(-xRange,yRange),y=rnd(-yRange,yRange)}

        --set moveTarget to Player position offset by nearPlayerLocation 
        --needs to be a table with a center field to work with self:move()
        self.moveTarget={center={
            x=Player.center.x+self.nearPlayerLocation.x,
            y=Player.center.y+self.nearPlayerLocation.y,
        }}
    end,

    --Gets the closest attack target within LOS from the Player's nearbyEnemies table
    getNearestAllyAttackTarget=function(self)
        local nearbyEnemies=Player.nearbyEnemies
        
        --filter out any targets blocked from LOS
        local validTargets={}
        for i=1, #nearbyEnemies do 
            local e=nearbyEnemies[i]
            local _,len = World:querySegment(
                self.center.x,self.center.y,
                e.center.x,e.center.y,self.losFilter
            )
            if len==0 then table.insert(validTargets,e) end
        end        
        if #validTargets==0 then return self end --nothing nearby in LOS
        
        local closest=nil --find and return the closest target
        for i=1, #validTargets do 
            local dist=getDistance(self,validTargets[i])
            if closest==nil or closest.d>dist then 
                closest={t=validTargets[i],d=dist} 
            end
        end
        return closest.t
    end,
}

behaviors.methods.enemy={    

    queryForEnemyAttackTargets=function(self)
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
    end,

    --queries in 8 directions around enemy to find possible locations free of
    --entity specific obstructions, then sets one of those to moveTarget.
    setLocationMoveTarget=function(self)
        --distance is 10 to 200 units at moveSpeed=10
        local unit=10/(self.moveSpeed/60)
        local distance=rnd(unit*10,unit*200)
        local locations={
            {center={x=self.center.x,y=self.center.y-distance}},
            {center={x=self.center.x+distance,y=self.center.y-distance}},
            {center={x=self.center.x+distance,y=self.center.y}},
            {center={x=self.center.x+distance,y=self.center.y+distance}},
            {center={x=self.center.x,y=self.center.y+distance}},
            {center={x=self.center.x-distance,y=self.center.y+distance}},
            {center={x=self.center.x-distance,y=self.center.y}},
            {center={x=self.center.x-distance,y=self.center.y-distance}},
        }
        local validLocations={}
        for i=1,8 do
            local l=locations[i]
            local _,len=World:querySegment(
                self.center.x,self.center.y,l.center.x,l.center.y,self.moveFilter
            )
            if len==0 then table.insert(validLocations,l) end
        end
        --of the remaining valid locations, choose a random one to set as moveTarget
        if #validLocations>0 then
            self.moveTarget=rndElement(validLocations)
        else --if no valid locations remain, clear moveTarget (moveTaget=self)
            self:clearMoveTarget()
        end
    end,
    
    --Gets the closest attack target within LOS
    getNearestEnemyAttackTarget=function(self)
        local nearbyAttackTargets=self:queryForEnemyAttackTargets()
        
        --filter out any targets blocked from LOS
        local validTargets={}
        for i=1, #nearbyAttackTargets do 
            local e=nearbyAttackTargets[i]
            local _,len = World:querySegment(
                self.center.x,self.center.y,
                e.center.x,e.center.y,self.losFilter
            )
            if len==0 then table.insert(validTargets,e) end
        end        
        if #validTargets==0 then return self end --nothing nearby in LOS
        
        local closest=nil --find and return the closest target
        for i=1, #validTargets do
            local dist=getDistance(self,validTargets[i])
            if closest==nil or closest.d>dist then 
                closest={t=validTargets[i],d=dist} 
            end
        end
        return closest.t
    end,

    spawnMinions=function(self)
        local spawnPoint=self.attack.minion.spawnPoint or 'center'
        local minionName=self.attack.minion.name
        local count=self.attack.minion.count or 1
        local startState=self.attack.minion.startState
        Audio:playSfx(self.sfx.summon)
        
        --spawn minion in center of spawner (with small deviation for natural
        --spread when multiple minions spawn at once)
        if spawnPoint=='center' then 
            local goalX,goalY=self.x,self.y
            for i=1,count do 
                local minion=Entities:new(minionName,goalX,goalY,startState)
                local realX,realY=World:move(
                    minion,goalX+rnd()-0.5,goalY+rnd()-0.5,
                    minion.collisionFilter
                )
                minion.x,minion.y=realX,realY
            end
            return 
        end

        --spawn minion toward direction spawner is facing
        if spawnPoint=='facing' then 
            local minionDimensions=Entities.definitions[minionName].collider
            local minionCenter={x=minionDimensions.w*0.5,y=minionDimensions.h*0.5}
            local goalX=self.scaleX==1 and self.x+self.w-minionCenter.x or self.x-minionCenter.x
            local goalY=self.center.y-minionCenter.y
            for i=1,count do 
                local minion=Entities:new(minionName,self.x,self.y,startState)
                local realX,realY=World:move(minion,goalX,goalY,minion.collisionFilter)
                minion.x,minion.y=realX,realY
            end
            return 
        end

        --spawn minion at a random point around the spawner
        if spawnPoint=='random' then 
            for i=1,count do 
                local minionDimensions=Entities.definitions[minionName].collider 
                local minionHalfWidth=minionDimensions.w*0.5
                local minionHalfHeight=minionDimensions.h*0.5
                local minion=Entities:new(
                    minionName,self.center.x-minionHalfWidth,
                    self.center.y-minionHalfHeight,startState
                ) 
                local minDistance=(self.w*0.5)+minionHalfWidth
                local maxDistance=self.attack.minion.maxDistance or 1
                local angle=rnd()*2*pi
                local distance=minDistance+rnd()*maxDistance
                local goalX=minion.x+(cos(angle)*distance)
                local goalY=minion.y+(sin(angle)*distance)
                local realX,realY=World:move(minion,goalX,goalY,minion.collisionFilter)
                minion.x,minion.y=realX,realY
            end
            return 
        end

        --Use the levelManager's gridClass to spawn minions throughout level's spawn area
        if spawnPoint=='level' then 
            local minionsToSpawn={}
            minionsToSpawn[minionName]=count 
            LevelManager.gridClass:generateEnemies(
                minionsToSpawn,Entities,LevelManager.currentLevel.grid 
            )
        end
    end,
}

behaviors.states={} --States-----------------------------------------------------------------------
behaviors.states.common={
    spawn=function(self)
        self:updatePosition()
        self.status:update(self)
        local onLoop=self:updateAnimation()
        if onLoop then self:changeState('idle') end
    end,
    
    dead=function(self) 
        --if there's a death animation, wait for it to finish
        if self.animations.dead then
            self.animSpeed=self.animSpeedMax
            local onLoop=self:updateAnimation()
            if not onLoop then return end 
        end

        if Player.upgrades.corpseExplosion then
            if self.collisionClass=='enemy'
            and self.name~='spiderEgg' --spiderEggs are the exception
            then
                local angles=Player.boneShieldAngles
                local playerAttack=Player.attack 
                local damage=self.health.max/16
                for i=1,#angles do  
                    Projectiles:new({ 
                        x=self.center.x,y=self.center.y,name=playerAttack.projectile.name,
                        damage=damage,knockback=playerAttack.knockback,
                        angle=angles[i],yOffset=-10,
                    })
                end
            end
        end

        --destroy enemy, emit particle explosion, shake camera
        self.particles:emit(self.center.x,self.center.y)
        LevelManager:decreaseEntityCount(self.collisionClass,self.name)
        if self.deathShake then 
            local shake=self.deathShake 
            Camera:shake({
                magnitude=shake.magnitude,
                period=shake.period,
                damping=shake.damping,
                stopThreshold=shake.stopThreshold,
            })
        end

        Audio:playSfx(self.sfx.death)
        return false
    end,

    shoot=function(self)
        self:updatePosition()
        self.status:update(self)
        local onLoop=self:updateAnimation()
        if onLoop then self:changeState('idle') end 

        if self.canAttack.flag and self:onFiringFrame() then
            self.canAttack.setOnCooldown()
            local projectile={
                name=self.attack.projectile.name,
                x=self.center.x+self.attack.projectile.xOffset*self.scaleX,
                y=self.center.y,yOffset=self.attack.projectile.yOffset
            }
            local count=self.attack.projectile.count or 1
            local spread=self.attack.projectile.spread or 0
            for i=1,count do
                local angleToTarget=getAngle(projectile,self.moveTarget.center)
                if spread~=0 then 
                    angleToTarget=angleToTarget+(rnd()*spread-spread*0.5)
                end
                Projectiles:new({
                    x=projectile.x,y=projectile.y,name=projectile.name,
                    damage=self.attack.damage,knockback=self.attack.knockback,
                    angle=angleToTarget,yOffset=projectile.yOffset
                })
            end
        end
    end,
}

behaviors.states.ally={
    idleMelee=function(self)
        self:updateAnimation()
        self:updatePosition()
        self.status:update(self)
        if self:remainNearPlayer()==false then return end

        --if target is a living enemy and skeleton can attack,
        --move toward the target in order to attack.
        if self.moveTarget~=self and self.moveTarget.state~='dead' then 
            if self.canAttack.flag and LevelManager:getEntityAggro()==true then 
                self:changeState('moveToTarget') 
            end 
            return --return to wait until attack is ready or target dies          
        end
    
        --find and target the nearest enemy
        if self.canQueryAttackTargets.flag then 
            self.canQueryAttackTargets.setOnCooldown()
            self.moveTarget=self:getNearestAllyAttackTarget()
            if self.moveTarget~=self and LevelManager:getEntityAggro()==true then 
                self:changeState('moveToTarget') 
                return 
            end
        end

        --if idling for too long, wander around near player
        self.idleTime=self.idleTime+dt 
        if self.idleTime>self.maxIdleTime then 
            self.idleTime=rnd()
            self:setNearPlayerMoveTarget()
            self:changeState('moveToPlayer')
            return 
        end
    end,

    idleRanged=function(self)
        self:updateAnimation()
        self:updatePosition()
        self.status:update(self)
        if self:remainNearPlayer()==false then return end

        --if target is a living enemy, move toward target to attack if attack
        --is off cooldown, otherwise relocate to another position near player.
        if self.moveTarget~=self and self.moveTarget.state~='dead' then 
            if self.canAttack.flag and LevelManager:getEntityAggro()==true then 
                self:changeState('moveToTarget')
            else 
                self:setNearPlayerMoveTarget()
                self:changeState('moveToPlayer')        
            end
            return
        end
    
        --find and target the nearest enemy
        if self.canQueryAttackTargets.flag then 
            self.canQueryAttackTargets.setOnCooldown()
            self.moveTarget=self:getNearestAllyAttackTarget()
            if self.moveTarget~=self and LevelManager:getEntityAggro()==true then 
                self:changeState('moveToTarget') 
                return 
            end
        end

        --if idling for too long, wander around near player
        self.idleTime=self.idleTime+dt 
        if self.idleTime>self.maxIdleTime then 
            self.idleTime=rnd()
            self:setNearPlayerMoveTarget()
            self:changeState('moveToPlayer')
            return 
        end
    end,

    moveToTarget=function(self) 
        self:updateAnimation()
        self:updatePosition()
        self.status:update(self)
        if self:remainNearPlayer()==false then return end
    
        --if moveTarget has died or has been cleared, return to idle
        if self.moveTarget.state=='dead' or self.moveTarget==self then
            self:clearMoveTarget()
            self:changeState('idle')
            return 
        end 
    
        --continue looking for closer targets 
        if self.canQueryAttackTargets.flag then 
            self.canQueryAttackTargets.setOnCooldown()
            self.moveTarget=self:getNearestAllyAttackTarget()
            if self.moveTarget==self then self:changeState('idle') return end
        end
    
        if getRectDistance(self,self.moveTarget)<self.attack.range then             
            if self.canAttack.flag and LevelManager:getEntityAggro()==true then 
                self:changeState('attack') 
                return 
            else self:changeState('idle') return
            end
        end

        self:move()
    end,

    moveToPlayer=function(self) 
        self:updateAnimation()
        self:updatePosition()
        self.status:update(self)
    
        --if moveTarget has died or has been cleared, return to idle
        if self.moveTarget.state=='dead' or self.moveTarget==self then
            self:clearMoveTarget()
            self:changeState('idle')
            return 
        end 
    
        --reached nearby player location  
        if getDistance(self.moveTarget.center,self.center)<self.w then 
            self:clearMoveTarget()
            self:changeState('idle')
            return
        end        

        --if moving for too long, pick another location (possibly stuck)
        self.idleTime=self.idleTime+dt 
        if self.idleTime>self.maxIdleTime then 
            self.idleTime=rnd()
            self:setNearPlayerMoveTarget()
            return 
        end

        --if an enemy is nearby, move to attack it only if skeleton
        --is within 70% of return threshold
        if self.canQueryAttackTargets.flag and self.canAttack.flag then
            self.canQueryAttackTargets.setOnCooldown()
            local nearbyTarget=self:getNearestAllyAttackTarget()
            if nearbyTarget~=self 
            and LevelManager:getEntityAggro()==true
            and abs(Player.center.x-self.center.x)<Player.allyReturnThreshold.x*0.7
            and abs(Player.center.y-self.center.y)<Player.allyReturnThreshold.y*0.7
            then
                self.moveTarget=nearbyTarget 
                self:changeState('moveToTarget')
                return
            end 
        end
        
        --update moveTarget to be same nearby location relative to Player
        self.moveTarget={center={
            x=Player.center.x+self.nearPlayerLocation.x,
            y=Player.center.y+self.nearPlayerLocation.y,
        }}
        
        self:move()
    end,
    
    lunge=function(self)
        self.status:update(self)
        local onLoop=self:updateAnimation()
        if onLoop then 
            self.targetsAlreadyAttacked={}
            self:changeState('idle') 
        end 

        local collisions=self:updatePosition()        
        if self:onDamagingFrames() then
            if self.canAttack.flag then 
                self.canAttack.setOnCooldown()
                local fx=cos(self.angle)*self.attack.lungeForce
                local fy=sin(self.angle)*self.attack.lungeForce
                self.vx=self.vx+fx
                self.vy=self.vy+fy  
                Audio:playSfx(self.sfx.lunge)
            end
    
            --handle collisions
            for i=1,#collisions do
                local other=collisions[i].other --other collider
                
                if other.collisionClass=='enemy' then 
                    --Only hurt targets once per attack
                    for i=1,#self.targetsAlreadyAttacked do 
                        if other==self.targetsAlreadyAttacked[i] then return end
                    end

                    local touch=collisions[i].touch --point of collision     
                    local magnitude=getMagnitude(self.vx,self.vy)         
                    local angle=getAngle(touch,self)

                    --bounce self away from target, losing some momentum
                    self.vx=cos(angle)*magnitude*self.restitution
                    self.vy=sin(angle)*magnitude*self.restitution

                    --damage target, add to targetsAlreadyAttacked
                    other:takeDamage({
                        damage=self.attack.damage,
                        knockback=self.attack.knockback,
                        angle=getAngle(self.center,other.center),
                        textColor=Player.upgrades.warriorIce and 'blue' or 'gray',
                    })
                    if other.state~='dead' and Player.upgrades.warriorIce then 
                        other.status:freeze(other,2,0.5) --slow to half speed for 2s
                    end 
                    table.insert(self.targetsAlreadyAttacked,other)
                end
            end    
        end
    end,

    chainLightning=function(self)
        self:updatePosition()
        self.status:update(self)
        local onLoop=self:updateAnimation()
        if onLoop then self:changeState('idle') end 

        if self.canAttack.flag and self:onFiringFrame() then
            self.canAttack.setOnCooldown()
            local targets={self.moveTarget}
            local range=self.attack.range 
            local queryFilter=World.queryFilters.enemy 
            for i=1,4 do --chains up to 4 additional targets
                prevTarget=targets[#targets]
                --query all enemies surrounding the last target
                local nearbyEnemies=World:queryRect(
                    prevTarget.center.x-range,
                    prevTarget.center.y-range,
                    range*2,range*2,queryFilter  
                )
                --filter out the last target from nearbyEnemies
                for j,enemy in ipairs(nearbyEnemies) do 
                    for k=1,#targets do 
                        if enemy==targets[k] then 
                            table.remove(nearbyEnemies,j) 
                        end 
                    end
                end
                table.insert(targets,rndElement(nearbyEnemies))
            end
            SpecialAttacks:chainLightning(self,targets)
        end
    end,
    
    kamakaze=function(self) 
        --if there's a death animation, wait for it to finish
        if self.animations.dead then
            self.animSpeed=self.animSpeedMax
            local onLoop=self:updateAnimation()
            if not onLoop then return end 
        end

        --destroy enemy, emit particle explosion, shake camera
        self.particles:emit(self.center.x,self.center.y)
        LevelManager:decreaseEntityCount(self.collisionClass,self.name)
        if self.deathShake then 
            local shake=self.deathShake 
            Camera:shake({
                magnitude=shake.magnitude,
                period=shake.period,
                damping=shake.damping,
                stopThreshold=shake.stopThreshold,
            })
        end
        
        local explosionRadius=100 --twice the radius of fireball
        local explosionDamage=self.health.max --damage equal to max health
        local queryData={
            x=self.x-explosionRadius*0.5,
            y=self.y-explosionRadius*0.5,
            w=explosionRadius,h=explosionRadius
        }
        local filter=World.queryFilters.enemy
        local targets=World:queryRect(
            queryData.x,queryData.y,queryData.w,queryData.h,filter
        )
        for i=1,#targets do 
            local target=targets[i]
            target:takeDamage({                 
                damage=explosionDamage,
                knockback=self.attack.knockback*2,
                angle=getAngle(self.center,targets[i].center),
                textColor='red',
            })
            if target.state~='dead' then 
                target.status:burn(explosionDamage*0.5,5) --burn for 5s
            end
        end

        Camera:shake({magnitude=10})
        Audio:playSfx('explodeOrb')

        return false
    end,
}

behaviors.states.enemy={
    spawnGiantTombstone=function(self)
        self:updatePosition()
        self.status:update(self)
        local onLoop=self:updateAnimation()
        if onLoop then 
            self:changeState('idle') 
            Audio:playSfx('obsidianGolemSlam')
        end
        Camera:shakeBypass({magnitude=20*dt,stopThreshold=0}) --shake camera during spawn
    end,

    spawnObsidianGolem=function(self)
        self:updatePosition()
        self.status:update(self)
        local onLoop=self:updateAnimation()
        if self.animations.current.position==15 then 
            Camera:shakeBypass({magnitude=80*dt,damping=2}) --shake camera upon landing
            Audio:playSfx('obsidianGolemSlam')
        end
        if onLoop then 
            self:changeState('idle') 
        end
    end,

    idleMelee=function(self) 
        self:updateAnimation()
        self:updatePosition()
        self.status:update(self)

        --if target is a living skeleton and enemy can attack,
        --move toward the target in order to attack.
        if self.moveTarget~=self 
        and LevelManager:getEntityAggro()==true
        and self.moveTarget.state~='dead' 
        then 
            if self.canAttack.flag 
            or getRectDistance(self,self.moveTarget)>self.attack.range 
            then self:changeState('moveToTarget') end 
            return --return to wait until attack is ready or target dies          
        end
        
        --find and target the nearest skeleton/player
        if self.canQueryAttackTargets.flag then
            self.canQueryAttackTargets.setOnCooldown()
            self.moveTarget=self:getNearestEnemyAttackTarget()
            if self.moveTarget~=self and LevelManager:getEntityAggro()==true then 
                self:changeState('moveToTarget') 
            end
            return
        end

        --if idling for too long, wander around
        self.idleTime=self.idleTime+dt 
        if self.idleTime>self.maxIdleTime then 
            self.idleTime=rnd()
            self:setLocationMoveTarget()
            self:changeState('moveToLocation') 
            return 
        end
    end,

    idleRanged=function(self) 
        self:updateAnimation()
        self:updatePosition()
        self.status:update(self)

        --if target is a living skeleton, move toward target to attack if attack
        --is off cooldown, otherwise relocate to a different position.
        if self.moveTarget~=self and self.moveTarget.state~='dead' then 
            if self.canAttack.flag 
            and LevelManager:getEntityAggro()==true
            and getRectDistance(self,self.moveTarget)>self.attack.range 
            then 
                self:changeState('moveToTarget') 
            else 
                self:setLocationMoveTarget()
                self:changeState('moveToLocation') 
            end
            return         
        end
        
        --find and target the nearest skeleton/player
        if self.canQueryAttackTargets.flag then
            self.canQueryAttackTargets.setOnCooldown()
            self.moveTarget=self:getNearestEnemyAttackTarget()
            if self.moveTarget~=self and LevelManager:getEntityAggro()==true then 
                self:changeState('moveToTarget') 
            end
        end

        --if idling for too long, wander around
        self.idleTime=self.idleTime+dt 
        if self.idleTime>self.maxIdleTime then 
            self.idleTime=rnd()
            self:setLocationMoveTarget()
            self:changeState('moveToLocation') 
            return 
        end
    end,

    idleStationary=function(self)
        self:updateAnimation()
        self:updatePosition()
        self.status:update(self)

        if self.canQueryAttackTargets.flag then 
            self.canQueryAttackTargets.setOnCooldown()
            self.target=self:getNearestEnemyAttackTarget()
            if self.target~=self 
            and LevelManager:getEntityAggro()==true
            and getRectDistance(self,self.target)<self.attack.range 
            then self:changeState('attack') end 
        end
    end,

    moveToTarget=function(self) 
        self:updateAnimation()
        self:updatePosition()
        self.status:update(self)
        
        --if target has died, clear moveTarget, return to idle
        if self.moveTarget.state=='dead' or self.moveTarget==self then
            self:clearMoveTarget()
            self:changeState('idle')
            return 
        end 
    
        --continue looking for closer targets
        if self.canQueryAttackTargets.flag then 
            self.canQueryAttackTargets.setOnCooldown()
            self.moveTarget=self:getNearestEnemyAttackTarget()
            if self.moveTarget==self then self:changeState('idle') return end
        end
        
        --if target is within attack range, attack. Otherwise move toward it
        if getRectDistance(self,self.moveTarget)<self.attack.range then 
            if self.canAttack.flag and LevelManager:getEntityAggro()==true then 
                self:changeState('attack') 
                return 
            else self:changeState('idle') return 
            end  
        end

        self:move()
    end,

    moveToLocation=function(self)
        self:updateAnimation()
        self:updatePosition()
        self.status:update(self)

        --reached nearby location  
        if getDistance(self.moveTarget.center,self.center)<self.w then 
            self:clearMoveTarget()
            self:changeState('idle')
            return
        end

        --if moving for too long, pick another location (possibly stuck)
        self.idleTime=self.idleTime+dt 
        if self.idleTime>self.maxIdleTime then 
            self.idleTime=rnd()
            self:setLocationMoveTarget()
            return 
        end

        --continue checking for targets if attack is off cooldown
        if self.canQueryAttackTargets.flag and self.canAttack.flag then
            self.canQueryAttackTargets.setOnCooldown()
            local nearbyTarget=self:getNearestEnemyAttackTarget()
            if nearbyTarget~=self and LevelManager:getEntityAggro()==true then 
                self.moveTarget=nearbyTarget 
                self:changeState('moveToTarget')
                return
            end 
        end

        self:move()
    end,
    
    lunge=function(self) --lunges toward target, deals damage and bounces away
        self.status:update(self)
        local onLoop=self:updateAnimation()
        if onLoop then
            self.targetsAlreadyAttacked={}
            self:changeState('idle')
        end

        local collisions=self:updatePosition()    
        if self:onDamagingFrames() then 
            if self.canAttack.flag then 
                self.canAttack.setOnCooldown()
                local fx=cos(self.angle)*self.attack.lungeForce
                local fy=sin(self.angle)*self.attack.lungeForce
                self.vx=self.vx+fx
                self.vy=self.vy+fy    
                Audio:playSfx(self.sfx.lunge)    
            end 
    
            --handle collisions
            for i=1,#collisions do
                local other=collisions[i].other --other collider
                
                if other.collisionClass=='ally' then 
                    --Only hurt targets once per attack
                    for i=1,#self.targetsAlreadyAttacked do 
                        if other==self.targetsAlreadyAttacked[i] then return end
                    end

                    local touch=collisions[i].touch --point of collision     
                    local magnitude=getMagnitude(self.vx,self.vy)         
                    local angle=getAngle(touch,self)

                    --bounce self away from target, losing some momentum
                    self.vx=cos(angle)*magnitude*self.restitution
                    self.vy=sin(angle)*magnitude*self.restitution

                    --damage target, add to targetsAlreadyAttacked
                    other:takeDamage({
                        damage=self.attack.damage,
                        knockback=self.attack.knockback,
                        angle=getAngle(self.center,other.center),
                    })
                    table.insert(self.targetsAlreadyAttacked,other)
                end
            end  
        end
    end,
    
    roll=function(self) --lunges toward target, deals damage and rolls through
        self.status:update(self)
        local onLoop=self:updateAnimation()
        if onLoop then
            self.targetsAlreadyAttacked={}
            self:changeState('idle')
        end

        local collisions=self:updatePosition()    
        if self:onDamagingFrames() then 
            if self.canAttack.flag then 
                self.canAttack.setOnCooldown()
                local fx=cos(self.angle)*self.attack.lungeForce
                local fy=sin(self.angle)*self.attack.lungeForce
                self.vx=self.vx+fx
                self.vy=self.vy+fy
                Audio:playSfx(self.sfx.lunge)   
            end 
    
            --handle collisions
            for i=1,#collisions do
                local other=collisions[i].other --other collider
                
                if other.collisionClass=='ally' then 
                    --Only hurt targets once per attack
                    for i=1,#self.targetsAlreadyAttacked do 
                        if other==self.targetsAlreadyAttacked[i] then return end
                    end

                    --damage target, add to targetsAlreadyAttacked
                    other:takeDamage({
                        damage=self.attack.damage,
                        knockback=self.attack.knockback,
                        angle=getAngle(self.center,other.center),
                    })
                    table.insert(self.targetsAlreadyAttacked,other)
                end
            end
        end
    end,

    spawnMinion=function(self)
        self:updatePosition()
        self.status:update(self)
        local onLoop=self:updateAnimation()
        if onLoop then self:changeState('idle') end 

        if LevelManager:maxEnemiesReached() then --don't exceed entity limit
            self.canAttack.setOnCooldown()
            self.animations.current:gotoFrame(1)
            self:changeState('idle')
        end
        
        if self.canAttack.flag and self:onSpawnMinionFrame() then
            self.canAttack.setOnCooldown()
            self:spawnMinions()
        end        
    end,

    spawnSpiders=function(self)
        self.status:update(self)
        self:updatePosition()
        self:updateAnimation()
        if self.attackTime==nil then 
            self.attackTime=dt 
        else 
            self.attackTime=self.attackTime+dt 
            if self.attackTime>2 then 
                self:spawnMinions()
                self:die()
            end
        end    
    end,
    
    lungeAndTeleport=function(self) --normal lunge, then roll for a chance to teleport
        self.status:update(self)
        local onLoop=self:updateAnimation()
        if onLoop then
            self.targetsAlreadyAttacked={}
            local nextState=rnd(2)>1 and 'teleport' or 'idle' --50% chance    
            if nextState=='teleport' then Audio:playSfx(self.sfx.teleport) end         
            self:changeState(nextState)
        end

        local collisions=self:updatePosition()    
        if self:onDamagingFrames() then 
            if self.canAttack.flag then 
                self.canAttack.setOnCooldown()
                local fx=cos(self.angle)*self.attack.lungeForce
                local fy=sin(self.angle)*self.attack.lungeForce
                self.vx=self.vx+fx
                self.vy=self.vy+fy     
                Audio:playSfx(self.sfx.lunge)   
            end 
    
            --handle collisions
            for i=1,#collisions do
                local other=collisions[i].other --other collider
                
                if other.collisionClass=='ally' then 
                    --Only hurt targets once per attack
                    for i=1,#self.targetsAlreadyAttacked do 
                        if other==self.targetsAlreadyAttacked[i] then return end
                    end

                    local touch=collisions[i].touch --point of collision     
                    local magnitude=getMagnitude(self.vx,self.vy)         
                    local angle=getAngle(touch,self)

                    --bounce self away from target, losing some momentum
                    self.vx=cos(angle)*magnitude*self.restitution
                    self.vy=sin(angle)*magnitude*self.restitution

                    --damage target, add to targetsAlreadyAttacked
                    other:takeDamage({
                        damage=self.attack.damage,
                        knockback=self.attack.knockback,
                        angle=getAngle(self.center,other.center),
                    })
                    table.insert(self.targetsAlreadyAttacked,other)
                end
            end  
        end
    end, 

    shootAndTeleport=function(self)
        self:updatePosition()
        self.status:update(self)
        local onLoop=self:updateAnimation()
        if onLoop then 
            local nextState=rnd(4)>1 and 'teleport' or 'idle' --75% chance
            if nextState=='teleport' then Audio:playSfx(self.sfx.teleport) end   
            self:changeState(nextState)
        end 

        if self.canAttack.flag and self:onFiringFrame() then
            self.canAttack.setOnCooldown()
            local projectile={
                name=rndElement(self.attack.projectile.name),
                x=self.center.x+self.attack.projectile.xOffset*self.scaleX,
                y=self.center.y,yOffset=self.attack.projectile.yOffset
            }
            local count=self.attack.projectile.count or 1
            local spread=self.attack.projectile.spread or 0
            for i=1,count do
                local angleToTarget=getAngle(projectile,self.moveTarget.center)
                if spread~=0 then 
                    angleToTarget=angleToTarget+(rnd()*spread-spread*0.5)
                end
                Projectiles:new({
                    x=projectile.x,y=projectile.y,name=projectile.name,
                    damage=self.attack.damage,knockback=self.attack.knockback,
                    angle=angleToTarget,yOffset=projectile.yOffset
                })
            end
        end
    end,

    teleport=function(self)
        local onLoop=self:updateAnimation()
        self:updatePosition()
        self.status:update(self)

        if onLoop then 
            local distance=rnd(20,400)
            local angle=rnd()*2*pi 

            local goalX=self.x+cos(angle)*distance 
            local goalY=self.y+sin(angle)*distance
            local realX,realY=World:move(self,goalX,goalY,self.collisionFilter)
            self.x,self.y=realX,realY 
            local c=getCenter(self)
            self.center.x,self.center.y=c.x,c.y

            self:changeState('spawn') 
            Audio:playSfx(self.sfx.spawn)
        end
    end,

    obsidianGolemChooseAttack=function(self)
        self:updatePosition()
        self.status:update(self)

        if self.nextAttack==nil then 
            self.nextAttack='groundslam' --start with slam
        else 
            if LevelManager:maxEnemiesReached() then 
                self.nextAttack='fireball'
            else 
                self.nextAttack=rnd(3)==3 and 'groundslam' or 'fireball'         
            end
        end

        self:changeState(self.nextAttack)
    end,

    obsidianGolemGroundslam=function(self)
        self:updatePosition()
        self.status:update(self)
        local onLoop=self:updateAnimation()
        if onLoop then 
            self.targetsAlreadyAttacked={}
            self:changeState('idle') 
        end 

        if self:onDamagingFrames() and self.canAttack.flag then 
            self.canAttack.setOnCooldown()
            Camera:shake({magnitude=15})
            local slam=self.attack.slam 
            local w=slam.w 
            local h=slam.h
            local x=self.center.x-w*0.5
            local y=self.center.y-h*0.5
            local filter=World.queryFilters.ally
            local targets=World:queryRect(x,y,w,h,filter)
            for i=1,#targets do 
                local target=targets[i]
                target:takeDamage({
                    damage=slam.damage,
                    knockback=slam.knockback,
                    angle=getAngle(self.center,target.center),
                })
                table.insert(self.targetsAlreadyAttacked,target)
            end
            self:spawnMinions()
            Audio:playSfx('obsidianGolemSlam')
        end
    end,

    --Upon spawning, always summon demons.
    --Starts with a 1/10 chance to perform a special attack (summonDemons or clone).
    --Chance increases the more basic attacks are performed between specials.
    --Specials will never roll when level's enemy limit is reached.
    witchChooseAttack=function(self)
        self:updatePosition()
        self.status:update(self)

        local nextAttack=rndElement({'projectile','chainLightning'}) --default

        if self.basicAttackCounter==nil then --start fight with demons
            self.basicAttackCounter=0
            nextAttack='summonDemons'
        else             
            if not LevelManager:maxEnemiesReached() then 
                if rnd(10-self.basicAttackCounter)==1 then 
                    nextAttack=rndElement({'summonDemons','clone'})
                end
            end
        end

        --Keep track of basic attacks. Limit to 9 as it will guarentee a 
        --special attack on next chance (unless level's enemy limit is reached)
        if nextAttack=='projectile' or nextAttack=='chainLightning' then 
            self.basicAttackCounter=min(self.basicAttackCounter+1,9)
        else 
            self.basicAttackCounter=0
        end

        self:changeState(nextAttack)
    end,

    --1/5 chance to summon demons unless level's enemy limit is reached
    witchCloneChooseAttack=function(self)
        local nextAttack=rndElement({'projectile','chainLightning'})
        if not LevelManager:maxEnemiesReached() then 
            if rnd(5)==5 then nextAttack='summonDemons' end 
        end
        self:changeState(nextAttack)
    end,

    witchProjectile=function(self)        
        self:updatePosition()
        self.status:update(self)
        local onLoop=self:updateAnimation()
        if onLoop then self:changeState(rndElement({'teleport','idle'})) end 

        if self.canAttack.flag and self:onFiringFrame() then
            self.canAttack.setOnCooldown()
            --select a projectile to fire
            local selection=rndElement({'fireball','icicle'})
            local projectile={
                name=self.attack.projectile[selection].name,
                x=self.center.x+self.attack.projectile[selection].xOffset*self.scaleX,
                y=self.center.y,yOffset=self.attack.projectile[selection].yOffset
            }
            local count=self.attack.projectile[selection].count or 1
            local spread=self.attack.projectile[selection].spread or 0
            for i=1,count do
                local angleToTarget=getAngle(projectile,self.moveTarget.center)
                if spread~=0 then 
                    angleToTarget=angleToTarget+(rnd()*spread-spread*0.5)
                end
                Projectiles:new({
                    x=projectile.x,y=projectile.y,name=projectile.name,
                    damage=self.attack.projectile[selection].damage,
                    knockback=self.attack.projectile[selection].knockback,
                    angle=angleToTarget,yOffset=projectile.yOffset
                })
            end
        end
    end,

    witchChainLightning=function(self)
        self:updatePosition()
        self.status:update(self)
        local onLoop=self:updateAnimation()
        if onLoop then self:changeState(rndElement({'teleport','idle'})) end 

        if self.canAttack.flag and self:onFiringFrame() then
            self.canAttack.setOnCooldown()
            local targets={self.moveTarget}
            local range=self.attack.range 
            local queryFilter=World.queryFilters.ally 
            for i=1,9 do --chains up to 9 additional targets
                prevTarget=targets[#targets]
                --query all enemies surrounding the last target
                local nearbyEnemies=World:queryRect(
                    prevTarget.center.x-range,
                    prevTarget.center.y-range,
                    range*2,range*2,queryFilter  
                )
                --filter out any duplicates from nearbyEnemies
                for j,enemy in ipairs(nearbyEnemies) do 
                    for k=1,#targets do 
                        if enemy==targets[k] then 
                            table.remove(nearbyEnemies,j) 
                        end 
                    end
                end
                table.insert(targets,rndElement(nearbyEnemies))
            end
            SpecialAttacks:chainLightning(self,targets,'purple','pink')
        end
    end,

    witchSummonDemons=function(self)
        self:updatePosition()
        self.status:update(self)
        local onLoop=self:updateAnimation()
        if onLoop then self:changeState(rndElement({'teleport','idle'})) end 

        if self.canAttack.flag and self:onFiringFrame() then 
            self.canAttack.setOnCooldown()
            local demonsToSpawn={}
            local demonDef=self.attack.demons
            for i=1,#demonDef do
                local def=demonDef[i]
                demonsToSpawn[def.name]=def.count
            end
            LevelManager.gridClass:generateEnemies(
                demonsToSpawn,Entities,LevelManager.currentLevel.grid 
            )
            local messages={
                "Go forth, my minions!",
                "Attack, my minions!",
                "Minions, I summon thee!",
            }
            self.dialog:say(rndElement(messages))
        end        
    end,

    witchClone=function(self)
        self:updatePosition()
        self.status:update(self)
        local onLoop=self:updateAnimation()
        if onLoop then --summon clone
            local clone=Entities:new(self.attack.clone.name,self.x,self.y)
            clone.dialog=UI:newDialog(clone,45,'dialogWitch')
            self:changeState(rndElement({'teleport','idle'}))
            local messages={
                "AAAAAHAHAHAHAHA!",
                "Seeing double?",
                "Which witch is which?",
            }
            self.dialog:say(rndElement(messages))
            clone.dialog:say(rndElement(messages))
        end
    end,

    deadBoss=function(self) 
        --if there's a death animation, wait for it to finish
        if self.animations.dead then
            self.animSpeed=self.animSpeedMax
            local onLoop=self:updateAnimation()
            if not onLoop then return end 
        end

        --destroy enemy, emit particle explosion, shake camera
        --bosses' death shake bypasses camera's overshake prevention
        self.particles:emit(self.center.x,self.center.y)
        LevelManager:decreaseEntityCount(self.collisionClass,self.name)
        if self.deathShake then 
            local shake=self.deathShake 
            Camera:shakeBypass({
                magnitude=shake.magnitude,
                period=shake.period,
                damping=shake.damping,
                stopThreshold=shake.stopThreshold,
            })
        end
        if self.dialog then self.dialog:destroy() end
        Audio:playSfx(self.sfx.death)
        return false
    end,
}

behaviors.states.cutscene={
    idle=function(self)
        self:updateAnimation()
        self:updatePosition()
    end,

    despawn=function(self)
        local onLoop=self:updateAnimation()
        self:updatePosition()
        if onLoop then 
            LevelManager:decreaseEntityCount(self.collisionClass,self.name)
            return false 
        end
    end,
}

behaviors.AI={ --AI--------------------------------------------------------------------------------
    ['skeletonWarrior']={
        spawn=behaviors.states.common.spawn,
        idle=behaviors.states.ally.idleMelee,
        moveToPlayer=behaviors.states.ally.moveToPlayer,
        moveToTarget=behaviors.states.ally.moveToTarget,
        attack=behaviors.states.ally.lunge,
        dead=behaviors.states.common.dead,
    },
    ['skeletonArcher']={
        spawn=behaviors.states.common.spawn,
        idle=behaviors.states.ally.idleRanged,
        moveToPlayer=behaviors.states.ally.moveToPlayer,
        moveToTarget=behaviors.states.ally.moveToTarget,
        attack=behaviors.states.common.shoot,
        dead=behaviors.states.common.dead,
    },
    ['skeletonMageElectric']={ --clone of archer, but can't share reference
        spawn=behaviors.states.common.spawn,
        idle=behaviors.states.ally.idleRanged,
        moveToPlayer=behaviors.states.ally.moveToPlayer,
        moveToTarget=behaviors.states.ally.moveToTarget,
        attack=behaviors.states.common.shoot,
        dead=behaviors.states.common.dead,
    },
    ['slime']={ --standard melee, has spawn animation
        spawn=behaviors.states.common.spawn,
        idle=behaviors.states.enemy.idleMelee,
        moveToTarget=behaviors.states.enemy.moveToTarget,
        moveToLocation=behaviors.states.enemy.moveToLocation,
        attack=behaviors.states.enemy.lunge,
        dead=behaviors.states.common.dead,
    },
    ['possessedArcher']={ --standard ranged
        spawn=behaviors.states.common.spawn,
        idle=behaviors.states.enemy.idleRanged,
        moveToTarget=behaviors.states.enemy.moveToTarget,
        moveToLocation=behaviors.states.enemy.moveToLocation,
        attack=behaviors.states.common.shoot,
        dead=behaviors.states.common.dead,
    },
    ['slimeMatron']={ --'facing' moving summoner
        spawn=behaviors.states.common.spawn,
        idle=behaviors.states.enemy.idleRanged,
        moveToTarget=behaviors.states.enemy.moveToTarget,
        moveToLocation=behaviors.states.enemy.moveToLocation,
        attack=behaviors.states.enemy.spawnMinion,
        dead=behaviors.states.common.dead,
    },
    ['tombstone']={ --'random' idle summoner
        spawn=behaviors.states.common.spawn,
        idle=behaviors.states.enemy.idleStationary,
        attack=behaviors.states.enemy.spawnMinion,
        dead=behaviors.states.common.dead,
    },
    ['spiderEgg']={ --idle summoner, dies upon spawning minions
        spawn=behaviors.states.common.spawn,
        idle=behaviors.states.enemy.idleStationary,
        attack=behaviors.states.enemy.spawnSpiders,
        dead=behaviors.states.common.dead,
    },
    ['golem']={ --'roll through' melee
        spawn=behaviors.states.common.spawn,
        idle=behaviors.states.enemy.idleMelee,
        moveToTarget=behaviors.states.enemy.moveToTarget,
        moveToLocation=behaviors.states.enemy.moveToLocation,
        attack=behaviors.states.enemy.roll,
        dead=behaviors.states.common.dead,
    },
    ['ghost']={ --standard melee, then chance to teleport around
        spawn=behaviors.states.common.spawn,
        idle=behaviors.states.enemy.idleMelee,
        moveToTarget=behaviors.states.enemy.moveToTarget,
        moveToLocation=behaviors.states.enemy.moveToLocation,
        attack=behaviors.states.enemy.lungeAndTeleport,
        teleport=behaviors.states.enemy.teleport,
        dead=behaviors.states.common.dead,
    },
    ['poltergeist']={ --standard ranged, then chance to teleport around
        spawn=behaviors.states.common.spawn,
        idle=behaviors.states.enemy.idleRanged,
        moveToTarget=behaviors.states.enemy.moveToTarget,
        moveToLocation=behaviors.states.enemy.moveToLocation,
        attack=behaviors.states.enemy.shootAndTeleport,
        teleport=behaviors.states.enemy.teleport,
        dead=behaviors.states.common.dead,
    },
    ['giantTombstone']={        
        spawn=behaviors.states.enemy.spawnGiantTombstone,
        idle=behaviors.states.enemy.idleStationary,
        attack=behaviors.states.enemy.spawnMinion,
        dead=behaviors.states.enemy.deadBoss,
    },
    ['obsidianGolem']={
        spawn=behaviors.states.enemy.spawnObsidianGolem,
        idle=behaviors.states.enemy.idleRanged,
        moveToTarget=behaviors.states.enemy.moveToTarget,
        moveToLocation=behaviors.states.enemy.moveToLocation,
        attack=behaviors.states.enemy.obsidianGolemChooseAttack,
        fireball=behaviors.states.common.shoot,
        groundslam=behaviors.states.enemy.obsidianGolemGroundslam,
        dead=behaviors.states.enemy.deadBoss,
    },
    ['witch']={
        spawn=behaviors.states.common.spawn,
        idle=behaviors.states.enemy.idleRanged,
        moveToTarget=behaviors.states.enemy.moveToTarget,
        moveToLocation=behaviors.states.enemy.moveToLocation,
        attack=behaviors.states.enemy.witchChooseAttack,
        projectile=behaviors.states.enemy.witchProjectile,
        chainLightning=behaviors.states.enemy.witchChainLightning,
        summonDemons=behaviors.states.enemy.witchSummonDemons,
        clone=behaviors.states.enemy.witchClone,
        teleport=behaviors.states.enemy.teleport,
        dead=behaviors.states.enemy.deadBoss,
    },
    ['witchClone']={
        spawn=behaviors.states.common.spawn,
        idle=behaviors.states.enemy.idleRanged,
        moveToTarget=behaviors.states.enemy.moveToTarget,
        moveToLocation=behaviors.states.enemy.moveToLocation,
        attack=behaviors.states.enemy.witchCloneChooseAttack,
        projectile=behaviors.states.enemy.witchProjectile,
        chainLightning=behaviors.states.enemy.witchChainLightning,
        summonDemons=behaviors.states.enemy.witchSummonDemons,
        teleport=behaviors.states.enemy.teleport,
        dead=behaviors.states.enemy.deadBoss,
    },
}
--shared AI
behaviors.AI['skeletonMageFire']=behaviors.AI.skeletonArcher
behaviors.AI['skeletonMageIce']=behaviors.AI.skeletonArcher
behaviors.AI['pumpkin']=behaviors.AI.slime
behaviors.AI['spider']=behaviors.AI.slime
behaviors.AI['bat']=behaviors.AI.slime
behaviors.AI['zombie']=behaviors.AI.slime
behaviors.AI['possessedKnight']=behaviors.AI.golem
behaviors.AI['undeadMiner']=behaviors.AI.possessedArcher
behaviors.AI['ent']=behaviors.AI.possessedArcher
behaviors.AI['headlessHorseman']=behaviors.AI.possessedArcher
behaviors.AI['vampire']=behaviors.AI.slimeMatron
behaviors.AI['imp']=behaviors.AI.slime 
behaviors.AI['gnasherDemon']=behaviors.AI.slime
behaviors.AI['frankenstein']=behaviors.AI.possessedArcher
behaviors.AI['werebear']=behaviors.AI.golem
behaviors.AI['werewolf']=behaviors.AI.slime
behaviors.AI['floatingEyeball']=behaviors.AI.possessedArcher
behaviors.AI['pyreFiend']=behaviors.AI.possessedArcher
behaviors.AI['beholder']=behaviors.AI.possessedArcher

--setting cutscene behaviors for cutscene actors
behaviors.AI['witch'].idleCutscene=behaviors.states.cutscene.idle
behaviors.AI['witch'].despawn=behaviors.states.cutscene.despawn
behaviors.AI['imp'].despawn=behaviors.states.cutscene.despawn
behaviors.AI['gnasherDemon'].despawn=behaviors.states.cutscene.despawn
behaviors.AI['pyreFiend'].despawn=behaviors.states.cutscene.despawn
behaviors.AI['beholder'].despawn=behaviors.states.cutscene.despawn

return behaviors 