local PlayState={}

function PlayState:load()    
    World=wf.newWorld()
    World:addCollisionClass('player')
    World:addCollisionClass('skeleton')
    World:addCollisionClass('enemy')
    World:addCollisionClass('projectile',
       {ignores={'projectile','player','skeleton','enemy'}}
    )
    World:addCollisionClass('solid')
    --testing--------------------------------
    -- World:setQueryDebugDrawing(true)
    --testing--------------------------------

    map=love.graphics.newImage('assets/maps/placeholder.png')

    Objects:load()
    Shadows:load()
    Player:load(10,10)
    Entities:load()
    Projectiles:load()

    Camera.target=Player
    Camera.cam:zoomTo(3)
end

function PlayState:update()
    Camera:update()
    World:update(dt)
    Objects:update()
    if Controls.pressed.mouse then
        local mouseX,mouseY=Controls.getMousePosition()
        -- Projectiles:new({
        --     x=Player.x,y=Player.y,name='spark',
        --     attackDamage=1,knockback=1,angle=getAngle(Player,{x=mouseX,y=mouseY}),
        --     yOffset=-5
        -- })
        -- Projectiles:new({
        --     x=projectile.x,y=projectile.y,name=projectile.name,
        --     attackDamage=self.attackDamage,knockback=self.knockback,
        --     angle=angleToTarget,yOffset=projectile.yOffset
        -- })
        for i=1,10 do Entities:new('skeletonWarrior',Controls.getMousePosition()) end
        -- for i=1,1 do Entities:new('skeletonArcher',Controls.getMousePosition()) end 
        -- for i=1,1 do Entities:new('skeletonMageFire',Controls.getMousePosition()) end 
        -- for i=1,1 do Entities:new('skeletonMageIce',Controls.getMousePosition()) end 
        -- for i=1,1 do Entities:new('skeletonMageElectric',Controls.getMousePosition()) end 
    end
    if Controls.pressed.mouse2 then 
        for i=1,20 do Entities:new('slime',Controls.getMousePosition()) end
    end
end

function PlayState:draw()
    love.graphics.draw(map,-40,-50)
    -- World:draw()
    Objects:draw()
end

return PlayState
