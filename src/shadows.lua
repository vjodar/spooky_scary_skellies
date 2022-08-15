local shadows={}

function shadows:load()
    self.sprites={}
    self.sprites.player=love.graphics.newImage('assets/shadows/shadow_player.png')

    --skeletons
    self.sprites.skeletonWarrior=love.graphics.newImage('assets/shadows/shadow_skeleton.png')
    self.sprites.skeletonArcher=self.sprites.skeletonWarrior 
    self.sprites.skeletonMageFire=self.sprites.skeletonWarrior 
    self.sprites.skeletonMageIce=self.sprites.skeletonWarrior 
    self.sprites.skeletonMageElectric=self.sprites.skeletonWarrior

    --enemies
    self.sprites.slime=love.graphics.newImage('assets/shadows/shadow_slime.png')

    --projectiles
    self.sprites.arrow=love.graphics.newImage('assets/shadows/shadow_arrow.png')
    self.sprites.flame=love.graphics.newImage('assets/shadows/shadow_flame.png')
    self.sprites.icicle=love.graphics.newImage('assets/shadows/shadow_icicle.png')    
    self.sprites.spark=love.graphics.newImage('assets/shadows/shadow_spark.png')    

    --shadow functions
    self.drawFunction=function(s,x,y,rot)
        love.graphics.setColor(1,1,1,0.6)
        love.graphics.draw(s.sprite,x,y,rot,1,1,s.xOffset,s.yOffset)
        love.graphics.setColor(1,1,1,1)
    end
end

--contructor
function shadows:new(name)
    local s={}
    s.sprite=self.sprites[name]
    s.xOffset=s.sprite:getWidth()*0.5
    s.yOffset=s.sprite:getHeight()*0.5
    s.draw=self.drawFunction
    return s
end

return shadows 