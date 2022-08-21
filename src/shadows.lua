local shadowSprites=function()
    local sprites={}
    --player/skeletons
    sprites.player=love.graphics.newImage('assets/shadows/shadow_player.png')
    sprites.skeletonWarrior=love.graphics.newImage('assets/shadows/shadow_skeleton.png')
    sprites.skeletonArcher=sprites.skeletonWarrior 
    sprites.skeletonMageFire=sprites.skeletonWarrior 
    sprites.skeletonMageIce=sprites.skeletonWarrior 
    sprites.skeletonMageElectric=sprites.skeletonWarrior

    --enemies
    sprites.slime=love.graphics.newImage('assets/shadows/shadow_slime.png')

    --projectiles
    sprites.arrow=love.graphics.newImage('assets/shadows/shadow_arrow.png')
    sprites.flame=love.graphics.newImage('assets/shadows/shadow_flame.png')
    sprites.icicle=love.graphics.newImage('assets/shadows/shadow_icicle.png')
    sprites.spark=love.graphics.newImage('assets/shadows/shadow_spark.png')
    sprites.bone=love.graphics.newImage('assets/shadows/shadow_bone.png')

    return sprites
end 

local shadows={}
shadows.sprites=shadowSprites()
shadows.drawFunction=function(s,x,y,rot)
    love.graphics.setColor(1,1,1,0.6)
    love.graphics.draw(s.sprite,x,y,rot,1,1)
    love.graphics.setColor(1,1,1,1)
end

--contructor
function shadows:new(name)
    return {sprite=self.sprites[name],draw=self.drawFunction}
end

return shadows 