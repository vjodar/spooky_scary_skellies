local behaviors={}

--Methods------------------------------------------------------------------------------------------

behaviors.methods={
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

    updatePosition=function(self)
        local goalX=self.x+self.vx*dt 
        local goalY=self.y+self.vy*dt 
        local realX,realY,cols=World:move(self,goalX,goalY,self.filter)
        self.x,self.y=realX,realY 
        self.center=getCenter(self)

        --update angle/direction, face target
        self.angle=getAngle(self.center,self.moveTarget.center)
        if self.moveTarget~=self then --only turn when moving
            self.scaleX=self.moveTarget.x>self.x and 1 or -1
        end
    
        --apply friction/linearDamping
        self.vx=self.vx-(self.vx*self.linearDamping*dt)
        self.vy=self.vy-(self.vy*self.linearDamping*dt)
    
        --stop moving when sufficiently slow
        if abs(self.vx)<self.stopThreshold*dt then self.vx=0 end
        if abs(self.vy)<self.stopThreshold*dt then self.vy=0 end        

        --push entities of same class out of the way (except player)
        for i=1,#cols do
            local other=cols[i].other 
            if other.collisionClass==self.collisionClass
            and other.name~='player' 
            then 
                local angle=getAngle(self.center,other.center)
                other.vx=other.vx+cos(angle)*self.moveSpeed*2*dt
                other.vy=other.vy+sin(angle)*self.moveSpeed*2*dt
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
    
    --Gets the closest attack target within LOS from the Player's nearbyEnemies table
    getNearestSkeletonAttackTarget=function(self)
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
    
    queryForEnemyAttackTargets=function(self)
        local queryData={
            x=self.x-(self.aggroRange.w*0.5),
            y=self.y-(self.aggroRange.h*0.5),
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

--States-------------------------------------------------------------------------------------------

behaviors.common={ --states common to both skeletons and enemies
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
            local angleToTarget=getAngle(projectile,target.center)
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

behaviors.skeleton={ --skeleton specific states
    idle=function(self)
        self:updateAnimation()
        self:updatePosition()
    
        --if skeleton is too far from player, move back to player
        if abs(Player.center.x-self.center.x)>Player.allyReturnThreshold.x 
        or abs(Player.center.y-self.center.y)>Player.allyReturnThreshold.y
        then
            self.moveTarget=Player
            self:changeState('moveToPlayer')
            return 
        end

        --if target is a living enemy and skeleton can attack or is out of 
        --range, move toward the target in order to attack.
        if self.moveTarget~=Player 
        and self.moveTarget~=self 
        and self.moveTarget.state~='dead'
        then 
            if self.canAttack.flag 
            or getDistance(self,self.moveTarget)>self.attackRange 
            then self:changeState('moveToTarget') end 
            return --return to wait until attack is ready or target dies          
        end
    
        --find and target the nearest enemy
        if self.canQueryAttackTargets.flag then 
            self.canQueryAttackTargets.setOnCooldown()
            self.moveTarget=self:getNearestSkeletonAttackTarget()
            if self.moveTarget~=self then 
                self:changeState('moveToTarget') 
                return 
            end
        end
    end,

    moveToTarget=function(self) 
        self:updateAnimation()
        self:updatePosition()

        --if skeleton is too far from player, move back to player
        if abs(Player.center.x-self.center.x)>Player.allyReturnThreshold.x 
        or abs(Player.center.y-self.center.y)>Player.allyReturnThreshold.y
        then
            self.moveTarget=Player
            self:changeState('moveToPlayer')
            return 
        end
    
        --if moveTarget has died or has been cleared, return to idle
        if self.moveTarget.state=='dead' or self.moveTarget==self then
            self:clearMoveTarget()
            self:changeState('idle')
            return 
        end 
    
        --continue looking for closer targets 
        if self.canQueryAttackTargets.flag then 
            self.canQueryAttackTargets.setOnCooldown()
            self.moveTarget=self:getNearestSkeletonAttackTarget()
            if self.moveTarget==self then self:changeState('idle') return end
        end
    
        if getDistance(self,self.moveTarget)<self.attackRange then             
            if self.canAttack.flag then
                self:changeState('attack')
                return 
            else 
                self:changeState('idle') 
                return  
            end
        end

        local vxIncrement=cos(self.angle)*self.moveSpeed*dt 
        local vyIncrement=sin(self.angle)*self.moveSpeed*dt 
        self.vx=self.vx+vxIncrement
        self.vy=self.vy+vyIncrement 
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
    
        --reached player       
        if abs(Player.center.x-self.center.x)<Player.allyReturnThreshold.x*0.5
        and abs(Player.center.y-self.center.y)<Player.allyReturnThreshold.y*0.5
        then
            self:clearMoveTarget()
            self:changeState('idle')
            return
        end

        local vxIncrement=cos(self.angle)*self.moveSpeed*dt 
        local vyIncrement=sin(self.angle)*self.moveSpeed*dt 
        self.vx=self.vx+vxIncrement
        self.vy=self.vy+vyIncrement
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

behaviors.enemy={ --enemy specific states
    idle=function(self) 
        self:updateAnimation()
        self:updatePosition()

        --if target is a living skeleton and enemy can attack or is out of 
        --range, move toward the target in order to attack.
        if self.moveTarget~=self and self.moveTarget.state~='dead' then 
            if self.canAttack.flag 
            or getDistance(self,self.moveTarget)>self.attackRange 
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
        if self.moveTarget.state=='dead' then
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
        if getDistance(self,self.moveTarget)<self.attackRange then 
            if self.canAttack.flag then 
                self:changeState('attack')
                return 
            else 
                self:changeState('idle')
                return
            end  
        end

        local vxIncrement=cos(self.angle)*self.moveSpeed*dt 
        local vyIncrement=sin(self.angle)*self.moveSpeed*dt 
        self.vx=self.vx+vxIncrement
        self.vy=self.vy+vyIncrement
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

--AI-----------------------------------------------------------------------------------------------

behaviors.AI={
    ['skeletonWarrior']={
        raise=behaviors.common.raise,
        idle=behaviors.skeleton.idle,
        moveToPlayer=behaviors.skeleton.moveToPlayer,
        moveToTarget=behaviors.skeleton.moveToTarget,
        attack=behaviors.skeleton.lunge,
        dead=behaviors.common.dead,
    },
    ['skeletonArcher']={
        raise=behaviors.common.raise,
        idle=behaviors.skeleton.idle,
        moveToPlayer=behaviors.skeleton.moveToPlayer,
        moveToTarget=behaviors.skeleton.moveToTarget,
        attack=behaviors.common.shoot,
        dead=behaviors.common.dead,
    },
    ['skeletonMageFire']={
        raise=behaviors.common.raise,
        idle=behaviors.skeleton.idle,
        moveToPlayer=behaviors.skeleton.moveToPlayer,
        moveToTarget=behaviors.skeleton.moveToTarget,
        attack=behaviors.common.shoot,
        dead=behaviors.common.dead,
    },
    ['skeletonMageIce']={
        raise=behaviors.common.raise,
        idle=behaviors.skeleton.idle,
        moveToPlayer=behaviors.skeleton.moveToPlayer,
        moveToTarget=behaviors.skeleton.moveToTarget,
        attack=behaviors.common.shoot,
        dead=behaviors.common.dead,
    },
    ['skeletonMageElectric']={
        raise=behaviors.common.raise,
        idle=behaviors.skeleton.idle,
        moveToPlayer=behaviors.skeleton.moveToPlayer,
        moveToTarget=behaviors.skeleton.moveToTarget,
        attack=behaviors.common.shoot,
        dead=behaviors.common.dead,
    },
    ['slime']={
        idle=behaviors.enemy.idle,
        moveToTarget=behaviors.enemy.moveToTarget,
        attack=behaviors.enemy.lunge,
        dead=behaviors.common.dead,
    },
}

return behaviors 