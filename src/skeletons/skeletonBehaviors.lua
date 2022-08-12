local behaviors={}

behaviors.onLoopFunctions={
    changeToIdle=function(_s)
        return function() _s:changeState('idle')  end
    end,
    changeToRaise=function(_s)
        return function()
            _s.collider:setPosition(Player.x,Player.y)
            _s:changeState('raise')
        end
    end,
    changeToMove=function(_s)
        return function() _s:changeState('move') end
    end,
}

--Methods--------------------------------------------------------------------==

behaviors.methods={
    update=function(_s) return _s.AI[_s.state](_s) end,
    draw=function(_s)
        _s.animations.current:draw(
            _s.spriteSheet,_s.x,_s.y,
            nil,_s.scaleX,1,_s.xOffset,_s.yOffset
        )
    end,

    updatePosition=function(_s)
        _s.x,_s.y=_s.collider:getPosition()
    end,

    updateAnimation=function(_s)
        _s.animations.current:update(dt*_s.animSpeed.current)
    end,

    takeDamage=function(_s,_source)
        local hp=_s.health.current 
        local damage=_source.attackDamage or 0 
        local knockback=_source.knockback or 0
        local angle=atan2((_source.y-_s.y),(_source.x-_s.x))+pi
        
        hp=max(0,hp-damage)
        _s.health.current=hp

        local ix,iy=cos(angle)*knockback,sin(angle)*knockback
        _s.collider:applyLinearImpulse(ix,iy)

        if _s.health.current==0 then _s:die() end
    end,

    dealDamage=function(_s,_target)
        _target:takeDamage(_s) 
    end,

    die=function(_s)
        _s.collider:destroy()
        _s:changeState('dead')
    end,

    changeState=function(_s,_newState)
        _s.state=_newState 
        if _s.animations[_newState] then 
            _s.animations.current=_s.animations[_newState]
        end
    end,

    resetMoveTarget=function(_s)
        _s.moveTargetOffset=0
        _s.moveTarget=_s 
    end,

    --Gets the closest attack target within LOS from the Player's nearby enemies table
    getNearestAttackTarget=function(_s)
        local nearbyEnemies=Player.nearbyEnemies
        if #nearbyEnemies==0 then return _s end --nothing nearby, reset moveTarget

        --filter out any targets blocked from LOS
        local LOSblockers={'ALL',{except='enemy'}}
        for i,target in pairs(nearbyEnemies) do 
            if #World:queryLine(_s.x,_s.y,target.x,target.y,LOSblockers)>0 then 
                table.remove(nearbyEnemies,i)
            end
        end
        
        local closest=nil --find and return the closest target
        for _,target in pairs(nearbyEnemies) do 
            local dist=((abs(_s.x-target.x))^2+(abs(_s.y-target.y))^2)^0.5
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

behaviors.raise=function(_s)
    _s:updatePosition()
    _s:updateAnimation()
    _s.animations.raise.onLoop=_s.onLoopFunctions.changeToIdle
end

behaviors.lower=function(_s)
    _s:updatePosition()
    _s:updateAnimation()
    _s.animations.lower.onLoop=_s.onLoopFunctions.changeToRaise
end

behaviors.idle=function(_s)
    _s:updatePosition()
    _s:updateAnimation()

    --update distance from Player
    _s.distanceFromPlayer=(abs(Player.x-_s.x)^2+abs(Player.y-_s.y)^2)^0.5

    --if skeleton is too far from player, move to player
    if _s.distanceFromPlayer>_s.returnToPlayerThreshold then
        _s.moveTarget=Player
        _s.moveTargetOffset=10+rnd()*40 --will stop 10-50px from player
        _s:changeState('move')
    end

    --find and target the nearest enemy
    if _s.canQueryAttackTarget then 
        Timer:setOnCooldown(_s,'canQueryAttackTarget',_s.queryAttackTargetRate)
        _s.moveTarget=_s:getNearestAttackTarget()
        if _s.moveTarget~=_s then 
            _s.moveTargetOffset=_s.attackRange
            _s:changeState('move') 
        end
    end
end

behaviors.move=function(_s)
    _s:updatePosition()
    _s:updateAnimation()

    --if moveTarget has died or has been cleared, return to idle
    if _s.moveTarget.state=='dead' or _s.moveTarget==_s then
        _s:changeState('idle')
        _s:resetMoveTarget()
        return 
    end 

    if _s.moveTarget.x>_s.x then _s.scaleX=1 else _s.scaleX=-1 end 
    _s.angle=atan2((_s.moveTarget.y-_s.y),(_s.moveTarget.x-_s.x))

    local xVel,yVel=0,0
    local reachedTarget=(
        (abs(_s.moveTarget.x-_s.x)^2+abs(_s.moveTarget.y-_s.y)^2)^0.5
    )<_s.moveTargetOffset

    if reachedTarget then 
        if _s.moveTarget~=Player and _s.canAttack  then 
            _s:changeState('attack')
            return
        end
        _s:changeState('idle')
        return
    end

    xVel=cos(_s.angle)*_s.moveSpeed
    yVel=sin(_s.angle)*_s.moveSpeed
    _s.collider:applyForce(xVel,yVel)
end

behaviors.attackLunge=function(_s)
    _s:updatePosition()
    _s:updateAnimation()
    _s.animations.attack.onLoop=_s.onLoopFunctions.changeToMove

    if _s:onDamagingFrames() then
        if _s.canAttack then 
            local ix=cos(_s.angle)*_s.lungeSpeed
            local iy=sin(_s.angle)*_s.lungeSpeed
            _s.collider:applyLinearImpulse(ix,iy)
            Timer:setOnCooldown(_s,'canAttack',_s.attackSpeed)
        end

        if _s.collider:enter('enemy') then 
            local data=_s.collider:getEnterCollisionData('enemy')
            local enemy=data.collider:getObject()
            if enemy~=nil then _s:dealDamage(enemy) end
        end
    end
end

behaviors.attackRanged=function(_s)
    _s:updatePosition()
    _s:updateAnimation()
    _s.animations.attack.onLoop=_s.onLoopFunctions.changeToMove

    if _s.canAttack and _s:onDamagingFrames() then
        local target=_s:getNearestAttackTarget()
        local angleToTarget=atan2( --calculate angle from ARROW to target
            (_s.moveTarget.y-_s.y),(_s.moveTarget.x-(_s.x+14*_s.scaleX))
        )
        Projectiles:new({
            x=_s.x+14*_s.scaleX,y=_s.y,name='arrow',attackDamage=_s.attackDamage,
            knockback=_s.knockback,angle=angleToTarget
        })
        Timer:setOnCooldown(_s,'canAttack',_s.attackSpeed)
    end
end

behaviors.dead=function(_s)
    return false
end

--AI---------------------------------------------------------------------------

behaviors.AI={
    ['skeletonWarrior']={
        raise=behaviors.raise,
        lower=behaviors.lower,
        idle=behaviors.idle,
        move=behaviors.move,
        attack=behaviors.attackLunge,
        dead=behaviors.dead,
    },
    ['skeletonArcher']={
        raise=behaviors.raise,
        lower=behaviors.lower,
        idle=behaviors.idle,
        move=behaviors.move,
        attack=behaviors.attackRanged,
        dead=behaviors.dead,
    },
    ['skeletonMageFire']={
        raise=behaviors.raise,
        lower=behaviors.lower,
        idle=behaviors.idle,
        move=behaviors.move,
        attack=behaviors.attackRanged,
        dead=behaviors.dead,
    },
    ['skeletonMageIce']={
        raise=behaviors.raise,
        lower=behaviors.lower,
        idle=behaviors.idle,
        move=behaviors.move,
        attack=behaviors.attackRanged,
        dead=behaviors.dead,
    },
    ['skeletonMageElectric']={
        raise=behaviors.raise,
        lower=behaviors.lower,
        idle=behaviors.idle,
        move=behaviors.move,
        attack=behaviors.attackRanged,
        dead=behaviors.dead,
    },
}

return behaviors