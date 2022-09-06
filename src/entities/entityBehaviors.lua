local behaviors={}

behaviors.methods={} --Methods---------------------------------------------------------------------
behaviors.methods.common={

    update=function(self) return self.AI[self.state](self) end,

    draw=function(self)
        self.shadow:draw(self.x,self.y)
        -- love.graphics.setColor(0.8,0.9,1,1) --light blue tint for freeze
        -- love.graphics.setColor(1,0.8,0.8,1) --red tint for burn
        self.animations.current:draw(
            self.spriteSheet,self.x+self.xOffset,self.y+self.yOffset,
            nil,self.scaleX,1,self.xOrigin,self.yOrigin
        )
    end,

    changeState=function(self,newState)
        self.state=newState 
        local associatedAnimation={
            raise='raise',
            idle='idle',
            attack='attack',
            moveToPlayer='move',
            moveToTarget='move',
            moveToLocation='move',
        }
        if self.animations[associatedAnimation[newState]] then 
            self.animations.current=self.animations[associatedAnimation[newState]]
        end
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
        local realX,realY,cols,len=World:move(self,goalX,goalY,self.filter)
        self.x,self.y=realX,realY 
        self.center=getCenter(self)

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

        return cols --return the collisions this move produced
    end,

    updateAnimation=function(self)
        return self.animations.current:update(dt*self.animSpeed.current)
    end,

    takeDamage=function(self,source)
        local damage=source.attackDamage or 0 
        local kbAngle=getAngle(source.center,self.center)
        local knockback=source.knockback or 0
        knockback=knockback-knockback*(self.kbResistance/100)
        
        self.health.current=max(self.health.current-damage,0)

        --Apply knockback force
        self.vx=self.vx+cos(kbAngle)*knockback
        self.vy=self.vy+sin(kbAngle)*knockback

        if self.health.current==0 then self:die() end
    end,

    dealDamage=function(self,target)
        if target.state=='dead' then return end
        target:takeDamage(self)
    end,

    die=function(self)
        World:remove(self) 
        self:changeState('dead')
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
        if #nearbyEnemies==0 then return self end --nothing nearby, reset moveTarget

        -- --filter out any targets blocked from LOS
        -- local LOSblockers={'solid'}
        -- for i=1, #nearbyEnemies do 
        --     if #World:queryLine(
        --         self.x,self.y,nearbyEnemies[i].x,
        --         nearbyEnemies[i].y,LOSblockers
        --     )>0 then 
        --         table.remove(nearbyEnemies,i)
        --     end
        -- end
        
        local closest=nil --find and return the closest target
        for i=1, #nearbyEnemies do 
            local dist=getDistance(self,nearbyEnemies[i])
            if closest==nil or closest.d>dist then 
                closest={t=nearbyEnemies[i],d=dist} 
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

    --projects in 8 directions around enemy to find possible locations free of
    --solid obstructions, then sets one of those to moveTarget
    setLocationMoveTarget=function(self)
        local distance=rnd(self.w,self.w*10)
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
        local filter=World.queryFilters.solid
        for i,l in ipairs(locations) do
            local _,len=World:project(
                self,self.x,self.y,self.w,self.h,l.center.x,l.center.y,filter
            )
            if len>0 then table.remove(locations,i) end
        end
        --of the remaining valid locations, choose a random one to set as moveTarget
        if #locations>0 then 
            self.moveTarget=locations[rnd(#locations)]
        else --if no valid locations remain, clear moveTarget (moveTaget=self)
            self:clearMoveTarget()
        end
    end,
    
    --Gets the closest attack target within LOS
    getNearestEnemyAttackTarget=function(self)
        local nearbyAttackTargets=self:queryForEnemyAttackTargets()
        if #nearbyAttackTargets==0 then return self end --nothing nearby, reset moveTarget

        -- --filter out any targets blocked from LOS
        -- local LOSblockers={'solid'}
        -- for i=1, #nearbyAttackTargets do 
        --     if #World:queryLine(
        --         self.x,self.y,nearbyAttackTargets[i].x,
        --         nearbyAttackTargets[i].y,LOSblockers
        --     )>0 then 
        --         table.remove(nearbyAttackTargets,i)
        --     end
        -- end
        
        local closest=nil --find and return the closest target
        for i=1, #nearbyAttackTargets do
            local dist=getDistance(self,nearbyAttackTargets[i])
            if closest==nil or closest.d>dist then 
                closest={t=nearbyAttackTargets[i],d=dist} 
            end
        end
        return closest.t
    end,
}

