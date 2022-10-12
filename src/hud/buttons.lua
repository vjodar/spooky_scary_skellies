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
        fire=getImage('iconMageFire'),
        ice=getImage('iconMageIce'),
        electric=getImage('iconMageElectric'),
    }
}

buttons.x,buttons.y=0,0
buttons.warriorSpriteIndex=1 --used to draw the appropriate button sprite
buttons.archerSpriteIndex=1
buttons.mageSpriteIndex=1

buttons.cooldownBar={ --used to show when player can summon again
    x=0, y=0,
    color={237/255,228/255,218/255},
    active=false,
    progress=1,
    increment=0,
    length=56,
}

buttons.update=function(self,x,y)
    self.x=x-32
    self.y=y+154
    self.cooldownBar.x=self.x+4
    self.cooldownBar.y=self.y+24.5
    
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
        love.graphics.draw(self.sprites.warriorIcon,self.x,self.y)
        --TODO: only draw icon when archer and/or mage is unlocked-------
        love.graphics.draw(self.sprites.archerIcon,self.x,self.y)
        love.graphics.draw(self.sprites.mageIcon['fire'],self.x,self.y)
    end

    --draw cooldown progress bar
    local bar=self.cooldownBar 
    love.graphics.setColor(bar.color)
    love.graphics.setLineWidth(1)
    love.graphics.line(bar.x,bar.y,bar.x+bar.length*bar.progress,bar.y)
    love.graphics.setColor(1,1,1)
end

return buttons