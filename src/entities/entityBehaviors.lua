local behaviors={}

behaviors.onLoops={
    changeToIdle=function(self)
        return function() self:changeState('idle')  end
    end,
    changeToRaise=function(self)
        return function()
            self:setPosition(Player.x,Player.y)
            self:changeState('raise')
        end
    end,
}

--Methods------------------------------------------------------------------------------------------

behaviors.methods={
    update=function(self) return self.AI[self.state](self) end,
    draw=function(self)
        self.shadow:draw(self.x,self.y)
        self.animations.current:draw(
            self.spriteSheet,self.x,self.y,
            nil,self.scaleX,1,self.xOffset,self.yOffset
        )
    end,

    changeState=function(self,newState)
        self.state=newState 
        local associatedAnimation={
            raise='raise',
            lower='lower',
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
        self.x,self.y=self:getPosition()
    end,

    updateAnimation=function(self)
        self.animations.current:update(dt*self.animSpeed.current)
    end,

    takeDamage=function(self,source)
        local hp=self.health.current 
        local damage=source.attackDamage or 0 
        local knockback=source.knockback or 0
        local angle=getAngle(source,self)
        
        hp=max(0,hp-damage)
        self.health.current=hp

        local ix,iy=cos(angle)*knockback,sin(angle)*knockback
        self:applyLinearImpulse(ix,iy)

        if self.health.current==0 then self:die() end
    end,

    dealDamage=function(self,target)
        if target.state=='dead' then return end
        target:takeDamage(self)
    end,

    die=function(self)
        self:destroy()
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

        --filter out any targets blocked from LOS
        local LOSblockers={'solid'}
        for i=1, #nearbyEnemies do 
            if #World:queryLine(
                self.x,self.y,nearbyEnemies[i].x,
                nearbyEnemies[i].y,LOSblockers
            )>0 then 
                table.remove(nearbyEnemies,i)
            end
        end
        
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
            colliderNames={'player','skeleton'}
        }    
        local targets=World:queryRectangleArea(
            queryData.x,queryData.y,queryData.w,queryData.h,queryData.colliderNames
        )
        return targets
    end,
    
    --Gets the closest attack target within LOS
    getNearestEnemyAttackTarget=function(self)
        local nearbyAttackTargets=self:queryForEnemyAttackTargets()
        if #nearbyAttackTargets==0 then return self end --nothing nearby, reset moveTarget

        --filter out any targets blocked from LOS
        local LOSblockers={'solid'}
        for i=1, #nearbyAttackTargets do 
            if #World:queryLine(
                self.x,self.y,nearbyAttackTargets[i].x,
                nearbyAttackTargets[i].y,LOSblockers
            )>0 then 
                table.remove(nearbyAttackTargets,i)
            end
        end
        
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
        self:updateAnimation()
        self.animations.raise.onLoop=self.onLoops.changeToIdle
    end,
    
    lower=function(self)
        self:updatePosition()
        self:updateAnimation()
        self.animations.lower.onLoop=self.onLoops.changeToRaise
    end,
    
    dead=function(self) 
        return false
    end,

    shoot=function(self)
        self:updatePosition()
        self:updateAnimation()
        self.animations.attack.onLoop=self.onLoops.changeToIdle

        if self.canAttack and self:onFiringFrame() then
            local projectile={
                name=self.projectile.name,
                x=self.x+self.projectile.xOffset*self.scaleX,
                y=self.y,yOffset=self.projectile.yOffset
            }
            local angleToTarget=getAngle(projectile,self.moveTarget)
            for i=1,self.projectilesPerShot do
                Projectiles:new({
                    x=projectile.x,y=projectile.y,name=projectile.name,
                    attackDamage=self.attackDamage,knockback=self.knockback,
                    angle=angleToTarget,yOffset=projectile.yOffset
                })
            end
            Timer:setOnCooldown(self,'canAttack',self.attackSpeed)
        end
    end,
}

