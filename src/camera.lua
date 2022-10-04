local camera=humpCam()
camera.target={x=0,y=0} --target must be a table with x,y coords
camera.smoother=camera.smooth.damped(10)

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

function camera:update() self:lockPosition(self.target.x,self.target.y) end

return camera