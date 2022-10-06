local shadowNames={
    --player and skeletons
    'player',               --12x7
    'skeletonWarrior',      --10x6
    'skeletonArcher', 
    'skeletonMageFire',
    'skeletonMageIce',
    'skeletonMageElectric',

    --enemies
    'slime',                --11x5
    'pumpkin',              
    'golem',                --14x8
    'spider',               
    'slimeMatron',          --14x5
    'bat',                  --6x4
    'zombie',
    'possessedArcher',
    'possessedKnight',
    'undeadMiner',
    'ent',                  --16x9
    'headlessHorseman',     --25x10
    'vampire',
    'tombstone',            --19x7
    'spiderEgg',            --20x8
    'imp',                  --9,6
    'gnasherDemon',
    'frankenstein',         --20x11
    'werebear',             --30x11
    'werewolf',             --18x8
    'ghost',                --10x7
    'poltergeist',
    'pyreFiend',
    'floatingEyeball',      --12x10
    'beholder',             --19x16
    'giantTombstone',       --42x12
    'obsidianGolem',        --38x16

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
    'blueSpark',
    'mug',
    'bottle',
    'candle',
    'fireball',
    'blizzard',
    'laser',
    'pyre',
    'pyreTrail',
    'orb',
    'obsidianFireball',
}

local sharedSprites={
    skeletonArcher='skeletonWarrior',
    skeletonMageFire='skeletonWarrior',
    skeletonMageIce='skeletonWarrior',
    skeletonMageElectric='skeletonWarrior',

    pumpkin='player',
    spider='player',
    zombie='skeletonWarrior',
    undeadMiner='skeletonWarrior',
    possessedArcher='player',
    possessedKnight='player',
    vampire='player',
    gnasherDemon='player',
    poltergeist='ghost',
    pyreFiend='frankenstein',
    
    darkArrow='arrow',
    blueSpark='spark',
    blizzard='jack-o-lantern',
    pyreTrail='pyre',
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