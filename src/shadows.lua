local shadowNames={
    --player and skeletons
    'player',
    'skeletonWarrior',
    'skeletonArcher',
    'skeletonMageFire',
    'skeletonMageIce',
    'skeletonMageElectric',

    --enemies
    'slime',
    'pumpkin',
    'golem',
    'spider',
    'slimeMatron',
    'bat',
    'zombie',
    'possessedArcher',
    'possessedKnight',
    'undeadMiner',
    'ent',
    'headlessHorseman',
    'vampire',
    'tombstone',
    'spiderEgg',

    --projectiles
    'arrow',
    'flame',
    'icicle',
    'spark',
    'bone',
    'darkArrow',
    'pickaxe',
    'apple',
    'jack-o-lantern',
}

local sharedSprites={
    skeletonArcher='skeletonWarrior',
    skeletonMageFire='skeletonWarrior',
    skeletonMageIce='skeletonWarrior',
    skeletonMageElectric='skeletonWarrior',

    spider='pumpkin',
    zombie='skeletonWarrior',
    undeadMiner='skeletonWarrior',
    possessedArcher='player',
    possessedKnight='player',
    vampire='player',
    
    darkArrow='arrow',
}

local generateShadowSprites=function()
    local sprites={}

    for i=1,#shadowNames do 
        local name=shadowNames[i]
        if sharedSprites[name] then 
            sprites[name]=sprites[sharedSprites[name]]
        else 
            local path='assets/shadows/shadow_'..name..'.png'
            sprites[name]=love.graphics.newImage(path)
        end
    end

    return sprites
end

--Module
return {
    sprites=generateShadowSprites(),
    drawFunction=function(s,x,y,rot)
        love.graphics.setColor(1,1,1,0.6)
        love.graphics.draw(s.sprite,x+s.xOffset,y+s.yOffset,rot,1,1,s.xOrigin,s.yOrigin)
        love.graphics.setColor(1,1,1,1)
    end,    
    new=function(self,name,w,h) --constructor
        return {
            sprite=self.sprites[name],
            xOffset=w*0.5,
            yOffset=h*0.5,
            xOrigin=self.sprites[name]:getWidth()*0.5,
            yOrigin=self.sprites[name]:getHeight()*0.5,
            draw=self.drawFunction
        }
    end,
}