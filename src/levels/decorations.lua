local definitions={
    swampSmall={
        w=16,h=16,
        sprites={
            'swampSmall1',
            'swampSmall2',
            'swampSmall3',
            'swampSmall4',
            'swampSmall5',
            'swampSmall6',
            'swampSmall7',
            'swampSmall8',
        },
    },
    swampBig={
        w=32,h=32,
        sprites={'swampBig1','swampBig2',},
    },
    caveSmall={
        w=16,h=16,
        sprites={
            'caveSmall1',
            'caveSmall2',
            'caveSmall3',
            'caveSmall4',
            'caveSmall5',
            'caveSmall6',
            'caveSmall7',
            'caveSmall8',
        },
    },
    caveBig={
        w=32,h=32,
        sprites={'caveBig1',},
    },
}

local generateSprites=function(defs)
    local sprites={}

    for _,decor in pairs(defs) do 
        for i=1,#decor.sprites do 
            local name=decor.sprites[i]
            local path='assets/decorations/'..name..'.png'
            sprites[name]=love.graphics.newImage(path)
        end
    end
    
    return sprites
end
local sprites=generateSprites(definitions)

local decorDrawFunction=function(self)
    love.graphics.draw(self.sprite,self.x,self.y)
end

return { --The Module
    definitions=definitions,
    sprites=sprites,
    decorDrawFunction=decorDrawFunction, 
    new=function(self,name,x,y) --constructor
        local def=self.definitions[name]
        local spriteName=rndElement(def.sprites)
        return {
            x=x, y=y, w=def.w, h=def.h,
            sprite=self.sprites[spriteName],
            draw=self.decorDrawFunction
        }
    end
}