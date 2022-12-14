local definitions={
    chestSmall={
        w=12, h=8, xOffset=2, yOffset=12,
        frameWidth=16,
        frameHeight=20,
        animations={
            spawn={                
                frames='1-7',
                row=1,
                durations=0.1,
            },
            open={                
                frames='1-4',
                row=2,
                durations=0.12,
            },
        }
    },

    chestLarge={
        w=24, h=8, xOffset=3, yOffset=15,
        frameWidth=30,
        frameHeight=23,
        animations={
            spawn={                
                frames='1-8',
                row=1,
                durations=0.1,
            },
            open={                
                frames='1-4',
                row=2,
                durations=0.12,
            },
        }
    },
}

local generateDrawData=function(defs)
    local getImage=function(name) return love.graphics.newImage('assets/chests/'..name..'.png') end 
    local sprites,anims={},{}

    for name,def in pairs(defs) do
        sprites[name]=getImage(name)
        local w,h=sprites[name]:getDimensions()
        local grid=anim8.newGrid(def.frameWidth,def.frameHeight,w,h)

        anims[name]={}
        for anim,animDef in pairs(def.animations) do
            anims[name][anim]=anim8.newAnimation(
                grid(animDef.frames, animDef.row), 
                animDef.durations
            )
        end
    end

    return sprites, anims 
end
local sprites,animations=generateDrawData(definitions)

local chestUpdate=function(self) self.stateMachine[self.state](self) end
local chestDraw=function(self)
    self.shadow:draw(self.x,self.y)
    self.animations.current:draw(
        self.sprite,self.x-self.xOffset,self.y-self.yOffset
    )
end

local chestSpawn=function(self)
    local onLoop=self.animations.current:update(dt)
    if onLoop then 
        self.animations.current=self.animations.open 
        self.animations.current:pauseAtStart() 
        self.state='idle'
    end 
end

local chestIdle=function() end 

local chestOpen=function(self)
    local onLoop=self.animations.current:update(dt)
    if onLoop then 
        self.animations.current:pauseAtEnd() 
        self.state='idle'
    end
end

local activateChest=function(self)
    self.animations.current:resume()
    self.state='open'
    self.name='activatedChest'    
    
    --Large (boss) chests get 5 cards, otherwise 3 cards
    local isBossChest=self.size=='large'
    local cardCount=isBossChest and 5 or 3
    UpgradeSelectionState:presentCards(cardCount,isBossChest)
    Audio:playSfx('spawnPoof')
end

return { --The Module
    definitions=definitions,
    sprites=sprites,
    animations=animations,
    chestUpdate=chestUpdate,
    chestDraw=chestDraw,
    chestStateMachine={
        spawn=chestSpawn,
        idle=chestIdle,
        open=chestOpen,
    },
    activateChest=activateChest,
    new=function(self,name,x,y) --constructor
        local def=self.definitions[name]
        local animations={}
        for animName,anim in pairs(self.animations[name]) do 
            animations[animName]=anim:clone() 
        end
        animations.current=animations.spawn
        local size=name=='chestLarge' and 'large' or 'small'
        local chest={
            name='chest', size=size, state='spawn',
            x=x, y=y, w=def.w, h=def.h,
            xOffset=def.xOffset, 
            yOffset=def.yOffset,
            sprite=self.sprites[name],
            collisionClass='solid',
            animations=animations,
            shadow=Shadows:new(name,def.w,def.h),
            update=self.chestUpdate,
            draw=self.chestDraw,
            stateMachine=self.chestStateMachine,
            activateChest=self.activateChest,
        }
        table.insert(Objects.table,chest)
        World:addItem(chest)
        Audio:playSfx('spawnPoof')
        return chest 
    end,
}
