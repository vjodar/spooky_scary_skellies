local PlayState={}

function PlayState:startGame()

    map=love.graphics.newImage('assets/maps/placeholder2.png')

    Camera.target=Player
    Camera:zoomTo(2)
end

function PlayState:update()
    Camera:update()
    Objects:update()
end

function PlayState:draw()
    love.graphics.draw(map,-40,-50)
    Objects:draw()
end

--testing-------------------
function love.keyreleased(k) 
    if k=='escape' then love.event.quit() end 
    if k=='o' then 
        -- for i=1,1 do Entities:new('skeletonWarrior',Controls.getMousePosition()) end
        for i=1,1 do Entities:new('skeletonArcher',Controls.getMousePosition()) end 
        -- for i=1,1 do Entities:new('skeletonMageFire',Controls.getMousePosition()) end 
        -- for i=1,1 do Entities:new('skeletonMageIce',Controls.getMousePosition()) end 
        -- for i=1,1 do Entities:new('skeletonMageElectric',Controls.getMousePosition()) end 
    end
    if k=='p' then 
        -- for i=1,1 do Entities:new('pumpkin',Controls.getMousePosition()) end
        -- for i=1,1 do Entities:new('golem',Controls.getMousePosition()) end
        -- for i=1,1 do Entities:new('bat',Controls.getMousePosition()) end
        for i=1,1 do Entities:new('possessedArcher',Controls.getMousePosition()) end
    end
    if k=='k' then 
        for i=1,100 do Entities:new('skeletonWarrior',rnd(0,400),rnd(0,300)) end
        -- for i=1,100 do Entities:new('skeletonArcher',rnd(0,400),rnd(0,300)) end
        -- for i=1,50 do Entities:new('skeletonMageFire',rnd(0,400),rnd(0,300)) end
        -- for i=1,50 do Entities:new('skeletonMageIce',rnd(0,400),rnd(0,300)) end
        -- for i=1,100 do Entities:new('skeletonMageElectric',rnd(0,400),rnd(0,300)) end
    end
    if k=='l' then 
        for i=1,100 do Entities:new('possessedArcher',rnd(0,400),rnd(0,300)) end
    end
end
--testing-------------------

return PlayState