behaviors.skeleton={ --skeleton specific states
    idle=function(self) 
        self:updatePosition()
        self:updateAnimation()
    
        --if skeleton is too far from player, move to player
        if getDistance(self,Player)>self.returnToPlayerThreshold then
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
            if self.canAttack 
            or getDistance(self,self.moveTarget)>self.attackRange 
            then self:changeState('moveToTarget') end 
            return --return to wait until attack is ready or target dies          
        end
    
        --find and target the nearest enemy
        if self.canQueryAttackTarget then 
            Timer:setOnCooldown(self,'canQueryAttackTarget',self.queryAttackTargetRate)
            self.moveTarget=self:getNearestSkeletonAttackTarget()
            if self.moveTarget~=self then 
                self:changeState('moveToTarget') 
                return 
            end
        end
    end,

    moveToTarget=function(self) 
        self:updatePosition()
        self:updateAnimation()

        --if Player is too far, move toward Player
        if getDistance(self,Player)>self.returnToPlayerThreshold then 
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
        if self.canQueryAttackTarget then 
            Timer:setOnCooldown(self,'canQueryAttackTarget',self.queryAttackTargetRate)
            self.moveTarget=self:getNearestSkeletonAttackTarget()
            if self.moveTarget==self then self:changeState('idle') return end
        end
    
        if self.moveTarget.x>self.x then self.scaleX=1 else self.scaleX=-1 end 
        self.angle=getAngle(self,self.moveTarget)
    
        if getDistance(self,self.moveTarget)<self.attackRange then             
            if self.canAttack then
                self:changeState('attack')
                return 
            else 
                self:changeState('idle') 
                return  
            end
        end

        local xVel=cos(self.angle)*self.moveSpeed
        local yVel=sin(self.angle)*self.moveSpeed
        self:applyForce(xVel,yVel)
    end,

    moveToPlayer=function(self) 
        self:updatePosition()
        self:updateAnimation()
    
        --if moveTarget has died or has been cleared, return to idle
        if self.moveTarget.state=='dead' or self.moveTarget==self then
            self:clearMoveTarget()
            self:changeState('idle')
            return 
        end 
    
        if self.moveTarget.x>self.x then self.scaleX=1 else self.scaleX=-1 end 
        self.angle=getAngle(self,self.moveTarget)
    
        --reached player
        if getDistance(self,self.moveTarget)<self.returnToPlayerThreshold*0.4 then 
            self:clearMoveTarget()
            self:changeState('idle')
            return
        end

        local xVel=cos(self.angle)*self.moveSpeed
        local yVel=sin(self.angle)*self.moveSpeed
        self:applyForce(xVel,yVel)
    end,
    
    lunge=function(self)
        self:updatePosition()
        self:updateAnimation()
        self.animations.current.onLoop=self.onLoops.changeToIdle
        
        if self:onDamagingFrames() then
            if self.canAttack then 
                local ix=cos(self.angle)*self.lungeSpeed
                local iy=sin(self.angle)*self.lungeSpeed
                self:applyLinearImpulse(ix,iy)
                Timer:setOnCooldown(self,'canAttack',self.attackSpeed)
            end
    
            if self:enter('enemy') then 
                local data=self:getEnterCollisionData('enemy')
                local enemy=data.collider
                if enemy~=nil then self:dealDamage(enemy) end
            end
        end
    end,
}

