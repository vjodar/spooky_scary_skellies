local timerState={}
timerState.timers={}

function timerState:clear() self.timers={} end

function timerState:update()
    for i,timer in pairs(self.timers) do 
        --Update each timer, remove any that return false
        if timer:update()==false then table.remove(self.timers,i) end
    end
end

--Delays a function call by t seconds
function timerState:after(t,fn)
    local timer={t=t,fn=fn}
    function timer:update()
        self.t=self.t-dt --decrement time
        --call fn() when time is up, return false to discard timer
        if self.t<=0 then self.fn() return false end
    end
    table.insert(self.timers,timer)
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
    }
    function timer:update()
        self.t=self.t-dt --decrement timer
        self.obj[self.prop]=self.obj[self.prop]+self.delta*dt --tween
        --When within 1 frame (60fps) of completion, snap to endVal, discard timer 
        if self.t<0.17 then self.obj[self.prop]=self.endVal return false end
    end
    table.insert(self.timers,timer)
end

--Set a cooldown timer 
function timerState:setOnCooldown(obj,cdFlag,cdPeriod)
    obj[cdFlag]=false
    local releaseCooldown=function() obj[cdFlag]=true end
    self:after(cdPeriod,releaseCooldown)
end

return timerState
