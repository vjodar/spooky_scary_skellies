local lose=function(self)
    self.alpha=0
    self.state='fadeInLose'
    GameStates:addState(self)
end

local updateFunctions={
    fadeInLose=function(self) --fade in 'Sad Halloween'
        self.alpha=self.alpha+dt*0.5
        if self.alpha>1 then 
            self.state='waitForInputLose'
        end
    end,
    waitForInputLose=function(self)
        self.buttons.titleScreen:update(self.x,self.y)
        return self.buttons.tryAgain:update(self.x,self.y)
    end,
}

local drawFunctions={
    fadeInLose=function(self)
        love.graphics.setColor(1,1,1,self.alpha)
        love.graphics.draw(self.text.sad,self.x-37,self.y-100)
        love.graphics.draw(self.text.haloween,self.x-116,self.y-68)
        love.graphics.setColor(1,1,1)
    end,
    waitForInputLose=function(self)
        love.graphics.draw(self.text.sad,self.x-37,self.y-100)
        love.graphics.draw(self.text.haloween,self.x-116,self.y-68)
        self.buttons.titleScreen:draw()
        self.buttons.tryAgain:draw()
    end,
}

local newImage=love.graphics.newImage
local mouseInBounds=function(self) --mouse is within bounds
    local mx,my=Controls:getMousePosition()
    return not (mx<self.x or mx>self.x+self.w
            or my<self.y or my>self.y+self.h)
end

local buttons={
    titleScreen={
        x=0, y=0, w=54, h=26,
        sprites={
            up=newImage('assets/screenArt/buttonTitleScreenUp.png'),
            down=newImage('assets/screenArt/buttonTitleScreenDown.png'),
        },
        state='up',
        update=function(self,x,y)
            self.x,self.y=x-(self.w*0.5)-50,y-(self.h*0.5)+20

            if self.state=='up'
            and Controls.down.mouse 
            and self:mouseInBounds()
            then --mouse is down and within bounds, change to down state
                self.state='down'
                return 
            end

            if self.state=='down' then 
                if self:mouseInBounds() then 
                    if Controls.released.mouse then --released in bounds, reset game
                        self.state='up'
                        resetGame() 
                    end 
                else --mouse moved out of bounds, return to up state
                    self.state='up'
                end
                return 
            end
        end,
        draw=function(self)
            love.graphics.draw(self.sprites[self.state],self.x,self.y)
        end,
        mouseInBounds=mouseInBounds,
    },
    tryAgain={
        x=0, y=0, w=54, h=26,
        sprites={
            up=newImage('assets/screenArt/buttonTryAgainUp.png'),
            down=newImage('assets/screenArt/buttonTryAgainDown.png'),
        },
        state='up',
        update=function(self,x,y)
            self.x,self.y=x-(self.w*0.5)+50,y-(self.h*0.5)+20

            if self.state=='up'
            and Controls.down.mouse 
            and self:mouseInBounds()
            then --mouse is down and within bounds, change to down state
                self.state='down'
                return 
            end

            if self.state=='down' then 
                if self:mouseInBounds() then 
                    if Controls.released.mouse then --released in bounds, restart level
                        self.state='up'
                        LevelManager:restartLevel() 
                        return false
                    end 
                else --mouse moved out of bounds, return to up state
                    self.state='up'
                end
                return 
            end
        end,
        draw=function(self)
            love.graphics.draw(self.sprites[self.state],self.x,self.y)
        end,
        mouseInBounds=mouseInBounds,
    },
}

return { --The Module
    x=0, y=0,
    text={
        sad=newImage('assets/screenArt/sad.png'),
        happy=newImage('assets/screenArt/happy.png'),
        haloween=newImage('assets/screenArt/haloween.png'),
    },
    alpha=1,
    buttons=buttons,
    state='idle',
    lose=lose,
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