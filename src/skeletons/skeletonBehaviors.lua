local behaviors={}

behaviors.onLoopFunctions={
    changeToIdle=function(_s)
        return function() _s:changeState('idle')  end
    end,
    changeToRaise=function(_s)
        return function()
            _s:changeState('raise')
            _s.collider:setPosition(Player.x,Player.y)
        end
    end,
}

behaviors.updatePosition=function(_s)
    _s.x,_s.y=_s.collider:getPosition()
end

behaviors.updateAnimation=function(_s)
    _s.animations.current:update(dt*_s.animSpeed.current)
end

behaviors.raise=function(_s)
    behaviors.updatePosition(_s)
    behaviors.updateAnimation(_s)
end

behaviors.lower=function(_s)
    behaviors.updatePosition(_s)
    behaviors.updateAnimation(_s)
end

behaviors.idle=function(_s)
    behaviors.updatePosition(_s)
    behaviors.updateAnimation(_s)

    --if skeleton is far from player, move toward player
    local distanceToPlayer=(abs(Player.x-_s.x)^2+abs(Player.y-_s.y)^2)^0.5
    if distanceToPlayer>80 then 
        _s.moveTarget=Player
        _s:changeState('move')
    end
end

behaviors.move=function(_s)
    behaviors.updatePosition(_s)
    behaviors.updateAnimation(_s)

    local xVel,yVel=0,0
    local reachedTarget=((abs(_s.moveTarget.x-_s.x)^2+abs(_s.moveTarget.y-_s.y)^2)^0.5)<40

    if reachedTarget then _s:changeState('idle') return end

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