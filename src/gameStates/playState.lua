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
    World:setQueryDebugDrawing(true)
    --testing--------------------------------

    map=love.graphics.newImage('assets/maps/placeholder.png')

    Objects:load()
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
        --     x=Player.x,y=Player.y,name='arrow',
        --     attackDamage=1,knockback=1,angle=getAngle(Player,{x=mouseX,y=mouseY})
        -- })
        -- Entities:new('skeletonWarrior',Controls.getMousePosition())
        Entities:new('skeletonArcher',Controls.getMousePosition())
    end
    if Controls.pressed.mouse2 then 
        Entities:new('slime',Controls.getMousePosition())
    end
end

function PlayState:draw()
    love.graphics.draw(map,-40,-50)
    -- World:draw()
    Objects:draw()
end

return PlayState
