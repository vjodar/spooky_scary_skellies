local buttons={}

local getImage=function(name) return love.graphics.newImage('assets/hud/'..name..'.png') end 

buttons.sprites={
    panel=getImage('buttonsPanel'),
    warriorButton={getImage('buttonWarriorUp'), getImage('buttonWarriorDown')},
    archerButton={getImage('buttonArcherUp'), getImage('buttonArcherDown')},
    mageButton={getImage('buttonMageUp'), getImage('buttonMageDown')},
    warriorIcon=getImage('iconWarrior'),
    archerIcon=getImage('iconArcher'),
    mageIcon={
        Fire=getImage('iconMageFire'),
        Ice=getImage('iconMageIce'),
        Electric=getImage('iconMageElectric'),
    }
}

buttons.x,buttons.y=0,0
buttons.halfWidth=buttons.sprites.panel:getWidth()*0.5
buttons.warriorSpriteIndex=1 --used to draw the appropriate button sprite
buttons.archerSpriteIndex=1
buttons.mageSpriteIndex=1

buttons.cooldownBar={ --used to show when player can summon again
    x=0, y=0,
    color={237/255,228/255,218/255},
    active=false,
    progress=1,
    increment=0,
    length=60,
}

buttons.update=function(self,x,y)
    self.x=x-self.halfWidth
    self.y=y+146
    self.cooldownBar.x=self.x+6
    self.cooldownBar.y=self.y+5
    
    self.warriorSpriteIndex,self.archerSpriteIndex,self.mageSpriteIndex=1,1,1

    if acceptInput then 
        if Controls.down.btn1 then self.warriorSpriteIndex=2 end 
        if Controls.down.btn2 then self.archerSpriteIndex=2 end 
        if Controls.down.btn3 then self.mageSpriteIndex=2 end 
    end

    if Player.canSummon.flag==false then
        local bar=self.cooldownBar
        if bar.active then 
            bar.progress=bar.progress+bar.increment*dt
            bar.progress=min(bar.progress,1)
            if bar.progress==1 then 
                bar.active=false
            end 
        else
            bar.active=true 
            bar.progress=0
            bar.increment=1/Player.canSummon.cooldownPeriod 
        end
    else 
        self.cooldownBar.active=false 
        self.cooldownBar.progress=1
    end
end

buttons.draw=function(self)
    love.graphics.draw(self.sprites.panel,self.x,self.y)
    love.graphics.draw(self.sprites.warriorButton[self.warriorSpriteIndex],self.x,self.y)
    love.graphics.draw(self.sprites.archerButton[self.archerSpriteIndex],self.x,self.y)
    love.graphics.draw(self.sprites.mageButton[self.mageSpriteIndex],self.x,self.y)

    --draw icons when summon is off cooldown (and skeleton type has been unlocked )
    if Player.canSummon.flag then 
        love.graphics.draw(self.sprites.warriorIcon,self.x,self.y+self.warriorSpriteIndex-1)
        if Player.upgrades.skeletonArcher then 
            love.graphics.draw(self.sprites.archerIcon,self.x,self.y+self.archerSpriteIndex-1)
        end
        local mage=Player.selectedMage 
        if Player.upgrades['skeletonMage'..mage] then 
            love.graphics.draw(self.sprites.mageIcon[mage],self.x,self.y+self.mageSpriteIndex-1)
        end
    end

    --draw cooldown progress bar
    local bar=self.cooldownBar 
    love.graphics.setColor(bar.color)
    love.graphics.line(bar.x,bar.y,bar.x+bar.length*bar.progress,bar.y)
    love.graphics.setColor(1,1,1)
end

return buttons