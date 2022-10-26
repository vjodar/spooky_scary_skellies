local lose=function(self)
    self.alpha=0
    self.state='fadeInLose'
    GameStates:addState(self)
end

local win=function(self)
    self.alpha=0
    self.state='fadeInWin'
    GameStates:addState(self)
end

local updateFunctions={
    fadeInLose=function(self) --fade in 'Sad Halloween'
        self.alpha=self.alpha+dt*0.5
        if self.alpha>1 then 
            self.state='waitForInputLose'
            self.buttons.titleScreen:update(self.x,self.y,-60,20)
            self.buttons.tryAgain:update(self.x,self.y,60,20)
        end
    end,
    waitForInputLose=function(self)
        self.buttons.titleScreen:update(self.x,self.y,-60,20)
        return self.buttons.tryAgain:update(self.x,self.y,60,20)
    end,

    fadeInWin=function(self) --fade in 'Happy Halloween'
        self.alpha=self.alpha+dt*0.5
        if self.alpha>1 then 
            self.state='waitForInputWin' 
            self.buttons.titleScreen:update(self.x,self.y,0,40)
        end 
    end,
    waitForInputWin=function(self)
        self.buttons.titleScreen:update(self.x,self.y,0,40)
    end,
}

local drawFunctions={
    fadeInLose=function(self)
        love.graphics.setColor(1,1,1,self.alpha)
        love.graphics.draw(self.text.sad,self.x-37,self.y-100)
        love.graphics.draw(self.text.halloween,self.x-116,self.y-68)
        love.graphics.setColor(1,1,1)
    end,
    waitForInputLose=function(self)
        love.graphics.draw(self.text.sad,self.x-37,self.y-100)
        love.graphics.draw(self.text.halloween,self.x-116,self.y-68)
        self.buttons.titleScreen:draw()
        self.buttons.tryAgain:draw()
    end,

    fadeInWin=function(self)
        love.graphics.setColor(1,1,1,self.alpha)
        love.graphics.draw(self.text.happy,self.x-62,self.y-80)
        love.graphics.draw(self.text.halloween,self.x-116,self.y-48)
        love.graphics.setColor(1,1,1)
    end,
    waitForInputWin=function(self)
        love.graphics.draw(self.text.happy,self.x-62,self.y-80)
        love.graphics.draw(self.text.halloween,self.x-116,self.y-48)
        self.buttons.titleScreen:draw()
    end,
}

local newImage=love.graphics.newImage
local mouseInBounds=function(self) --mouse is within bounds
    local mx,my=Controls:getMousePosition()
    return not (mx<self.x or mx>self.x+self.w
            or my<self.y or my>self.y+self.h)
end

local updateButton=function(self)
    if self.state=='up'
    and Controls.down.mouse 
    and self:mouseInBounds()
    then --mouse is down and within bounds, change to down state
        self.state='down'
        return 
    end

    if self.state=='down' then 
        if self:mouseInBounds() then 
            if Controls.released.mouse then --released in bounds
                self.state='up'
                return true 
            end 
        else --mouse moved out of bounds, return to up state
            self.state='up'
        end
        return 
    end
end

local buttons={
    titleScreen={
        x=0, y=0, w=90, h=32,
        sprites={
            up=newImage('assets/screenArt/buttonTitleScreenUp.png'),
            down=newImage('assets/screenArt/buttonTitleScreenDown.png'),
        },
        state='up',
        update=function(self,x,y,xOffset,yOffset)
            self.x,self.y=x-(self.w*0.5)+xOffset,y-(self.h*0.5)+yOffset

            local userPressedMe=self:updateButton()
            if userPressedMe==true then 
                self.state='up'
                FadeState:fadeOut({
                    fadeTime=0.5,
                    afterFn=resetGame,
                })
                return false
            end
        end,
        draw=function(self)
            love.graphics.draw(self.sprites[self.state],self.x,self.y)
        end,
        mouseInBounds=mouseInBounds,
        updateButton=updateButton,
    },
    tryAgain={
        x=0, y=0, w=90, h=32,
        sprites={
            up=newImage('assets/screenArt/buttonTryAgainUp.png'),
            down=newImage('assets/screenArt/buttonTryAgainDown.png'),
        },
        state='up',
        update=function(self,x,y,xOffset,yOffset)
            self.x,self.y=x-(self.w*0.5)+xOffset,y-(self.h*0.5)+yOffset

            local userPressedMe=self:updateButton()
            if userPressedMe==true then 
                self.state='up'
                LevelManager:restartLevel()
                return false
            end
        end,
        draw=function(self)
            love.graphics.draw(self.sprites[self.state],self.x,self.y)
        end,
        mouseInBounds=mouseInBounds,
        updateButton=updateButton,
    },
}

return { --The Module
    x=0, y=0,
    text={
        sad=newImage('assets/screenArt/sad.png'),
        happy=newImage('assets/screenArt/happy.png'),
        halloween=newImage('assets/screenArt/halloween.png'),
    },
    alpha=1,
    buttons=buttons,
    state='idle',
    lose=lose,
    win=win,
    stateMachine={
        update=updateFunctions,
        draw=drawFunctions,
    },
    update=function(self) 
        self.x,self.y=Camera:position()
        return self.stateMachine.update[self.state](self) 
    end,
    draw=function(self) self.stateMachine.draw[self.state](self) end,
}