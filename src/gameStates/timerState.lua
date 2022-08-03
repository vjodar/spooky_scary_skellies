local TimerState={}

function TimerState:load() 
    self.timers={} --table of all timers
end

function TimerState:update()
    for i,timer in pairs(self.timers) do 
        --Update each timer, remove any that return false
        if timer:update()==false then table.remove(self.timers,i) end
    end
end

--Delays a function call by _t seconds
function TimerState:after(_t,_fn)
    local timer={t=_t,fn=_fn}
    function timer:update()
        self.t=self.t-dt --decrement time
        --call fn() when time is up, return false to discard timer
        if self.t<=0 then self.fn() return false end
    end
    table.insert(self.timers,timer)
end

--Tweens the property (number) of an object to an endValue over _time seconds.
function TimerState:tween(_obj,_prop,_endVal,_time)
    local _delta=(_endVal-_obj[_prop])/_time
    local timer={
        t=_time,
        obj=_obj,
        prop=_prop,
        endVal=_endVal,
        delta=_delta,
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
function TimerState:setOnCooldown(_obj,_cdFlag,_cdPeriod)
    _obj[_cdFlag]=true
    local setOffCooldown=function() _obj[_cdFlag]=false end
    self:after(_cdPeriod,setOffCooldown)
end

return TimerState
