local start=function(self)
    GameStates:addState(self)
    Camera.smoother=Camera.smooth.damped(0.5)
    self.playButton.isActive=false --will wait for fade to finish
    local activatePlayButton=function() 
        self.playButton:update(self.x,self.y)
        self.playButton.isActive=true 
    end 
    Timer:after(0.5,function() FadeState:fadeIn({fadeTime=2,afterFn=activatePlayButton}) end)
end 

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

local playButton={
    x=0, y=0, w=90, h=32,
    sprites={
        up=newImage('assets/screenArt/buttonPlayUp.png'),
        down=newImage('assets/screenArt/buttonPlayDown.png'),
    },
    state='up',
    isActive=false, --wait for fade in to complete
    update=function(self,x,y)
        self.x,self.y=x-(self.w*0.5),y-(self.h*0.5)

        if GameStates.acceptInput then 
            local userPressedMe=self:updateButton()
            if userPressedMe==true then 
                self.state='up'
                Audio:playSfx('accept')
                PlayState:startGame()
                return false
            end
        end
    end,
    draw=function(self)
        love.graphics.draw(self.sprites[self.state],self.x,self.y)
    end,
    mouseInBounds=mouseInBounds,
    updateButton=updateButton,
}

return {
    x=0, y=0,
    enemyFocus={ --used to pan camera to an enemy periodically
        period=3.5,
        timer=0,
    },
    text={
        title=newImage('assets/screenArt/gameTitle.png'),
        author=newImage('assets/screenArt/author.png'),
    },
    playButton=playButton,
    update=function(self)
        --periodically have the camera follow a random enemy
        local focus=self.enemyFocus
        focus.timer=focus.timer+dt 
        if focus.timer>focus.period then 
            focus.timer=0
            local enemies={}
            for i=1,#Objects.table do
                local o=Objects.table[i]
                if o.collisionClass=='enemy' 
                and o.name~='spiderEgg'
                and o.name~='tombstone'
                then table.insert(enemies,o) end 
            end
            local newTarget=rndElement(enemies).center
            Camera.target=newTarget
            --choose a new target to focus after ~0.5s after pan
            focus.period=0.5+getDistance(Camera,newTarget)*0.01
        end

        self.x,self.y=Camera:position()
        if self.playButton.isActive then             
            return self.playButton:update(self.x,self.y) 
        end
    end,
    draw=function(self)
        love.graphics.draw(self.text.title,self.x-88,self.y-164)
        love.graphics.draw(self.text.author,self.x-50,self.y-68)
        if self.playButton.isActive then self.playButton:draw() end
    end,
    start=start,
}