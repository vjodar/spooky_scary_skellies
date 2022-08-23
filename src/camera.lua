local camera=humpCam()
camera.target={x=0,y=0} --target must be a table with x,y coords
camera.smoother=camera.smooth.damped(10)

function camera:update()
    if self.target.w and self.target.h then --target is a rectangle
        self:lockPosition(self.target.center.x,self.target.center.y,self.smoother)

    else --target is a point
        self:lockPosition(self.target.x,self.target.y,self.smoother)
    end
end

return camera