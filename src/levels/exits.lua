local definitions={
    dungeonStairs={
        w=16, h=18, xOffset=9, yOffset=9,
        animation={
            frameWidth=34,
            frameHeight=27,
            frames='1-11',
            durations={['1-6']=0.07,['7-11']=0.1},
        },
    },
    caveWallHole={
        w=26, h=4, xOffset=6, yOffset=26,
        animation={
            frameWidth=38,
            frameHeight=30,
            frames='1-12',
            durations={['1-6']=0.07,['7-12']=0.1},
        },
    },
    swampWallHole={
        w=38, h=5, xOffset=8, yOffset=31,
        animation={
            frameWidth=54,
            frameHeight=36,
            frames='1-11',
            durations={['1-6']=0.07,['7-11']=0.1},
        },
    },
}

local generateSprites=function(defs)
    local sprites,anims={},{}

    for name,def in pairs(defs) do         
        local path='assets/exits/'..name..'.png'
        sprites[name]=love.graphics.newImage(path)

        local animDef=def.animation
        local grid=anim8.newGrid(
            animDef.frameWidth,animDef.frameHeight,
            sprites[name]:getWidth(),animDef.frameHeight
        )
        anims[name]=anim8.newAnimation(grid(animDef.frames,1),animDef.durations)
    end

    return sprites,anims
end
local sprites,animations=generateSprites(definitions)

local exitUpdateFunction=function(self)
    local onLoop=self.anim:update(dt) 
    if onLoop then self.anim:pauseAtEnd() end
end

local exitDrawFunction=function(self)
    self.anim:draw(self.sprite,self.x-self.xOffset,self.y-self.yOffset)
end

return { --The Module
    definitions=definitions,
    sprites=sprites,
    animations=animations,
    exitUpdateFunction=exitUpdateFunction,
    exitDrawFunction=exitDrawFunction,
    new=function(self,name,x,y) --constructor        
        local def=self.definitions[name]
        local exit={
            x=x, y=y, w=def.w, h=def.h,            
            xOffset=def.xOffset or 0,
            yOffset=def.yOffset or 0,
            sprite=self.sprites[name],
            anim=self.animations[name]:clone(),
            collisionClass='exit',
            update=self.exitUpdateFunction,
            draw=self.exitDrawFunction,
        }
        table.insert(Objects.table,exit)
        World:addItem(exit)
        return exit 
    end,
}