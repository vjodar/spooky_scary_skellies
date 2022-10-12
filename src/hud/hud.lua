local hud={}

hud.buttons=require 'src/hud/buttons'
hud.health=require 'src/hud/health'

hud.x,hud.y=0,0
hud.skeletonCount=0

hud.update=function(self)
    self.x,self.y=Camera.x,Camera.y 
    self.buttons:update(self.x,self.y)
    self.health:update(self.x,self.y)
    self.skeletonTotal=self.getSkeletonCount()
end

hud.draw=function(self)
    self.buttons:draw()
    self.health:draw()
    love.graphics.print(
        "Skeletons: "..self.skeletonTotal.."/"..Player.maxMinions,
        self.x-248,self.y-168
    )
end

hud.getSkeletonCount=function()
    local count=LevelManager.currentLevel.allyCount
    local w=count.skeletonWarrior
    local a=count.skeletonArcher 
    local f=count.skeletonMageFire 
    local i=count.skeletonMageIce
    local e=count.skeletonMageElectric 
    return w+a+f+i+e
end

return hud