local setupFade=function(self,mode,fadeTime,afterFn,holdTime)
    --testing------------------------------------------------------
    assert(gameStates[#gameStates]~=self,'already performing fade')
    --testing------------------------------------------------------
    self.mode=mode
    self.inc=1/fadeTime 
    self.afterFn=afterFn
    self.holdTime=holdTime or 0
    if self.mode=='in' then self.inc=-self.inc end
    self.update=self.fadeUpdate 
    table.insert(gameStates,self)
end

local fadeOut=function(self,args) self:setupFade('out',args.fadeTime,args.afterFn,args.holdTime) end
local fadeIn=function(self,args) self:setupFade('in',args.fadeTime,args.afterFn,args.holdTime) end
local fadeBoth=function(self,args) self:setupFade('both',args.fadeTime,args.afterFn,args.holdTime) end

local fadeUpdate=function(self)
    Camera.curtain.alpha=Camera.curtain.alpha+self.inc*dt 
    if (self.mode=='out' and Camera.curtain.alpha>1)
    or (self.mode=='both' and Camera.curtain.alpha>1)
    or (self.mode=='in' and Camera.curtain.alpha<0) 
    then 
        if self.afterFn then self.afterFn() end 
        self.update=self.holdUpdate 
    end
end

local holdUpdate=function(self)
    self.holdTime=self.holdTime-dt 
    if self.holdTime<0 then 
        if self.mode=='both' then --start the fadeIn
            self.mode='in'
            self.inc=-self.inc
            self.afterFn=nil 
            self.update=self.fadeUpdate
        else
            return false --fade is done, remove from gameStates
        end
    end
end

return { --The Module
    inc=0,
    mode='out',
    setupFade=setupFade,
    fadeOut=fadeOut,
    fadeIn=fadeIn,
    fadeBoth=fadeBoth,
    fadeUpdate=fadeUpdate,
    holdUpdate=holdUpdate,
    update=fadeUpdate,
}