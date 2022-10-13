return {
    buttons=require 'src/hud/buttons',
    health=require 'src/hud/health',

    x=0,y=0,
    skeletonTotal=0,
    minionLimitReached=false,
    font=UI.fonts.white,

    update=function(self)
        self.x,self.y=Camera.x,Camera.y 
        self.buttons:update(self.x,self.y)
        self.health:update(self.x,self.y)
        self.skeletonTotal=LevelManager.currentLevel.allyTotal 
        self.minionLimitReached=self.skeletonTotal>=Player.maxMinions
        self.font=self.minionLimitReached and UI.fonts.red or UI.fonts.white
    end,

    draw=function(self)
        self.buttons:draw()
        self.health:draw()
        love.graphics.printf(
            "Skeletons: "..self.skeletonTotal.."/"..Player.maxMinions,
            self.font,self.x-250,self.y+138,500,'center'
        )
    end
}