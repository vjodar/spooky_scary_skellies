local timerState={}
timerState.timers={}

function timerState:clear() self.timers={} end

function timerState:update()
    for i,timer in ipairs(self.timers) do --must use ipairs() 
        --Update each timer, remove any that return false
        if timer:update()==false then table.remove(self.timers,i) end
    end
end

--Delays a function call by t seconds
function timerState:after(t,fn)
    local timer={t=t,fn=fn,update=self.afterUpdate}
    table.insert(self.timers,timer)
end
timerState.afterUpdate=function(self)
    self.t=self.t-dt --decrement time
    --call fn() when time is up, return false to discard timer
    if self.t<=0 then self.fn() return false end
end

--Tweens the property (number) of an object to an endValue over time seconds.
function timerState:tween(obj,prop,endVal,time)
    local delta=(endVal-obj[prop])/time
    local timer={
        t=time,
        obj=obj,
        prop=prop,
        endVal=endVal,
        delta=delta,
        update=self.tweenUpdate,
    }
    table.insert(self.timers,timer)
end
timerState.tweenUpdate=function(self)
    self.t=self.t-dt --decrement timer
    self.obj[self.prop]=self.obj[self.prop]+self.delta*dt --tween
    --When within 1 frame (60fps) of completion, snap to endVal, discard timer 
    if self.t<0.17 then self.obj[self.prop]=self.endVal return false end
end

--Gives a cooldown object its releaseCooldown and setOnCooldown callback function.
--Defining these callbacks upon initialization and passing them to timerState:after()
--is much faster than defining the releaseCooldown inside a timerState:after() call.
function timerState.giveCooldownCallbacks(cd)
    cd.releaseCooldown=function() cd.flag=true end
    cd.setOnCooldown=function() 
        cd.flag=false 
        Timer:after(cd.cooldownPeriod,cd.releaseCooldown) 
    end
end

return timerState