behaviors.states={} --States-----------------------------------------------------------------------
behaviors.states.common={
    raise=function(self)
        self:updatePosition()
        local onLoop=self:updateAnimation()
        if onLoop then self:changeState('idle') end
    end,
    
    dead=function(self) 
        return false
    end,

    shoot=function(self)
        self:updatePosition()
        local onLoop=self:updateAnimation()
        if onLoop then self:changeState('idle') end 

        if self.canAttack.flag and self:onFiringFrame() then
            self.canAttack.setOnCooldown()
            local projectile={
                name=self.projectile.name,
                x=self.center.x+self.projectile.xOffset*self.scaleX,
                y=self.center.y,yOffset=self.projectile.yOffset
            }
            local angleToTarget=getAngle(projectile,self.moveTarget.center)
            for i=1,self.projectilesPerShot do
                Projectiles:new({
                    x=projectile.x,y=projectile.y,name=projectile.name,
                    attackDamage=self.attackDamage,knockback=self.knockback,
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
        if self:remainNearPlayer()==false then return end

        --if target is a living enemy and skeleton can attack,
        --move toward the target in order to attack.
        if self.moveTarget~=self and self.moveTarget.state~='dead' then 
            if self.canAttack.flag then self:changeState('moveToTarget') end 
            return --return to wait until attack is ready or target dies          
        end
    
        --find and target the nearest enemy
        if self.canQueryAttackTargets.flag then 
            self.canQueryAttackTargets.setOnCooldown()
            self.moveTarget=self:getNearestAllyAttackTarget()
            if self.moveTarget~=self then 
                self:changeState('moveToTarget') 
                return 
            end
        end
    end,

    idleRanged=function(self)
        self:updateAnimation()
        self:updatePosition()
        if self:remainNearPlayer()==false then return end

        --if target is a living enemy, move toward target to attack if attack
        --is off cooldown, otherwise relocate to another position near player.
        if self.moveTarget~=self and self.moveTarget.state~='dead' then 
            if self.canAttack.flag then 
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
            if self.moveTarget~=self then 
                self:changeState('moveToTarget') 
                return 
            end
        end
    end,

    moveToTarget=function(self) 
        self:updateAnimation()
        self:updatePosition()
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
    
        if getRectDistance(self,self.moveTarget)<self.attackRange then             
            if self.canAttack.flag then self:changeState('attack') return 
            else self:changeState('idle') return
            end
        end

        self:move()
    end,

    moveToPlayer=function(self) 
        self:updateAnimation()
        self:updatePosition()
    
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

        --if an enemy is nearby, move to attack it only if skeleton
        --is within 70% of return threshold
        if self.canQueryAttackTargets.flag and self.canAttack.flag then
            self.canQueryAttackTargets.setOnCooldown()
            local nearbyTarget=self:getNearestAllyAttackTarget()
            if nearbyTarget~=self 
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
        local onLoop=self:updateAnimation()
        if onLoop then 
            self.targetsAlreadyAttacked={}
            self:changeState('idle') 
        end 

        local collisions=self:updatePosition()        
        if self:onDamagingFrames() then
            if self.canAttack.flag then 
                self.canAttack.setOnCooldown()
                local fx=cos(self.angle)*self.lungeForce
                local fy=sin(self.angle)*self.lungeForce
                self.vx=self.vx+fx
                self.vy=self.vy+fy  
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
                    self:dealDamage(other)
                    table.insert(self.targetsAlreadyAttacked,other)
                end
            end    
        end
    end,
}

behaviors.states.enemy={
    idleMelee=function(self) 
        self:updateAnimation()
        self:updatePosition()

        --if target is a living skeleton and enemy can attack,
        --move toward the target in order to attack.
        if self.moveTarget~=self and self.moveTarget.state~='dead' then 
            if self.canAttack.flag then self:changeState('moveToTarget') end 
            return --return to wait until attack is ready or target dies          
        end
        
        --find and target the nearest skeleton/player
        if self.canQueryAttackTargets.flag then
            self.canQueryAttackTargets.setOnCooldown()
            self.moveTarget=self:getNearestEnemyAttackTarget()
            if self.moveTarget~=self then self:changeState('moveToTarget') end
        end
    end,

    idleRanged=function(self) 
        self:updateAnimation()
        self:updatePosition()

        --if target is a living skeleton, move toward target to attack if attack
        --is off cooldown, otherwise relocate to a different position.
        if self.moveTarget~=self and self.moveTarget.state~='dead' then 
            if self.canAttack.flag 
            and getRectDistance(self,self.moveTarget)>self.attackRange 
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
            if self.moveTarget~=self then self:changeState('moveToTarget') end
        end
    end,

    moveToTarget=function(self) 
        self:updateAnimation()
        self:updatePosition()
        
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
        if getRectDistance(self,self.moveTarget)<self.attackRange then 
            if self.canAttack.flag then self:changeState('attack') return 
            else self:changeState('idle') return 
            end  
        end

        self:move()
    end,

    moveToLocation=function(self)
        self:updateAnimation()
        self:updatePosition()

        --reached nearby location  
        if getDistance(self.moveTarget.center,self.center)<self.w then 
            self:clearMoveTarget()
            self:changeState('idle')
            return
        end

        --continue checking for targets if attack is off cooldown
        if self.canQueryAttackTargets.flag and self.canAttack.flag then
            self.canQueryAttackTargets.setOnCooldown()
            local nearbyTarget=self:getNearestEnemyAttackTarget()
            if nearbyTarget~=self then 
                self.moveTarget=nearbyTarget 
                self:changeState('moveToTarget')
                return
            end 
        end

        self:move()
    end,
    
    lunge=function(self) 
        local onLoop=self:updateAnimation()
        if onLoop then
            self.targetsAlreadyAttacked={}
            self:changeState('idle')
        end

        local collisions=self:updatePosition()    
        if self:onDamagingFrames() then 
            if self.canAttack.flag then 
                self.canAttack.setOnCooldown()
                local fx=cos(self.angle)*self.lungeForce
                local fy=sin(self.angle)*self.lungeForce
                self.vx=self.vx+fx
                self.vy=self.vy+fy        
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
                    self:dealDamage(other)
                    table.insert(self.targetsAlreadyAttacked,other)
                end
            end  
        end
    end,

    spawnMinion=function(self)
        self:updatePosition()
        local onLoop=self:updateAnimation()
        if onLoop then self:changeState('idle') end 

        if self.canAttack.flag and self:onSpawnMinionFrame() then
            self.canAttack.setOnCooldown()
            Entities:new(self.minion.name,self.center.x,self.center.y)
        end        
    end,
}

behaviors.AI={ --AI--------------------------------------------------------------------------------
    ['skeletonWarrior']={
        raise=behaviors.states.common.raise,
        idle=behaviors.states.ally.idleMelee,
        moveToPlayer=behaviors.states.ally.moveToPlayer,
        moveToTarget=behaviors.states.ally.moveToTarget,
        attack=behaviors.states.ally.lunge,
        dead=behaviors.states.common.dead,
    },
    ['skeletonArcher']={
        raise=behaviors.states.common.raise,
        idle=behaviors.states.ally.idleRanged,
        moveToPlayer=behaviors.states.ally.moveToPlayer,
        moveToTarget=behaviors.states.ally.moveToTarget,
        attack=behaviors.states.common.shoot,
        dead=behaviors.states.common.dead,
    },
    ['slime']={
        raise=behaviors.states.common.raise,
        idle=behaviors.states.enemy.idleMelee,
        moveToTarget=behaviors.states.enemy.moveToTarget,
        attack=behaviors.states.enemy.lunge,
        dead=behaviors.states.common.dead,
    },
    ['pumpkin']={
        idle=behaviors.states.enemy.idleMelee,
        moveToTarget=behaviors.states.enemy.moveToTarget,
        attack=behaviors.states.enemy.lunge,
        dead=behaviors.states.common.dead,
    },
    ['possessedArcher']={
        idle=behaviors.states.enemy.idleRanged,
        moveToTarget=behaviors.states.enemy.moveToTarget,
        moveToLocation=behaviors.states.enemy.moveToLocation,
        attack=behaviors.states.common.shoot,
        dead=behaviors.states.common.dead,
    },
    ['slimeMatron']={
        idle=behaviors.states.enemy.idleRanged,
        moveToTarget=behaviors.states.enemy.moveToTarget,
        moveToLocation=behaviors.states.enemy.moveToLocation,
        attack=behaviors.states.enemy.spawnMinion,
        dead=behaviors.states.common.dead,
    }
}
--shared AI
behaviors.AI['skeletonMageFire']=behaviors.AI.skeletonArcher
behaviors.AI['skeletonMageIce']=behaviors.AI.skeletonArcher
behaviors.AI['skeletonMageElectric']=behaviors.AI.skeletonArcher
behaviors.AI['golem']=behaviors.AI.pumpkin
behaviors.AI['spider']=behaviors.AI.pumpkin
behaviors.AI['bat']=behaviors.AI.pumpkin
behaviors.AI['zombie']=behaviors.AI.slime
behaviors.AI['possessedKnight']=behaviors.AI.slime
behaviors.AI['undeadMiner']=behaviors.AI.possessedArcher
behaviors.AI['ent']=behaviors.AI.possessedArcher
behaviors.AI['headlessHorseman']=behaviors.AI.possessedArcher
behaviors.AI['vampire']=behaviors.AI.slimeMatron

return behaviors 