return {
    buttons=require 'src.hud.buttons',
    health=require 'src.hud.health',

    x=0,y=0,
    isHidden=true, --start off hidden for title screen
    skeletonTotal=0,
    minionLimitReached=false,
    white=Fonts.white,
    red=Fonts.red,
    font=Fonts.white,

    update=function(self)
        self.x,self.y=Camera.x,Camera.y 
        self.buttons:update(self.x,self.y)
        self.health:update(self.x,self.y)
        self.skeletonTotal=LevelManager.currentLevel.allyTotal 
        self.minionLimitReached=self.skeletonTotal>=Player.maxMinions
        self.font=self.minionLimitReached and self.red or self.white
    end,

    draw=function(self)
        if self.isHidden then return end
        self.buttons:draw()
        self.health:draw()
        love.graphics.printf(
            "Skeletons: "..self.skeletonTotal.."/"..Player.maxMinions,
            self.font,self.x-250,self.y+138,500,'center'
        )
    end,

    hide=function(self) self.isHidden=true end, 
    show=function(self) self.isHidden=false end, 
}