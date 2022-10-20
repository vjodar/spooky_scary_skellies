local screenWidth,screenHeight=love.window.getMode()

local definitions={
    cardPoof={
        frameWidth=120,
        frameHeight=108,
        animations={
            spawn={
                frames='1-14',
                row=1,
                durations=0.08,
            },
        }
    }
}

local generateDrawData=function(cardDef)
    local cardSprite=love.graphics.newImage('assets/hud/upgradeCard.png')
    local cardPoof=love.graphics.newImage('assets/hud/upgradeCardPoof.png')
    local imageWidth,imageHeight=cardPoof:getDimensions()
    local grid=anim8.newGrid(
        cardDef.frameWidth,cardDef.frameHeight,imageWidth,imageHeight
    )

    local animations={}
    for name,def in pairs(cardDef.animations) do 
        animations[name]=anim8.newAnimation(
            grid(def.frames,def.row),def.durations
        )
    end

    return cardSprite,cardPoof,animations 
end
local sprite,poof,animations=generateDrawData(definitions.cardPoof)
local pressedButtonSprite=love.graphics.newImage('assets/hud/pressedButton.png')

local presentCards=function(self,count,isBossChest)
    self.center.x,self.center.y=Camera.x,Camera.y 
    local upgrades=Upgrades:pickUpgrades(count,isBossChest)

    local cardOffsets={-166,0,166,-83,83}
    local cardHeightSixTenths=self.cardHeight*0.6
    for i=1,#upgrades do 
        local xOffset=cardOffsets[i]   
        local yOffset=cardHeightSixTenths*((i<=3 and -1 or 1))
        self:newCard(upgrades[i],0,0,xOffset,yOffset) 
    end
    self.upgradeSelectionDone=false 
    table.insert(gameStates,self)
end

local selectionUpdate=function(self)
    self.center.x,self.center.y=Camera.x,Camera.y
    local cardX=self.center.x-self.cardWidth*0.5
    local cardY=self.center.y-self.cardHeight*0.5
    for i,card in ipairs(self.cards) do 
        local res=card:update(cardX,cardY)
        if res==true then 
            self.upgradeSelectionDone=true 
            self:despawnCards()
            break
        end
        if res==false then table.remove(self.cards,i) end
    end
    if #self.cards==0 then return false end
end

local selectionDraw=function(self)
    love.graphics.setColor(self.fadeBackground)
    love.graphics.rectangle(
        'fill',self.center.x-self.screenWidth*0.5,
        self.center.y-self.screenHeight*0.5,
        self.screenWidth,self.screenHeight
    )
    love.graphics.setColor(1,1,1)
    
    love.graphics.printf(
        "Choose an Upgrade!",self.fonts.title,
        self.center.x-self.screenWidth,
        self.center.y-self.screenHeight*0.2,
        self.screenWidth,'center',nil,2
    )

    for i=1,#self.cards do self.cards[i]:draw() end
end

local despawnCards=function(self)
    for i=1,#self.cards do 
        local card=self.cards[i]
        card.state='despawn' 
        card.animations.current:gotoFrame(1)
        card.animations.current:resume()
    end
end

--card methods-------------------------------------------------------------------------------------
local cardUpdate=function(self,x,y)
    self.x,self.y=x+self.xOffset,y+self.yOffset 
    local onLoop=self.animations.current:update(dt)
    return self.stateMachine[self.state](self,onLoop)
end

local cardDraw=function(self)
    if self.isCardVisible then 
        love.graphics.draw(self.sprite,self.x,self.y) 
        love.graphics.setFont(self.titleFont)
        love.graphics.printf(self.title,self.x+10,self.y+self.titleOffset+13,98,'center')
        love.graphics.setFont(self.textFont)
        love.graphics.printf(self.desc,self.x+10,self.y+40,98,'center')
        if self.isButtonPressed then 
            love.graphics.draw(self.pressedButtonSprite,self.x,self.y)
        end
    end
    self.animations.current:draw(self.poof,self.x,self.y)
end

local cardStateMachine={
    spawn=function(self,onLoop) --spawn poof animation
        self.isCardVisible=(self.animations.current.position>=7)
        if onLoop then 
            self.state='idle'
            self.isCardVisible=true
            self.animations.current:pauseAtEnd()
        end
    end,
    idle=function(self) --wait for player to press button
        if acceptInput then 
            if Controls.pressed.mouse
            and self:selectedMe(Controls.getMousePosition())
            then
                self.state='pressed'
                self.isButtonPressed=true
            end
        end
    end,
    pressed=function(self) --'press' button, activate upgrade
        self.pressedTimer=self.pressedTimer-dt 
        if self.pressedTimer<0 then 
            self.isButtonPressed=false 
            Upgrades:unlock(self.name)
            return true 
        end
    end,
    despawn=function(self,onLoop) --despawn animation
        self.isCardVisible=(self.animations.current.position<=6)
        if onLoop then return false end 
    end,
}

local selectedMe=function(self,mouseX,mouseY)
    local button={x=self.x+20,y=self.y+86,w=80,h=14}
    return not (mouseX<button.x or mouseX>button.x+button.w
        or mouseY<button.y or mouseY>button.y+button.h)
end

local newCard=function(self,name,x,y,xOffset,yOffset) --card constructor
    local def=Upgrades.definitions[name]
    local title=def.name
    local titleOffset=0
    if #title<=14 then titleOffset=8
    elseif #title<=23 then titleOffset=4 
    end
    local anims={}
    for name,anim in pairs(self.cardAnimations) do anims[name]=anim:clone() end
    anims.current=anims.spawn
    local card={
        name=name,
        sprite=self.cardSprite,
        pressedButtonSprite=self.cardPressedButtonSprite,
        poof=self.cardPoof,
        x=x, y=y,
        xOffset=xOffset, yOffset=yOffset,
        animations=anims,
        title=title,      
        desc=def.desc,
        titleOffset=titleOffset,
        titleFont=self.fonts.title,
        textFont=self.fonts.text,
        state='spawn',
        isCardVisible=false,
        isButtonPressed=false,
        pressedTimer=0.15,
        update=self.cardUpdate,
        draw=self.cardDraw,
        stateMachine=self.cardStateMachine,
        selectedMe=self.selectedMe,
    }
    table.insert(self.cards,card)
    return card 
end

return { --The Module
    cardSprite=sprite,
    cardPressedButtonSprite=pressedButtonSprite,
    cardPoof=poof,
    cardAnimations=animations,
    cardWidth=definitions.cardPoof.frameWidth,
    cardHeight=definitions.cardPoof.frameHeight,
    screenWidth=screenWidth,
    screenHeight=screenHeight,
    fadeBackground={53/255,53/255,64/255,0.4},
    fonts={title=Fonts.big,text=Fonts.white},
    center={x=0,y=0},
    cards={},
    upgradeSelectionDone=false,
    presentCards=presentCards,
    despawnCards=despawnCards,
    update=selectionUpdate,
    draw=selectionDraw,
    cardStateMachine=cardStateMachine,
    cardUpdate=cardUpdate,
    cardDraw=cardDraw,
    selectedMe=selectedMe,
    newCard=newCard,
}