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
    sprites.pumpkin=love.graphics.newImage('assets/shadows/shadow_pumpkin.png')
    sprites.golem=love.graphics.newImage('assets/shadows/shadow_golem.png')
    sprites.spider=love.graphics.newImage('assets/shadows/shadow_spider.png')

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
    love.graphics.draw(s.sprite,x+s.xOffset,y+s.yOffset,rot,1,1,s.xOrigin,s.yOrigin)
    love.graphics.setColor(1,1,1,1)
end

--contructor
function shadows:new(name,w,h)
    return {
        sprite=self.sprites[name],
        xOffset=w*0.5,
        yOffset=h*0.5,
        xOrigin=self.sprites[name]:getWidth()*0.5,
        yOrigin=self.sprites[name]:getHeight()*0.5,
        draw=self.drawFunction
    }
end

return shadows 