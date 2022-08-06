local camera={}

function camera:load()
    self.cam=humpCam() --from hump.camera library
    self.target={x=0,y=0} --target must be a table with x,y coords
    self.smoother=self.cam.smooth.damped(10)

    return self
end

function camera:update()
    self.cam:lockPosition(self.target.x,self.target.y,self.smoother)
end

return camera:load()