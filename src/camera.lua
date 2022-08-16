local camera={}

camera.cam=humpCam() --from hump.camera library
camera.target={x=0,y=0} --target must be a table with x,y coords
camera.smoother=camera.cam.smooth.damped(10)   

function camera:update()
    self.cam:lockPosition(self.target.x,self.target.y,self.smoother)
end

return camera