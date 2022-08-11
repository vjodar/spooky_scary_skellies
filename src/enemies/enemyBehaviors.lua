local behaviors={}

--onLoopFunctions--------------------------------------------------------------

behaviors.onLoopFunctions={
    changeToIdle=function(_e)
        return function() _e:changeState('idle')  end
    end,
    changeToMove=function(_e)
        return function() _e:changeState('move') end 
    end,
}

--Methods----------------------------------------------------------------------

behaviors.methods={
    update=function(_e) return _e.AI[_e.state](_e) end,
    draw=function(_e)
        _e.animations.current:draw(
            _e.spriteSheet,_e.x,_e.y,
            nil,_e.scaleX,1,_e.xOffset,_e.yOffset
        )
    end,

    updateAnimation=function(_e)
        _e.animations.current:update(dt*_e.animSpeed.current)
    end,

    updatePosition=function(_e)
        _e.x,_e.y=_e.collider:getPosition()
    end,

    takeDamage=function(_e,_source)
        local hp=_e.health.current 
        local damage=_source.attackDamage or 0
        local knockback=_source.knockback or 0
        local angle=atan2((_source.y-_e.y),(_source.x-_e.x))+pi
        
        hp=max(0,hp-damage)
        _e.health.current=hp

        local ix,iy=cos(angle)*knockback,sin(angle)*knockback
        _e.collider:applyLinearImpulse(ix,iy)

        if _e.health.current==0 then _e:die() end
    end,

    dealDamage=function(_e,_target) _target:takeDamage(_e) end,

    die=function(_e)
        _e.collider:destroy()
        _e:changeState('dead')
    end,

    changeState=function(_e,_newState)
        _e.state=_newState 
        if _e.animations[_newState] then 
            _e.animations.current=_e.animations[_newState]
        end
    end,
    
    --Gets all attack targets in aggro range
    queryForAttackTargets=function(_e)
        local queryData={
            x=_e.x-(_e.aggroRange.w*0.5),
            y=_e.y-(_e.aggroRange.h*0.5),
            w=_e.aggroRange.w,
            h=_e.aggroRange.h,
            colliderNames={'player','skeleton'}
        }    
        local targetColliders=World:queryRectangleArea(
            queryData.x,queryData.y,queryData.w,queryData.h,queryData.colliderNames
        )
        local targets={}
        for _,c in pairs(targetColliders) do table.insert(targets,c:getObject()) end 
        return targets
    end,
    
    --Gets the closest attack target within LOS
    getNearestAttackTarget=function(_e)
        local nearbyAttackTargets=_e:queryForAttackTargets()
        if #nearbyAttackTargets==0 then return _e end --nothing nearby, reset moveTarget
    
        --filter out any targets blocked from LOS
        local LOSblockers={'ALL',{except='player','skeleton'}}
        for i,target in pairs(nearbyAttackTargets) do 
            if #World:queryLine(_e.x,_e.y,target.x,target.y,LOSblockers)>0 then 
                table.remove(nearbyAttackTargets,i)
            end
        end
        
        local closest=nil --find and return the closest target
        for _,target in pairs(nearbyAttackTargets) do 
            local dist=((abs(_e.x-target.x))^2+(abs(_e.y-target.y))^2)^0.5
            if closest==nil or closest.d>dist then closest={t=target,d=dist} end
        end
        return closest.t
    end,

    onDamagingFrames=function(_e)
        return _e.animations.current.position >= _e.damagingFrames[1]
            and _e.animations.current.position <= _e.damagingFrames[2]
    end,
}

--States-----------------------------------------------------------------------

behaviors.idle=function(_e)
    _e:updateAnimation()
    _e:updatePosition()
    
    if _e.canQueryAttackTarget then 
        Timer:setOnCooldown(_e,'canQueryAttackTarget',_e.queryAttackTargetRate)
        _e.moveTarget=_e:getNearestAttackTarget()
        if _e.moveTarget~=_e then _e:changeState('move') end
    end
end

behaviors.move=function(_e)
    _e:updateAnimation()
    _e:updatePosition()
    
    --if target has died, clear moveTarget, return to idle
    if _e.moveTarget.state=='dead' then
        _e:changeState('idle')
        _e.moveTarget=_e 
        return 
    end 

    _e.angle=atan2((_e.moveTarget.y-_e.y),(_e.moveTarget.x-_e.x))
    if _e.moveTarget.x>_e.x then _e.scaleX=1 else _e.scaleX=-1 end --face target
    
    local xVel,yVel=0,0
    local reachedAttackRange=(
        (abs(_e.moveTarget.x-_e.x)^2+abs(_e.moveTarget.y-_e.y)^2)^0.5
    )<_e.attackRange
    
    if reachedAttackRange then 
        if _e.canAttack then 
            _e:changeState('attack')
            return 
        end 
        --attack still on cooldown
        _e:changeState('idle')
        return 
    end

    --TODO: query for closer attack targets
    
    xVel=cos(_e.angle)*_e.moveSpeed
    yVel=sin(_e.angle)*_e.moveSpeed
    _e.collider:applyForce(xVel,yVel)
end

behaviors.attackLunge=function(_e)
    _e:updateAnimation()
    _e:updatePosition()
    _e.animations.attack.onLoop=_e.onLoopFunctions.changeToMove

    if _e:onDamagingFrames() then 
        if _e.canAttack then 
            local ix=cos(_e.angle)*_e.lungeSpeed
            local iy=sin(_e.angle)*_e.lungeSpeed
            _e.collider:applyLinearImpulse(ix,iy)        
            Timer:setOnCooldown(_e,'canAttack',_e.attackSpeed)
        end        

        if _e.collider:enter('skeleton') then 
            local data=_e.collider:getEnterCollisionData('skeleton')
            local skeleton=data.collider:getObject()
            if skeleton~=nil then _e:dealDamage(skeleton) end
        end

        if _e.collider:enter('player') then 
            print("hit the player")
        end
    end
end

behaviors.attackRange=function(_e)
    _e:updateAnimation()
    _e:updatePosition()
    _e.animations.attack.onLoop=_e.onLoopFunctions.changeToMove

end

behaviors.dead=function(_e)
    return false
end

--AI---------------------------------------------------------------------------

behaviors.AI={
    ['slime']={
        idle=behaviors.idle,
        move=behaviors.move,
        attack=behaviors.attackLunge,
        dead=behaviors.dead,
    },
}

return behaviors