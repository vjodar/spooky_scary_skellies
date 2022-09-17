local definitions={
    mushroomBig={
        w=14,h=10,yOffset=18,
        sprites={
            'mushroomBig1',
            'mushroomBig2',
            'mushroomBig3',
            'mushroomBig4',
            'mushroomBig5',
            'mushroomBig6',
            'mushroomBig7',
            'mushroomBig8',
            'mushroomBig9',
            'mushroomBig10',
        },
    },
    mushroomSwamp={
        w=6,h=4,yOffset=5,
        class='pit',
        sprites={
            'mushroomSwamp1',
            'mushroomSwamp2',
            'mushroomSwamp3',
            'mushroomSwamp4',
            'mushroomSwamp5',
            'mushroomSwamp6',
            'mushroomSwamp7',
            'mushroomSwamp8',
            'mushroomSwamp9',
            'mushroomSwamp10',
        },
    },
    mushroomCave={
        w=6,h=4,yOffset=5,
        class='pit',
        sprites={
            'mushroomCave1',
            'mushroomCave2',
            'mushroomCave3',
            'mushroomCave4',
            'mushroomCave5',
            'mushroomCave6',
            'mushroomCave7',
            'mushroomCave8',
            'mushroomCave9',
            'mushroomCave10',
        },
    },
    rockCaveLarge={
        w=22,h=18,yOffset=8,
        sprites={'rockCaveL1','rockCaveL2'},
    },
    rockCaveMedium={
        w=14,h=10,yOffset=5,class='pit',
        sprites={'rockCaveM1','rockCaveM2'},
    },
    rockCaveSmall={
        w=12,h=8,yOffset=4,class='pit',sprites={'rockCaveS'},
    },
    rockGem={
        w=12,h=8,yOffset=4,class='pit',
        sprites={'rockGem1','rockGem2','rockGem3','rockGem4'},
    },
    rockSwampMedium={
        w=14,h=10,yOffset=5,class='pit',
        sprites={'rockSwampM1','rockSwampM2'},
    },
    rockSwampSmall={
        w=12,h=8,yOffset=4,class='pit',sprites={'rockSwampS'},
    },
    signPost1={w=10,h=6,yOffset=5,class='pit',},
    signPost2={w=12,h=6,yOffset=5,class='pit',},
    stoneTablet1={w=10,h=6,yOffset=6,class='pit',},
    stoneTablet2={w=10,h=6,yOffset=8,class='pit',},
    stoneTablet3={w=12,h=6,yOffset=6,class='pit',},
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

    local addSprite=function(name)        
        local path='assets/terrain/'..name..'.png'
        sprites[name]=love.graphics.newImage(path)
    end

    for name,def in pairs(defs) do 
        if def.sprites then --terrain has multiple sprites
            for i=1,#def.sprites do addSprite(def.sprites[i]) end
        else --only one sprite
            addSprite(name)
        end
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

local terrainUpdateFunction=function(self)
    if self.anim then self.anim:update(dt) end
end

local terrainDrawFunction=function(self)
    if self.anim then 
        self.anim:draw(self.sprite,self.x-self.xOffset,self.y-self.yOffset)
        return
    end 
    love.graphics.draw(self.sprite,self.x-self.xOffset,self.y-self.yOffset)
end

local terrainDestroyFunction=function(self) self.state='dead' end

return { --The Module
    definitions=definitions,
    sprites=sprites,
    animations=animations,
    terrainUpdateFunction=terrainUpdateFunction,
    terrainDrawFunction=terrainDrawFunction,
    terrainDestroyFunction=terrainDestroyFunction,

    new=function(self,name,x,y) --constructor
        local def=self.definitions[name]
        local spriteName=def.sprites and rndElement(def.sprites) or name
        local anim=def.animation and self.animations[name]:clone() or nil
        if anim then anim:gotoFrame(rnd(4)) end
        local t={
            name=name,
            sprite=self.sprites[spriteName],
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