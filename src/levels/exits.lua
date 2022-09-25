local definitions={
    dungeonStairs={w=16, h=18, yOffset=5,}
}

local generateSprites=function(defs)
    local sprites,anims={},{}

    for name,def in pairs(defs) do         
        local path='assets/exits/'..name..'.png'
        sprites[name]=love.graphics.newImage(path)
    end

    return sprites,anims
end
local sprites=generateSprites(definitions)

local exitUpdateFunction=function(self)
    if self.exitReached then 
        -- LevelManager:nextLevel()
        print('exit has been reached!')
    end
end

local exitDrawFunction=function(self)
    love.graphics.draw(self.sprite,self.x-self.xOffset,self.y-self.yOffset)
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
            collisionClass='exit',
            update=self.exitUpdateFunction,
            draw=self.exitDrawFunction,
        }
        table.insert(Objects.table,exit)
        World:addItem(exit)
        return exit 
    end,
}