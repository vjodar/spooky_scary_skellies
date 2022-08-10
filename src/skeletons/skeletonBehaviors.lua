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
}

behaviors.updatePosition=function(_s)
    _s.x,_s.y=_s.collider:getPosition()
end

behaviors.updateAnimation=function(_s)
    _s.animations.current:update(dt*_s.animSpeed.current)
end

behaviors.changeState=function(_s,_newState)
    _s.state=_newState 
    if _s.animations[_newState] then 
        _s.animations.current=_s.animations[_newState]
    end
end

behaviors.resetMoveTarget=function(_s)
    _s.moveTargetOffset=0
    _s.moveTarget=_s 
end

--Gets the closest attack target within LOS from the Player's nearby enemies table
behaviors.getNearestAttackTarget=function(_s)
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
end

-------------------------------------------------------------------------------

behaviors.raise=function(_s)
    behaviors.updatePosition(_s)
    behaviors.updateAnimation(_s)
    _s.animations.raise.onLoop=_s.onLoopFunctions.changeToIdle
end

behaviors.lower=function(_s)
    behaviors.updatePosition(_s)
    behaviors.updateAnimation(_s)
    _s.animations.lower.onLoop=_s.onLoopFunctions.changeToRaise
end

behaviors.idle=function(_s)
    behaviors.updatePosition(_s)
    behaviors.updateAnimation(_s)

    --update distance from Player
    _s.distanceFromPlayer=(abs(Player.x-_s.x)^2+abs(Player.y-_s.y)^2)^0.5

    --if skeleton is too far from player, move to player
    if _s.distanceFromPlayer>_s.returnToPlayerThreshold then
        _s.moveTarget=Player
        _s.moveTargetOffset=10+rnd()*40 --will stop 10-50px from player
        _s:changeState('move')
    end

    --find and target the nearest enemy
    if _s.queryAttackTargetReady then 
        Timer:setOnCooldown(_s,'queryAttackTargetReady',_s.queryAttackTargetRate)
        _s.moveTarget=behaviors.getNearestAttackTarget(_s)
        _s.moveTargetOffset=_s.attackRange
        _s:changeState('move')
    end
end

behaviors.move=function(_s)
    behaviors.updatePosition(_s)
    behaviors.updateAnimation(_s)

    if _s.moveTarget.state=='dead' then --if target has died, return to idle
        _s:changeState('idle')
        behaviors.resetMoveTarget(_s)
        return 
    end 

    local xVel,yVel=0,0
    local reachedTarget=(
        (abs(_s.moveTarget.x-_s.x)^2+abs(_s.moveTarget.y-_s.y)^2)^0.5
    )<_s.moveTargetOffset

    if reachedTarget then 
        _s:changeState('idle') 
        behaviors.resetMoveTarget(_s)
        return 
    end

    local angle=atan2((_s.moveTarget.y-_s.y),(_s.moveTarget.x-_s.x))
    xVel=cos(angle)*_s.moveSpeed
    yVel=sin(angle)*_s.moveSpeed
    if _s.moveTarget.x>_s.x then _s.scaleX=1 else _s.scaleX=-1 end 
    _s.collider:applyForce(xVel,yVel)
end

behaviors.attackMelee=function(_s)

end

behaviors.attackRange=function(_s)

end

-------------------------------------------------------------------------------

behaviors.AI={
    ['warrior']={
        raise=behaviors.raise,
        lower=behaviors.lower,
        idle=behaviors.idle,
        move=behaviors.move,
        attack=behaviors.attackMelee,
    },
    ['archer']={
        raise=behaviors.raise,
        lower=behaviors.lower,
        idle=behaviors.idle,
        move=behaviors.move,
        attack=behaviors.attackRange,
    },
    ['mageFire']={
        raise=behaviors.raise,
        lower=behaviors.lower,
        idle=behaviors.idle,
        move=behaviors.move,
        attack=behaviors.attackRange,
    },
    ['mageIce']={
        raise=behaviors.raise,
        lower=behaviors.lower,
        idle=behaviors.idle,
        move=behaviors.move,
        attack=behaviors.attackRange,
    },
    ['mageElectric']={
        raise=behaviors.raise,
        lower=behaviors.lower,
        idle=behaviors.idle,
        move=behaviors.move,
        attack=behaviors.attackRange,
    },
}

return behaviors