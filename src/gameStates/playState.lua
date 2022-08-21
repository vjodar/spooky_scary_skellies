local PlayState={}

function PlayState:startGame()

    map=love.graphics.newImage('assets/maps/placeholder.png')

    -- Player:setPosition(10,10)

    Camera.target=Player
    Camera:zoomTo(3)
end

function PlayState:update()
    Camera:update()
    Objects:update()
    if Controls.pressed.mouse then
        -- for i=1,1 do Entities:new('skeletonWarrior',Controls.getMousePosition()) end
        -- for i=1,10 do Entities:new('skeletonArcher',Controls.getMousePosition()) end 
        -- for i=1,10 do Entities:new('skeletonMageFire',Controls.getMousePosition()) end 
        -- for i=1,1 do Entities:new('skeletonMageIce',Controls.getMousePosition()) end 
        -- for i=1,1 do Entities:new('skeletonMageElectric',Controls.getMousePosition()) end 
        -- for i=1,1 do Entities:new('slime',Controls.getMousePosition()) end
    end
    if Controls.pressed.mouse2 then         
        -- for i=1,10 do Entities:new('slime',Controls.getMousePosition()) end
    end
end

function PlayState:draw()
    love.graphics.draw(map,-40,-50)
    Objects:draw()
end

return PlayState
