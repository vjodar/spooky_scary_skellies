local behaviors={}

behaviors.onLoopFunctions={
    changeToIdle=function(_e)
        return function() _e:changeState('idle')  end
    end,
}

behaviors.updatePosition=function(_e)
    _e.x,_e.y=_e.collider:getPosition()
end

behaviors.updateAnimation=function(_e)
    _e.animations.current:update(dt*_e.animSpeed.current)
end

behaviors.changeState=function(_e,_newState)
    _e.state=_newState 
    if _e.animations[_newState] then 
        _e.animations.current=_e.animations[_newState]
    end
end

--Gets all attack targets in aggro range
behaviors.queryForAttackTargets=function(_e)
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
end

--Gets the closest attack target within LOS
behaviors.getNearestAttackTarget=function(_e)
    local nearbyAttackTargets=behaviors.queryForAttackTargets(_e)
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
end

-------------------------------------------------------------------------------

behaviors.idle=function(_e)
    behaviors.updatePosition(_e)
    behaviors.updateAnimation(_e)
    
    if _e.queryAttackTargetReady then 
        Timer:setOnCooldown(_e,'queryAttackTargetReady',_e.queryAttackTargetRate)
        _e.moveTarget=behaviors.getNearestAttackTarget(_e)
        _e:changeState('move')
    end
end

behaviors.move=function(_e)
    behaviors.updatePosition(_e)
    behaviors.updateAnimation(_e)
    
    --if target has died, clear moveTarget, return to idle
    if _e.moveTarget.state=='dead' then
        _e:changeState('idle')
        _e.moveTarget=_e 
        return 
    end 
    
    local xVel,yVel=0,0
    local reachedAttackRange=(
        (abs(_e.moveTarget.x-_e.x)^2+abs(_e.moveTarget.y-_e.y)^2)^0.5
    )<_e.attackRange
    
    if reachedAttackRange then 
        _e:changeState('idle') 
        _e.moveTarget=_e --clear moveTarget
        return 
    end

    --TODO: query for closer attack targets
    
    local angle=atan2((_e.moveTarget.y-_e.y),(_e.moveTarget.x-_e.x))
    xVel=cos(angle)*_e.moveSpeed
    yVel=sin(angle)*_e.moveSpeed
    if _e.moveTarget.x>_e.x then _e.scaleX=1 else _e.scaleX=-1 end 
    _e.collider:applyForce(xVel,yVel)
end

behaviors.attackMelee=function(_e)

end

behaviors.attackRange=function(_e)

end

-------------------------------------------------------------------------------

behaviors.AI={
    ['slime']={
        idle=behaviors.idle,
        move=behaviors.move,
        attack=behaviors.attackMelee,
    },
}

return behaviors