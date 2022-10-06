local camera=humpCam()
camera.target={x=0,y=0} --target must be a table with x,y coords
camera.smoother=camera.smooth.damped(10)
camera.shakeData={
    magnitude=0,
    period=0.01,
    timer=0,
    damping=10,
    stopThreshold=0.5*60,
}

camera.curtain={ --curtain is used for fading in/out    
    w=1000,h=750, r=53/255,g=53/255,b=64/255,alpha=0,
    draw=function(self) 
        love.graphics.setColor(self.r,self.g,self.b,self.alpha)
        love.graphics.rectangle(
            'fill',Camera.x-(self.w*0.5),Camera.y-(self.h*0.5),self.w,self.h
        )
        love.graphics.setColor(1,1,1,1)
    end
}

camera.update=function(self) 
    self:lockPosition(self.target.x,self.target.y) --smoothly follow camera target
    if self.shakeData.magnitude>0 then self:updateShake() end
 end

 camera.updateShake=function(self)
    local shake=self.shakeData 
    shake.timer=shake.timer+dt 
    if shake.timer>shake.period then --shake the camera 
        shake.timer=0
        local angle=rnd()*2*pi
        local shakeX=cos(angle)*shake.magnitude 
        local shakeY=sin(angle)*shake.magnitude 
        self:move(shakeX,shakeY)
    end
    --reduce magnitude
    shake.magnitude=shake.magnitude-(shake.magnitude*shake.damping*dt)
    if shake.magnitude<shake.stopThreshold*dt then shake.magnitude=0 end 
 end

 camera.shake=function(self,args) --args={magnitude,period,damping,stopThreshold}
    local shake=self.shakeData
    shake.magnitude=shake.magnitude+(args.magnitude or 5)
    shake.period=args.period or 0.01
    shake.damping=args.damping or 10
    shake.stopThreshold=args.stopThreshold or 0.5
    shake.stopThreshold=shake.stopThreshold*60 --frameRate sensitive
 end

return camera