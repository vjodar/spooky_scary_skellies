local behaviors={}

behaviors.methods={} --Methods---------------------------------------------------------------------
behaviors.methods.common={
    update=function(self) return self.AI[self.state](self) end,
    draw=function(self)
        self.shadow:draw(self.x,self.y)
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
                other.vx=other.vx+cos(angle)*self.moveSpeed*dt
                other.vy=other.vy+sin(angle)*self.moveSpeed*dt
            end
        end

        return cols --return the collisions this move produced
    end,

    updateAnimation=function(self)
        return self.animations.current:update(dt*self.animSpeed.current)
    end,

    takeDamage=function(self,source)
        local damage=source.attackDamage or 0 
        local knockback=source.knockback or 0
        local kbAngle=getAngle(source.center,self.center)
        
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
}

behaviors.methods.ally={

    --if skeleton is too far from player, return to near the player
    remainNearPlayer=function(self)
        if abs(Player.center.x-self.center.x)>Player.allyReturnThreshold.x
        or abs(Player.center.y-self.center.y)>Player.allyReturnThreshold.y
        then
            --choose an offset from the player's center point
            local xRange=Player.allyReturnThreshold.x*0.4
            local yRange=Player.allyReturnThreshold.y*0.4
            self.nearPlayerLocation={x=rnd(-xRange,yRange),y=rnd(-yRange,yRange)}

            --set moveTarget to Player position offset by nearPlayerLocation 
            --needs to be a table with a center field to work with self:move()
            self.moveTarget={center={
                x=Player.center.x+self.nearPlayerLocation.x,
                y=Player.center.y+self.nearPlayerLocation.y,
            }}
            self:changeState('moveToPlayer')
            return false 
        end
        return true 
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
            filter=World.queryFilters.enemy
        }    
        local targets=World:queryRect(
            queryData.x,queryData.y,queryData.w,queryData.h,queryData.filter
        )
        return targets
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
    idle=function(self)
        self:updateAnimation()
        self:updatePosition()
        if self:remainNearPlayer()==false then return end

        --if target is a living enemy and skeleton can attack or is out of 
        --range, move toward the target in order to attack.
        if self.moveTarget~=self and self.moveTarget.state~='dead' then 
            if self.canAttack.flag 
            or getRectDistance(self,self.moveTarget)>self.attackRange 
            then self:changeState('moveToTarget') end 
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
        if getDistance(self.moveTarget.center,self.center)<20 then 
            self:clearMoveTarget()
            self:changeState('idle')
            return
        end

        --if an enemy is nearby, move to attack it only if skeleton
        --is within 70% of return threshold
        if self.canQueryAttackTargets.flag then
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
    idle=function(self) 
        self:updateAnimation()
        self:updatePosition()

        --if target is a living skeleton and enemy can attack or is out of 
        --range, move toward the target in order to attack.
        if self.moveTarget~=self and self.moveTarget.state~='dead' then 
            if self.canAttack.flag 
            or getRectDistance(self,self.moveTarget)>self.attackRange 
            then self:changeState('moveToTarget') end 
            return --return to wait until attack is ready or target dies          
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
}

behaviors.AI={ --AI--------------------------------------------------------------------------------
    ['skeletonWarrior']={
        raise=behaviors.states.common.raise,
        idle=behaviors.states.ally.idle,
        moveToPlayer=behaviors.states.ally.moveToPlayer,
        moveToTarget=behaviors.states.ally.moveToTarget,
        attack=behaviors.states.ally.lunge,
        dead=behaviors.states.common.dead,
    },
    ['skeletonArcher']={
        raise=behaviors.states.common.raise,
        idle=behaviors.states.ally.idle,
        moveToPlayer=behaviors.states.ally.moveToPlayer,
        moveToTarget=behaviors.states.ally.moveToTarget,
        attack=behaviors.states.common.shoot,
        dead=behaviors.states.common.dead,
    },
    ['skeletonMageFire']={
        raise=behaviors.states.common.raise,
        idle=behaviors.states.ally.idle,
        moveToPlayer=behaviors.states.ally.moveToPlayer,
        moveToTarget=behaviors.states.ally.moveToTarget,
        attack=behaviors.states.common.shoot,
        dead=behaviors.states.common.dead,
    },
    ['skeletonMageIce']={
        raise=behaviors.states.common.raise,
        idle=behaviors.states.ally.idle,
        moveToPlayer=behaviors.states.ally.moveToPlayer,
        moveToTarget=behaviors.states.ally.moveToTarget,
        attack=behaviors.states.common.shoot,
        dead=behaviors.states.common.dead,
    },
    ['skeletonMageElectric']={
        raise=behaviors.states.common.raise,
        idle=behaviors.states.ally.idle,
        moveToPlayer=behaviors.states.ally.moveToPlayer,
        moveToTarget=behaviors.states.ally.moveToTarget,
        attack=behaviors.states.common.shoot,
        dead=behaviors.states.common.dead,
    },
    ['slime']={
        idle=behaviors.states.enemy.idle,
        moveToTarget=behaviors.states.enemy.moveToTarget,
        attack=behaviors.states.enemy.lunge,
        dead=behaviors.states.common.dead,
    },
}

return behaviors 