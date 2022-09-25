local definitions={
    -- swamp terrain-----------------------------------------------------------
    mushroomSwamp={
        w=6,h=4,yOffset=5, class='pit',
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
            'mushroomSwamp11',
            'mushroomSwamp12',
        },
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

    pitSwampSmall={
        w=24,h=23,class='pit',
        sprites={
            'pitSwamp1',
            'pitSwamp2',
            'pitSwamp3',
            'pitSwamp4',
        }
    },
    pitSwampLarge={
        w=40,h=39,class='pit',
        sprites={
            'pitSwamp5',
            'pitSwamp6',
        }
    },
    pitWater1={
        w=24, h=23, class='pit',
        animation={frames='1-4',duration=0.25},
    },
    pitWater2={
        w=40, h=39, class='pit',
        animation={frames='1-4',duration=0.25},
    },
    pitWater3={
        w=56, h=54, class='pit',
        animation={frames='1-4',duration=0.25},
    },
    moundSwampSmall={
        w=34,h=37,class='solid',
        sprites={
            'moundSwamp1',
            'moundSwamp2',
            'moundSwamp3',
            'moundSwamp4',
        }
    },
    moundSwampLarge={
        w=50,h=53,class='solid',
        sprites={
            'moundSwamp5',
            'moundSwamp6',
            'moundSwamp7',
        }
    },

    --cave terrrain------------------------------------------------------------
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
            'mushroomBig11',
            'mushroomBig12',
        },
    },
    mushroomCave={
        w=6,h=4,yOffset=5, class='pit',
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
            'mushroomCave11',
            'mushroomCave12',
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

    pitCaveSmall={
        w=26,h=26,class='pit',
        sprites={
            'pitCave1',
            'pitCave2',
            'pitCave3',
            'pitCave4',
        }
    },
    pitCaveLarge={
        w=42,h=42,class='pit',
        sprites={
            'pitCave5',
            'pitCave6',
            'pitCave7',
            'pitCave8',
        }
    },
    moundCaveSmall={
        w=34,h=37,class='solid',
        sprites={
            'moundCave1',
        }
    },
    moundCaveLarge={
        w=50,h=53,class='solid',
        sprites={
            'moundCave5',
        }
    },
    pitLava1={
        w=26, h=26, class='pit',
        animation={frames='1-4',duration=0.25},
    },
    pitLava2={
        w=42, h=42, class='pit',
        animation={frames='1-4',duration=0.25},
    },
    pitLava3={
        w=58, h=58, class='pit',
        animation={frames='1-4',duration=0.25},
    },

    --dungeon terrain---------------------------------------------
    tableSmall={
        w=30, h=29, class='pit',
        sprites={
            'tableSmall1',
        },
    },
    tableVertical={
        w=30, h=29, class='pit',        
        sprites={
            'tableVertical1',
        },
    },
    tableLarge={
        w=60, h=28, class='pit',
        sprites={
            'tableLarge1',
        },
    },
    crateLarge={
        w=24, h=16, yOffset=6,
        sprites={
            'crateLarge1',
            'crateLarge2',
            'crateLarge3',
        }
    },
    crateSmall={
        w=10, h=8, yOffset=6, class='pit',
        sprites={
            'crateSmall1',
            'crateSmall2',
            'crateSmall3',
            'crateSmall4',
        }
    },
    pitDungeonWaterSmall={
        w=30, h=28, class='pit',
        animation={frames='1-4',duration=0.25},
    },
    pitDungeonLavaSmall={
        w=30, h=28, class='pit',
        animation={frames='1-4',duration=0.25},
    },
    pitDungeonAcidSmall={
        w=30, h=28, class='pit',
        animation={frames='1-4',duration=0.25},
    },
}

local generateDrawData=function(defs)
    local sprites,anims={},{}

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

        if def.animation then 
            local grid=anim8.newGrid(
                def.w,def.h,sprites[name]:getWidth(),def.h
            )
            local animDef=def.animation
            anims[name]=anim8.newAnimation(
                grid(animDef.frames,1),animDef.duration
            )
        end
    end

    return sprites,anims
end
local sprites,animations=generateDrawData(definitions)

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

return { --The Module
    definitions=definitions,
    sprites=sprites,
    animations=animations,
    terrainUpdateFunction=terrainUpdateFunction,
    terrainDrawFunction=terrainDrawFunction,

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
        }
        World:addItem(t)
        table.insert(Objects.table,t)
        return t
    end,
}