local PlayState={}

function PlayState:startGame()

    map=love.graphics.newImage('assets/maps/placeholder.png')

    Player:setPosition(10,10)

    Camera.target=Player
    Camera:zoomTo(3)
end

function PlayState:update()
    Camera:update()
    World:update(dt)
    Objects:update()
    if Controls.pressed.mouse then
        -- for i=1,1 do Entities:new('skeletonWarrior',Controls.getMousePosition()) end
        -- for i=1,10 do Entities:new('skeletonArcher',Controls.getMousePosition()) end 
        -- for i=1,10 do Entities:new('skeletonMageFire',Controls.getMousePosition()) end 
        -- for i=1,1 do Entities:new('skeletonMageIce',Controls.getMousePosition()) end 
        for i=1,1 do Entities:new('skeletonMageElectric',Controls.getMousePosition()) end 
    end
    if Controls.pressed.mouse2 then 
        -- local mx,my=Controls.getMousePosition()
        -- Projectiles:new({
        --     x=Player.x,y=Player.y,name='icicle',
        --     attackDamage=1,knockback=1,
        --     angle=getAngle(Player,{x=mx,y=my}),
        --     yOffset=-10
        -- })
        for i=1,10 do Entities:new('slime',Controls.getMousePosition()) end
    end
end

function PlayState:draw()
    love.graphics.draw(map,-40,-50)
    -- World:draw()
    Objects:draw()
end

return PlayState