behaviors.enemy={ --enemy specific states
    idle=function(self) 
        self:updatePosition()
        self:updateAnimation()

        --if target is a living skeleton and enemy can attack or is out of 
        --range, move toward the target in order to attack.
        if self.moveTarget~=self and self.moveTarget.state~='dead' then 
            if self.canAttack 
            or getDistance(self,self.moveTarget)>self.attackRange 
            then self:changeState('moveToTarget') end 
            return --return to wait until attack is ready or target dies          
        end
        
        --find and target the nearest skeleton/player
        if self.canQueryAttackTarget then 
            Timer:setOnCooldown(self,'canQueryAttackTarget',self.queryAttackTargetRate)
            self.moveTarget=self:getNearestEnemyAttackTarget()
            if self.moveTarget~=self then self:changeState('moveToTarget') end
        end
    end,

    moveToTarget=function(self) 
        self:updatePosition()
        self:updateAnimation()
        
        --if target has died, clear moveTarget, return to idle
        if self.moveTarget.state=='dead' then
            self:clearMoveTarget()
            self:changeState('idle')
            return 
        end 
    
        --continue looking for closer targets
        if self.canQueryAttackTarget then 
            Timer:setOnCooldown(self,'canQueryAttackTarget',self.queryAttackTargetRate)
            self.moveTarget=self:getNearestEnemyAttackTarget()
            if self.moveTarget==self then self:changeState('idle') return end
        end
    
        if self.moveTarget.x>self.x then self.scaleX=1 else self.scaleX=-1 end --face target
        self.angle=getAngle(self,self.moveTarget)
        
        if getDistance(self,self.moveTarget)<self.attackRange then 
            if self.canAttack then 
                self:changeState('attack')
                return 
            else 
                self:changeState('idle')
                return
            end  
        end
        
        local xVel,yVel=cos(self.angle)*self.moveSpeed,sin(self.angle)*self.moveSpeed
        self:applyForce(xVel,yVel)
    end,
    
    lunge=function(self) 
        self:updatePosition()
        self:updateAnimation()
        self.animations.current.onLoop=self.onLoops.changeToIdle
    
        if self:onDamagingFrames() then 
            if self.canAttack then 
                local ix=cos(self.angle)*self.lungeSpeed
                local iy=sin(self.angle)*self.lungeSpeed
                self:applyLinearImpulse(ix,iy)  
                Timer:setOnCooldown(self,'canAttack',self.attackSpeed)
            end        
    
            if self:enter('skeleton') then 
                local data=self:getEnterCollisionData('skeleton')
                local skeleton=data.collider
                if skeleton~=nil then self:dealDamage(skeleton) end
            end
    
            if self:enter('player') then 
                --TODO: damage the player
                -- print("hit the player")
            end
        end
    end,
}

--AI-----------------------------------------------------------------------------------------------

behaviors.AI={
    ['skeletonWarrior']={
        raise=behaviors.common.raise,
        lower=behaviors.common.lower,
        idle=behaviors.skeleton.idle,
        moveToPlayer=behaviors.skeleton.moveToPlayer,
        moveToTarget=behaviors.skeleton.moveToTarget,
        attack=behaviors.skeleton.lunge,
        dead=behaviors.common.dead,
    },
    ['skeletonArcher']={
        raise=behaviors.common.raise,
        lower=behaviors.common.lower,
        idle=behaviors.skeleton.idle,
        moveToPlayer=behaviors.skeleton.moveToPlayer,
        moveToTarget=behaviors.skeleton.moveToTarget,
        attack=behaviors.common.shoot,
        dead=behaviors.common.dead,
    },
    ['skeletonMageFire']={
        raise=behaviors.common.raise,
        lower=behaviors.common.lower,
        idle=behaviors.skeleton.idle,
        moveToPlayer=behaviors.skeleton.moveToPlayer,
        moveToTarget=behaviors.skeleton.moveToTarget,
        attack=behaviors.common.shoot,
        dead=behaviors.common.dead,
    },
    ['skeletonMageIce']={
        raise=behaviors.common.raise,
        lower=behaviors.common.lower,
        idle=behaviors.skeleton.idle,
        moveToPlayer=behaviors.skeleton.moveToPlayer,
        moveToTarget=behaviors.skeleton.moveToTarget,
        attack=behaviors.common.shoot,
        dead=behaviors.common.dead,
    },
    ['skeletonMageElectric']={
        raise=behaviors.common.raise,
        lower=behaviors.common.lower,
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