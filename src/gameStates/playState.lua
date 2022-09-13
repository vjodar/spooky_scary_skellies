local PlayState={}

function PlayState:startGame()
    LevelManager:buildLevel(1)
    Camera:zoomTo(2)
    Camera.target=Player
end

function PlayState:update()
    Camera:update()
    LevelManager:update()
    Objects:update()
end

function PlayState:draw()
    LevelManager:draw()
    Objects:draw()
end

--testing-------------------
function love.keyreleased(k) 
    if k=='escape' then love.event.quit() end 
    if k=='o' then 
        -- for i=1,1 do Entities:new('skeletonWarrior',Controls.getMousePosition()) end
        -- for i=1,1 do Entities:new('skeletonArcher',Controls.getMousePosition()) end 
        for i=1,1 do Entities:new('skeletonMageFire',Controls.getMousePosition()) end 
        -- for i=1,1 do Entities:new('skeletonMageIce',Controls.getMousePosition()) end 
        -- for i=1,1 do Entities:new('skeletonMageElectric',Controls.getMousePosition()) end 
    end
    if k=='p' then 
        for i=1,1 do Entities:new('bat',Controls.getMousePosition()) end
        -- for i=1,1 do Entities:new('spider',Controls.getMousePosition()) end
        -- for i=1,1 do Entities:new('bat',Controls.getMousePosition()) end
        -- for i=1,1 do Entities:new('headlessHorseman',Controls.getMousePosition()) end
    end
    if k=='l' then 
        for i=1,50 do Entities:new('tombstone',rnd(100,800),rnd(100,600)) end
        -- for i=1,50 do Entities:new('gnasherDemon',rnd(0,400),rnd(0,300)) end
    end
    if k=='j' then 
        for i,def in pairs(Entities.definitions) do
            if def.collider.class=='enemy' then
                for j=1,5 do Entities:new(def.name,rnd(800),rnd(600)) end
            end
        end
    end
end
--testing-------------------

return PlayState
