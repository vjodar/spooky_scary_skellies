local definitions={
    mushroomL1={w=14,h=10,yOffset=18,},
    mushroomL2={w=14,h=10,yOffset=18,},
    mushroomL3={w=14,h=10,yOffset=18,},
    mushroomL4={w=14,h=10,yOffset=18,},
    mushroomL5={w=14,h=10,yOffset=18,},
    mushroomL6={w=14,h=10,yOffset=18,},
    mushroomL7={w=14,h=10,yOffset=18,},
    mushroomL8={w=14,h=10,yOffset=18,},
    mushroomS1={w=6,h=4,yOffset=5,},
    mushroomS2={w=6,h=4,yOffset=5,},
    mushroomS3={w=6,h=4,yOffset=5,},
    mushroomS4={w=6,h=4,yOffset=5,},
    mushroomS5={w=6,h=4,yOffset=5,},
    mushroomS6={w=6,h=4,yOffset=5,},
    mushroomS7={w=6,h=4,yOffset=5,},
    mushroomS8={w=6,h=4,yOffset=5,},
    rockCaveL1={w=22,h=18,yOffset=8,},
    rockCaveL2={w=22,h=18,yOffset=8,},
    rockCaveM1={w=14,h=10,yOffset=5,},
    rockCaveM2={w=14,h=10,yOffset=5,},
    rockCaveS={w=12,h=8,yOffset=4,},
    rockGem1={w=12,h=8,yOffset=4,},
    rockGem2={w=12,h=8,yOffset=4,},
    rockGem3={w=12,h=8,yOffset=4,},
    rockGem4={w=12,h=8,yOffset=4,},
    rockSwampM1={w=14,h=10,yOffset=5,},
    rockSwampM2={w=14,h=10,yOffset=5,},
    rockSwampS={w=12,h=8,yOffset=4,},
    signPost1={w=10,h=6,yOffset=5,},
    signPost2={w=12,h=6,yOffset=5,},
    stoneTablet1={w=10,h=6,yOffset=6,},
    stoneTablet2={w=10,h=6,yOffset=8,},
    stoneTablet3={w=12,h=6,yOffset=6,},
    treeLarge={w=12,h=10,xOffset=4,yOffset=15,},
    treeMedium={w=12,h=8,yOffset=17,},
    treePine={w=12,h=8,yOffset=13,},
    treeSmall={w=10,h=6,yOffset=15,},

    pitWater1={
        w=32, h=32,
        class='pit',
        animation='pit1',
    },
    pitWater2={
        w=48, h=48,
        class='pit',
        animation='pit2',
    },
    pitWater3={
        w=64, h=64,
        class='pit',
        animation='pit3',
    },
    pitLava1={
        w=32, h=32,
        class='pit',
        animation='pit1',
    },
    pitLava2={
        w=48, h=48,
        class='pit',
        animation='pit2',
    },
    pitLava3={
        w=64, h=64,
        class='pit',
        animation='pit3',
    },
}

local generateSprites=function(defs)
    local sprites={}
    for name,_ in pairs(defs) do 
        local path='assets/terrain/'..name..'.png'
        sprites[name]=love.graphics.newImage(path)
    end
    return sprites 
end
local sprites=generateSprites(definitions)

local generateAnimations=function(defs)
    local grids={
        pit1=anim8.newGrid(32,32,128,32),
        pit2=anim8.newGrid(48,48,192,48),
        pit3=anim8.newGrid(64,64,256,64),
    }
    local baseAnims={
        pit1=anim8.newAnimation(grids.pit1('1-4',1),0.25),
        pit2=anim8.newAnimation(grids.pit2('1-4',1),0.25),
        pit3=anim8.newAnimation(grids.pit3('1-4',1),0.25),
    }

    local anims={}
    for name,def in pairs(defs) do 
        if def.animation then anims[name]=baseAnims[def.animation] end
    end

    return anims 
end
local animations=generateAnimations(definitions)

return { --The Module
    definitions=definitions,
    sprites=sprites,
    animations=animations,

    terrainUpdateFunction=function(self)
        if self.anim then self.anim:update(dt) end
        if self.state=='dead' then 
            World:remove(self)
            return false
        end
    end,

    terrainDrawFunction=function(self)
        if self.anim then 
            self.anim:draw(self.sprite,self.x-self.xOffset,self.y-self.yOffset)
            return
        end 
        love.graphics.draw(self.sprite,self.x-self.xOffset,self.y-self.yOffset)
    end,

    terrainDestroyFunction=function(self) self.state='dead' end,

    new=function(self,name,x,y) --constructor
        local def=self.definitions[name]
        local anim=def.animation and self.animations[name]:clone() or nil
        local t={
            name=name,
            sprite=self.sprites[name],
            anim=anim,
            x=x, y=y, w=def.w, h=def.h,
            xOffset=def.xOffset or 0, 
            yOffset=def.yOffset or 0,
            collisionClass=def.class or 'solid',
            state='idle',
            update=self.terrainUpdateFunction,
            draw=self.terrainDrawFunction,
            destroy=self.terrainDestroyFunction,
        }
        World:addItem(t)
        table.insert(Objects.table,t)
        return t
    end,
}