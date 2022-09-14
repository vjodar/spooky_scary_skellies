local levelDefinitions={
    { --level 1
        map='forest1',
        wave1={
            pumpkin=5,            
        },
        wave2={
            zombie=5,            
        },
        wave3={
            ent=5,            
        },
    },
}

local bgColors={
    water={92/255,105/255,159/255},
    black={53/255,53/255,64/255},
    lava={229/255,111/255,75/255},
}

local mapDefinitions={
    forest1={
        name='forest1',
        frameWidth=928,
        frameHeight=800,
        sheetWidth=3712,
        sheetHeight=800,
        bgColor=bgColors.water,
        playerStartPos={x=80,y=672},
        boundaries={
            {x=0,y=0,w=928,h=100}, 
            {x=0,y=693,w=928,h=107},
            {x=0,y=100,w=71,h=593}, 
            {x=857,y=100,w=71,h=593},
        }
    },
}

local generateDrawData=function(defs)
    local sheets,anims={},{}

    for name,def in pairs(defs) do 
        local path='assets/maps/'..name..'.png'
        sheets[name]=love.graphics.newImage(path)

        local grid=anim8.newGrid(def.frameWidth,def.frameHeight,def.sheetWidth,def.sheetHeight)
        anims[name]=anim8.newAnimation(grid('1-4',1), 0.25)
    end

    return sheets,anims 
end
local spriteSheets,animations=generateDrawData(mapDefinitions)

local generateLevelBoundaries=function(boundaries)
    for i=1,#boundaries do 
        local b=boundaries[i]
        b.collisionClass='boundary'
        World:addItem(b)
    end
end

return { --The Module
    levelDefinitions=levelDefinitions,
    mapDefinitions=mapDefinitions,
    spriteSheets=spriteSheets,
    animations=animations,
    generateLevelBoundaries=generateLevelBoundaries,
    currentMap={},
    
    update=function(self) self.currentMap.anim:update(dt) end,    
    draw=function(self) self.currentMap.anim:draw(self.currentMap.spriteSheet,0,0) end,
    
    buildLevel=function(self,lvl)
        local level=self.levelDefinitions[lvl]
        local map=self.mapDefinitions[level.map]
        local start=map.playerStartPos

        love.graphics.setBackgroundColor(map.bgColor)
        Player.x,Player.y=map.playerStartPos.x,map.playerStartPos.y 
        World:update(Player,Player.x,Player.y)

        self.generateLevelBoundaries(map.boundaries)

        self.currentMap={
            spriteSheet=self.spriteSheets[map.name],
            anim=self.animations[map.name],
        }     
    end,
}