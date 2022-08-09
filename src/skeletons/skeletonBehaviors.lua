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

behaviors.raise=function(_s) --state changes to idle upon animation loop
    behaviors.updatePosition(_s)
    behaviors.updateAnimation(_s)
end

behaviors.lower=function(_s) --state changes to raise upon animation loop
    behaviors.updatePosition(_s)
    behaviors.updateAnimation(_s)
end

behaviors.idle=function(_s)
    behaviors.updatePosition(_s)
    behaviors.updateAnimation(_s)

    --update distance from Player
    _s.distanceFromPlayer=(abs(Player.x-_s.x)^2+abs(Player.y-_s.y)^2)^0.5

    --if skeleton is too far from player, move toward Player
    if _s.distanceFromPlayer>_s.distanceFromPlayerThreshold then
        _s.moveTarget=Player
        _s.moveTargetOffset=10+rnd()*40 --will stop 10-50px from target
        _s:changeState('move')
    end
end

behaviors.resetMoveTarget=function(_s)
    _s.moveTargetOffset=0
    _s.moveTarget=_s 
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

behaviors.changeState=function(_s,_newState)
    _s.state=_newState 
    if _s.animations[_newState] then 
        _s.animations.current=_s.animations[_newState]
    end
end

behaviors.AI={
    ['skeleton_warrior']={
        raise=behaviors.raise,
        lower=behaviors.lower,
        idle=behaviors.idle,
        move=behaviors.move,
        attack=behaviors.attackMelee,
    },
    ['skeleton_archer']={
        raise=behaviors.raise,
        lower=behaviors.lower,
        idle=behaviors.idle,
        move=behaviors.move,
        attack=behaviors.attackRange,
    },
    ['skeleton_mage_fire']={
        raise=behaviors.raise,
        lower=behaviors.lower,
        idle=behaviors.idle,
        move=behaviors.move,
        attack=behaviors.attackRange,
    },
    ['skeleton_mage_ice']={
        raise=behaviors.raise,
        lower=behaviors.lower,
        idle=behaviors.idle,
        move=behaviors.move,
        attack=behaviors.attackRange,
    },
    ['skeleton_mage_electric']={
        raise=behaviors.raise,
        lower=behaviors.lower,
        idle=behaviors.idle,
        move=behaviors.move,
        attack=behaviors.attackRange,
    },
}

return behaviors